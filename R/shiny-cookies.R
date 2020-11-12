read_creds_from_cookies <- function(req, oauth_app) {
  cookies <- parse_cookies(req)
  gargle_token <- cookies[["gargle_token"]]
  if (!is.null(gargle_token)) {
    unwrap_creds(gargle_token, oauth_app)
  }
}

wrap_creds <- function(creds, oauth_app) {
  cred_str <- jsonlite::toJSON(creds, auto_unbox = TRUE)

  oauth_app_str <- enc2utf8(paste(oauth_app$secret, oauth_app$key))

  salt <- sodium::random(32)
  nonce <- sodium::random(24)
  key <- sodium::scrypt(charToRaw(oauth_app_str), salt = salt, size = 32)
  # TODO: Add an expiration time (to the encrypted/signed payload), so a
  # stolen cookie could only be used for a limited time.
  ciphertext <- sodium::data_encrypt(charToRaw(cred_str), key = key, nonce = nonce)

  sodium::bin2hex(c(salt, nonce, ciphertext))
}

unwrap_creds <- function(gargle_token, oauth_app) {
  if (is.null(gargle_token)) {
    return(NULL)
  }

  tryCatch({
    oauth_app_str <- paste(oauth_app$secret, oauth_app$key)

    bytes <- sodium::hex2bin(gargle_token)

    if (length(bytes) <= 32 + 24) {
      stop(call. = FALSE, "gargle cookie payload was too short")
    }

    salt <- bytes[1:32]
    nonce <- bytes[32 + (1:24)]
    rest <- utils::tail(bytes, -(32 + 24))

    key <- sodium::scrypt(charToRaw(oauth_app_str), salt = salt, size = 32)
    cleartext <- sodium::data_decrypt(rest, key = key, nonce = nonce)
    cleartext <- rawToChar(cleartext)
    Encoding(cleartext) <- "UTF-8"

    creds <- jsonlite::parse_json(cleartext)

    email <- jwt_decode(creds[["id_token"]])[["claim"]][["email"]]
    stopifnot(is.character(email) && length(email) == 1)

    token <- gargle2.0_token(email, oauth_app, package = "gargle",
      scope = creds$scope, credentials = creds)

    if (!token$validate()) {
      token$refresh()
    }

    token
  }, error = function(err) {
    ui_line("gargle cookie failed to decrypt: ", conditionMessage(err))
    return(NULL)
  })
}

parse_cookies <- function(req) {
  cookie_header <- req[["HTTP_COOKIE"]]
  if (is.null(cookie_header)) {
    return(NULL)
  }

  cookies <- strsplit(cookie_header, "; *")[[1]]
  m <- regexec("(.*?)=(.*)", cookies)
  matches <- regmatches(cookies, m)
  names <- vapply(matches, function(x) {
    if (length(x) == 3) {
      x[[2]]
    } else {
      ""
    }
  }, character(1))

  if (any(names == "")) {
    # Malformed cookie
    return(NULL)
  }

  values <- vapply(matches, function(x) {
    x[[3]]
  }, character(1))

  stats::setNames(as.list(values), names)
}

#' @export
cookie_options <- function(expires = NULL, max_age = NULL,
  domain = NULL, path = NULL, secure = NULL, http_only = NULL, same_site = NULL) {

  if (!is.null(expires)) {
    stopifnot(length(expires) == 1 && (inherits(expires, "POSIXt") || is.character(expires)))
    if (inherits(expires, "POSIXt")) {
      expires <- as.POSIXlt(expires, tz = "GMT")
      expires <- sprintf("%s, %02d %s %04d %02d:%02d:%02.0f GMT",
        c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")[[expires$wday + 1]],
        expires$mday,
        c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[[expires$mon + 1]],
        expires$year + 1900,
        expires$hour,
        expires$min,
        expires$sec
      )
    }
  }

  stopifnot(is.null(max_age) || (is.numeric(max_age) && length(max_age) == 1))
  if (!is.null(max_age)) {
    max_age <- sprintf("%.0f", max_age)
  }
  stopifnot(is.null(domain) || (is.character(domain) && length(domain) == 1))
  stopifnot(is.null(path) || (is.character(path) && length(path) == 1))
  stopifnot(is.null(secure) || isTRUE(secure))
  stopifnot(is.null(http_only) || isTRUE(http_only))

  stopifnot(is.null(same_site) || (is.character(same_site) && length(same_site) == 1 &&
      grepl("^(strict|lax|none)$", same_site, ignore.case = TRUE)))
  # Normalize case
  if (!is.null(same_site)) {
    same_site <- c(strict = "Strict", lax = "Lax", none = "None")[[tolower(same_site)]]
  }

  list(
    "Expires" = expires,
    "Max-Age" = max_age,
    "Domain" = domain,
    "Path" = path,
    "Secure" = secure,
    "HttpOnly" = http_only,
    "SameSite" = same_site
  )
}

set_cookie_header <- function(name, value, cookie_options = cookie_options()) {

  stopifnot(is.character(name) && length(name) == 1)
  stopifnot(is.null(value) || (is.character(value) && length(value) == 1))
  value <- value %||% ""

  parts <- rlang::list2(
    !!name := value,
    !!!cookie_options
  )
  parts <- parts[!vapply(parts, is.null, logical(1))]

  names <- names(parts)
  sep <- ifelse(vapply(parts, isTRUE, logical(1)), "", "=")
  values <- ifelse(vapply(parts, isTRUE, logical(1)), "", as.character(parts))
  header <- paste(collapse = "; ", paste0(names, sep, values))
  ui_line("Set-Cookie: ", header)
  list("Set-Cookie" = header)
}

delete_cookie_header <- function(name, cookie_options = cookie_options()) {
  cookie_options[["Expires"]] <- NULL
  cookie_options[["Max-Age"]] <- 0
  set_cookie_header(name, "", cookie_options)
}

jwt_decode <- function(jwt_str) {
  stopifnot(is.character(jwt_str) && length(jwt_str) == 1)
  pieces <- strsplit(jwt_str, ".", fixed = TRUE)[[1]]
  stopifnot(length(pieces) == 3)

  list(
    header = jsonlite::parse_json(rawToChar(base64enc::base64decode(pieces[[1]]))),
    claim = jsonlite::parse_json(rawToChar(base64enc::base64decode(pieces[[2]])))
  )
}


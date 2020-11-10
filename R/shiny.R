#' Require OAuth login for Shiny app
#'
#' Use this function to enforce Google Auth login for all visitors to a Shiny
#' app. Once logged in, a [token][Gargle-class] will be stored on the Shiny
#' session object and automatically used for any Google API operations that go
#' through gargle.
#'
#' @param app The return value from [shiny::shinyApp()]. For readability,
#'   consider using a pipe operator, i.e. `shinyApp() %>% require_oauth(...)`.
#' @param oauth_app An [httr::oauth_app()] object that provides the OAuth client
#'   ID and secret. See the [How to get your own API
#'   credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
#'   vignette and [oauth_app_from_json()].
#' @inheritParams token_fetch
#' @export
require_oauth <- function(app, oauth_app, scopes, welcome_ui,
  cookie_opts = cookie_options(http_only = TRUE)) {

  force(oauth_app)
  force(scopes)
  force(welcome_ui)

  scopes <- normalize_scopes(add_email_scope(scopes))

  httpHandler <- app$httpHandler
  app$httpHandler <- function(req) {
    resp <-
      handle_oauth_callback(req, oauth_app, cookie_opts) %||%
      handle_logged_in(req, oauth_app, httpHandler) %||%
      handle_welcome(req, oauth_app, scopes, cookie_opts)
    resp
  }

  serverFuncSource <- app$serverFuncSource
  app$serverFuncSource <- function() {
    wrappedServer <- serverFuncSource()
    function(input, output, session) {
      creds <- read_creds_from_cookies(session$request, oauth_app)
      if (is.null(creds)) {
        stop("gargle_token cookie expected but not found")
      } else {
        email <- jwt_decode(creds[["id_token"]])[["claim"]][["email"]]
        stopifnot(is.character(email) && length(email) == 1)

        token <- gargle2.0_token(email, oauth_app, package = "gargle",
          scope = creds$scope, credentials = creds)
        session$userData$gargle_token <- token
        wrappedServer(input, output, session)
      }
    }
  }

  app
}

handle_oauth_callback <- function(req, oauth_app, cookie_opts) {
  if (has_code_param(req)) {
    # User just completed login; verify, set cookie, and redirect
    cookies <- parse_cookies(req)
    gargle_auth_state <- cookies[["gargle_auth_state"]]
    if (!is.null(gargle_auth_state)) {
      qs <- shiny::parseQueryString(req[["QUERY_STRING"]])
      code <- qs$code
      state <- qs$state

      if (identical(state, gargle_auth_state)) {
        cred <- httr::oauth2.0_access_token(
          gargle_outh_endpoint(),
          app = oauth_app,
          code = code,
          redirect_uri = infer_app_url(req)
        )

        # cred has:
        # access_token, expires_in, scope, token_type, and id_token
        # (and possibly refresh_token)

        return(shiny::httpResponse(
          status = 307L,
          content_type = "text/plain",
          content = "",
          headers = rlang::list2(
            Location = infer_app_url(req),
            "Cache-Control" = "no-store",
            !!!delete_cookie_header("gargle_auth_state", cookie_opts),
            !!!set_cookie_header("gargle_token", wrap_creds(cred, oauth_app),
              cookie_opts)
          )
        ))
      }
    }
  }
}

handle_logged_in <- function(req, oauth_app, httpHandler) {
  if (!is.null(read_creds_from_cookies(req, oauth_app))) {
    # User is already logged in, proceed
    return(httpHandler(req))
  }
}

handle_welcome <- function(req, oauth_app, scopes, cookie_opts) {
  redirect_uri <- infer_app_url(req)
  state <- sodium::bin2hex(sodium::random(32))
  query_extra <- list(
    access_type = "offline"
  )

  # TODO: Add email?

  auth_url <- httr::oauth2.0_authorize_url(
    endpoint = gargle_outh_endpoint(),
    oauth_app,
    scope = paste(scopes, collapse = " "),
    redirect_uri = redirect_uri,
    state = state,
    query_extra = query_extra)

  shiny::httpResponse(
    status = 307L,
    content_type = NULL,
    content = "",
    headers = rlang::list2(
      Location = auth_url,
      "Cache-Control" = "no-store",
      !!!set_cookie_header("gargle_auth_state", state, cookie_opts)
    )
  )
}

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

    jsonlite::parse_json(cleartext)
  }, error = function(err) {
    ui_line("gargle cookie failed to decrypt: ", conditionMessage(err))
    return(NULL)
  })
}

has_code_param <- function(req) {
  qs <- shiny::parseQueryString(req[["QUERY_STRING"]])
  "code" %in% names(qs)
}

infer_app_url <- function(req) {

  url <-
    # Connect
    req[["HTTP_X_RSC_REQUEST"]] %||%
    req[["HTTP_RSTUDIO_CONNECT_APP_BASE_URL"]] %||%
    # ShinyApps.io
    if (!is.null(req[["HTTP_X_REDX_FRONTEND_NAME"]])) { paste0("https://", req[["HTTP_X_REDX_FRONTEND_NAME"]]) }

  if (is.null(url)) {
    forwarded_host <- req[["HTTP_X_FORWARDED_HOST"]]
    forwarded_port <- req[["HTTP_X_FORWARDED_PORT"]]

    host <- if (!is.null(forwarded_host) && !is.null(forwarded_port)) {
      paste0(forwarded_host, ":", forwarded_port)
    } else {
      req[["HTTP_HOST"]] %||% paste0(req[["SERVER_NAME"]], ":", req[["SERVER_PORT"]])
    }

    proto <- req[["HTTP_X_FORWARDED_PROTO"]] %||% req[["rook.url_scheme"]]

    if (tolower(proto) == "http") {
      host <- sub(":80$", "", host)
    } else if (tolower(proto) == "https") {
      host <- sub(":443$", "", host)
    }

    url <- paste0(
      proto,
      "://",
      host,
      req[["SCRIPT_NAME"]],
      req[["PATH_INFO"]]
    )
  }

  # Strip existing querystring, if any
  url <- sub("\\?.*", "", url)

  url
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
  list(
    "Set-Cookie" = paste(collapse = "; ", paste0(names, sep, values))
  )
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

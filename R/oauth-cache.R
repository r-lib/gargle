## this file has its origins in oauth-cache.R in httr
## nothing there is exported, so copied over, then it evolved

cache_gargle <- function() {
  "~/.R/gargle/gargle-oauth"
}

cache_establish <- function(cache = getOption("gargle.oauth_cache")) {
  if (length(cache) != 1) {
    stop("cache should be length 1 vector", call. = FALSE)
  }
  if (!is.logical(cache) && !is.character(cache)) {
    stop("Cache must either be logical or string (file path)")
  }

  # If NA, get permission to use cache file and store results of that check in
  # global option.
  if (is.na(cache)) {
    cache <- cache_available()
    options("gargle.oauth_cache" = cache)
  }
  ## cache is now TRUE, FALSE or path

  if (isFALSE(cache)) return()

  if (isTRUE(cache)) {
    cache <- cache_gargle()
  }

  if (!file.exists(cache)) {
    cache_create(cache)
  }
  return(cache)
}

cache_available <- function(path = cache_gargle()) {
  file.exists(path) || cache_allowed(path)
}

cache_allowed <- function(path = cache_gargle()) {
  if (!interactive()) return(FALSE)

  cat("Use a local file ('", path, "'), to cache OAuth access credentials ",
      "between R sessions?\n", sep = "")
  utils::menu(c("Yes", "No")) == 1
}

cache_create <- function(path = cache_gargle()) {

  cache_parent <- dirname(path)
  if (!dir.exists(cache_parent)) {
    dir.create(cache_parent, recursive = TRUE)
  }

  file.create(path, showWarnings = FALSE)
  if (!file.exists(path)) {
    stop("Failed to create local cache ('", path, "')", call. = FALSE)
  }

  "!DEBUG cache exists: `path`"

  ## owner can read and write, but not execute; no one else can do anything
  Sys.chmod(path, "0600")

  desc <- file.path(cache_parent, "DESCRIPTION")
  if (file.exists(desc)) {
    add_line(
      file.path(cache_parent, ".Rbuildignore"),
      paste0("^", gsub("\\.", "\\\\.", path), "$")
    )
  }
  git <- file.path(cache_parent, c(".gitignore", ".git"))
  if (any(file.exists(git))) {
    add_line(
      file.path(cache_parent, ".gitignore"),
      path
    )
  }

  TRUE
}

token_cache <- function(token) {
  "!DEBUG token_cache"
  if (is.null(token$cache_path)) return()

  tokens <- cache_load(token$cache_path)
  tokens <- token_upsert(tokens, token)
  saveRDS(tokens, token$cache_path)
}

token_upsert <- function(tokens, token) {
  "!DEBUG token_upsert"
  if (length(tokens) == 0 || nrow(tokens) == 0) return(entibble(token))

  m <- token_hash_match(tokens, token)
  if (!is.na(m)) {
    tokens <- tokens[-m, ]
  }
  tokens[nrow(tokens) + 1, ] <- entibble(token)
  tokens
}

entibble <- function(token) {
  "!DEBUG entibble"
  tibble::tibble(
    email = token$email,
    app_hash = rhash_app(token$app),
    scopes = list(token$params$scope),
    token = list(token)
  )
}

token_from_cache <- function(token) {
  if (is.null(token$cache_path)) return()
  tokens <- cache_load(token$cache_path)
  if(length(tokens) == 0 || nrow(tokens) == 0) return()

  token_match(tokens, token)
}

token_match <- function(existing, candidate) {
  m <- token_hash_match(existing, candidate)
  if (!is.na(m)) {
    return(existing$token[[m]])
  }

  m <- token_multi_match(existing, candidate)
  existing <- existing[m, ]

  if (nrow(existing) == 0) return()
  if (nrow(existing) == 1) return(existing$token[[1]])
  if (!interactive()) {
    stop("Multiple cached tokens exist. Unclear which to use.")
  }

  cat("Multiple cached tokens exist. Pick the one you want to use.\n")
  cat("Or enter '0' to obtain a new token.")
  this_one <- utils::menu(existing$email)

  if (this_one == 0) return()

  existing$token[[this_one]]
}

# find location of exact match based on value returned by the $hash() method
token_hash_match <- function(existing, candidate) {
  match(
    candidate$hash(),
    vapply(existing$token, function(x) x$hash(), character(1))
  )
}

# find locations of existing tokens that match candidate wrt
#   * email, iff candidate specifies email (otherwise, ignore email)
#   * OAuth app
#   * scopes, in this sense: candidate scopes are included in scopes of
#     existing token (which may, in fact, have more)
token_multi_match <- function(existing, candidate) {
  m_email <- if (is.null(candidate$email)) {
    TRUE
  } else {
    existing$email == candidate$email
  }
  m_app <- existing$app_hash == rhash_app(candidate$app)
  m_scopes <- scope_ok(existing$scopes, candidate$params$scope)
  which(m_email & m_app & m_scopes)
}

## TODO(jennybc): until we expose inspection, I don't see how this is useful
# remove_cached_token <- function(token) {
#   if (is.null(token$cache_path)) return()
#
#   tokens <- cache_load(token$cache_path)
#   tokens[[token$hash()]] <- NULL
#   saveRDS(tokens, token$cache_path)
# }

cache_load <- function(cache_path) {
  if (!file.exists(cache_path) || file_size(cache_path) == 0) {
    list()
  } else {
    readRDS(cache_path)
  }
}

file_size <- function(x) file.info(x, extra_cols = FALSE)$size

add_email_scope <- function(scope = NULL) {
  scope <- scope %||% character()
  if (any(scope == "email")) {
    scope
  } else {
    c(scope, "email")
  }
}

normalize_scopes <- function(x) {
  stats::setNames(sort(unique(x)), NULL)
}

scope_ok <- function(have, need) {
  vapply(have, function(x) all(need %in% x), logical(1))
}

rhash_app <- function(app) {
  stopifnot(is.oauth_app(app))
  paste(
    app$appname,
    rhash(app[c("secret", "key", "redirect_uri")]),
    sep = "_"
  )
}


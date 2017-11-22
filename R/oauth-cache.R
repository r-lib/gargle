## see oauth-cache.R in httr
## nothing there is exported, so to make desired changes to oauth caching
## I have to copy and mutate here

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
    cache <- cache_ok()
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

cache_ok <- function(path = cache_gargle()) {
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

  # Protect cache as much as possible
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
  "!DEBUG Cache has been loaded"
  saveRDS(tokens, token$cache_path)
}

token_upsert <- function(df, new) {
  "!DEBUG token_upsert"
  if (length(df) == 0 || nrow(df) == 0) {
    return(entibble(new))
  }

  m <- match(
    new$hash(), # endpoint, app, scopes, email
    vapply(df$token, function(x) x$hash(), character(1))
  )
  if (!is.na(m)) {
    df <- df[-1 * m, ]
  }
  df[nrow(df) + 1, ] <- entibble(new)
  df
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

fetch_cached_token <- function(token) {
  if (is.null(token$cache_path)) return()

  tokens <- cache_load(token$cache_path)
  "!DEBUG Cache has been loaded"
  if(length(tokens) == 0 || nrow(tokens) == 0) return()

  ## look for exact match
  m <- match(
    token$hash(), # endpoint, app, scopes, email
    vapply(tokens$token, function(x) x$hash(), character(1))
  )
  if (!is.na(m)) {
    return(tokens$token[[m]])
  }
  "!DEBUG No exact match"

  m_email <- if (is.null(token$email)) {
    TRUE
  } else {
    tokens$email == token$email
  }
  m_app <- tokens$app_hash == rhash_app(token$app)
  m_scopes <- scope_ok(tokens$scopes, token$params$scope)
  m <- m_email & m_app & m_scopes

  tokens <- tokens[m, ]

  if (nrow(tokens) == 0) return()

  if (nrow(tokens) == 1) {
    "!DEBUG One suitable token found"
    return(tokens$token[[1]])
  }

  if (!interactive()) {
    stop("Multiple cached tokens exist. Unclear which to use.")
  }

  emails <- tokens$email
  cat("Multiple cached tokens exist. Pick the one you want to use.\n")
  cat("Or enter '0' to obtain a new token.")
  this_one <- utils::menu(emails)

  if (this_one == 0) return()

  tokens$token[[this_one]]
}

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

## for this token hash:
## 2a46e6750476326f7085ebdab4ad103d-jenny@rstudio.com
## ^ mask_email() returns this ^    ^ extract_email() returns this ^
mask_email <- function(x) sub("^([^-]*).*", "\\1", x)
extract_email <- function(x) sub(".*-([^-]*)$", "\\1", x)

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

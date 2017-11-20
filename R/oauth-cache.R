## see oauth-cache.R in httr
## nothing there is exported, so to make desired changes to oauth caching
## I have to copy and mutate here

gargle_cache_path <- function() {
  "~/.R/gargle/gargle-oauth"
}

use_cache <- function(cache = getOption("gargle.oauth_cache")) {
  if (length(cache) != 1) {
    stop("cache should be length 1 vector", call. = FALSE)
  }
  if (!is.logical(cache) && !is.character(cache)) {
    stop("Cache must either be logical or string (file path)")
  }

  # If missing, see if it's ok to use one, and cache the results of
  # that check in a global option.
  if (is.na(cache)) {
    cache <- can_use_cache()
    options("gargle.oauth_cache" = cache)
  }
  ## cache is now TRUE, FALSE or path

  if (isFALSE(cache)) {
    return(NULL)
  }

  if (isTRUE(cache)) {
    cache <- gargle_cache_path()
  }

  if (!file.exists(cache)) {
    create_cache(cache)
  }
  return(cache)
}

can_use_cache <- function(path = gargle_cache_path()) {
  file.exists(path) || should_cache(path)
}

should_cache <- function(path = gargle_cache_path()) {
  if (!interactive()) return(FALSE)

  cat("Use a local file ('", path, "'), to cache OAuth access credentials ",
      "between R sessions?\n", sep = "")
  utils::menu(c("Yes", "No")) == 1
}

create_cache <- function(path = gargle_cache_path()) {

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

  ## TODO(jennybc): this only looks in exact directory of cache path, not up
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

cache_token <- function(token, cache_path) {
  "!DEBUG cache_token"
  if (is.null(cache_path)) return()

  tokens <- load_cache(cache_path)
  tokens <- insert_token(tokens, token)
  saveRDS(tokens, cache_path)
}

insert_token <- function(df, new) {
  "!DEBUG insert_token"
  if (length(df) == 0 || nrow(df) == 0) {
    return(entibble(new))
  }

  df <- df[df$hash != new$hash(), ]
  df[nrow(df) + 1, ] <- entibble(new)
  df
}

entibble <- function(token) {
  "!DEBUG entibble"
  tibble::tibble(
    hash = token$hash(),
    token = list(token)
  )
}

fetch_cached_token <- function(hash, cache_path) {
  if (is.null(cache_path)) return()

  tokens <- load_cache(cache_path)
  tokens$token[[match(hash, tokens$hash)]]
}


fetch_matching_tokens <- function(hash, cache_path) {
  if (is.null(cache_path)) return(NULL)

  "!DEBUG `cache_path`"
  tokens <- load_cache(cache_path)
  matches <- mask_email(tokens$hash) == mask_email(hash)

  if (!any(matches)) return(NULL)

  tokens <- tokens[matches, ]

  if (nrow(tokens) == 1) {
    "!DEBUG Using a token cached for `extract_email(names(tokens))`"
    return(tokens$token[[1]])
  }

  ## TODO(jennybc) if not interactive? just use first match? now I just give up
  if (!interactive()) {
    message("Multiple cached tokens exist. Unclear which to use.")
    return(NULL)
  }

  emails <- extract_email(tokens$hash)
  cat("Multiple cached tokens exist. Pick the one you want to use.\n")
  cat("Or enter '0' to obtain a new token.")
  this_one <- utils::menu(emails)

  if (this_one == 0) return(NULL)

  tokens$token[[this_one]]
}

# remove_cached_token <- function(token) {
#   if (is.null(token$cache_path)) return()
#
#   tokens <- load_cache(token$cache_path)
#   tokens[[token$hash()]] <- NULL
#   saveRDS(tokens, token$cache_path)
# }

load_cache <- function(cache_path) {
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

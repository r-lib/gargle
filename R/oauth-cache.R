## this file has its origins in oauth-cache.R in httr
## nothing there is exported, so copied over, then it evolved

# cache --------------------------------------------------------------

gargle_default_oauth_cache_path <- "~/.R/gargle/gargle-oauth"

## this is the cache setup interface for the Gargle2.0 class
cache_establish <- function(cache = getOption("gargle.oauth_cache")) {
  if (length(cache) != 1) {
    stop("Cache should be length 1 vector", call. = FALSE)
  }
  if (!is.logical(cache) && !is.character(cache)) {
    stop("Cache must either be logical or string (file path)")
  }

  # If NA, propose default cache file
  # request permission to create it, if doesn't exist yet
  # store result of that ask (TRUE or FALSE) in the option
  if (is.na(cache)) {
    cache <- cache_available(gargle_default_oauth_cache_path)
    options("gargle.oauth_cache" = cache)
  }
  ## cache is now TRUE, FALSE or path

  if (isFALSE(cache)) return()

  if (isTRUE(cache)) {
    cache <- gargle_default_oauth_cache_path
  }

  if (!file.exists(cache)) {
    cache_create(cache)
  }
  ## cache is now NULL or path to a file that exists (possibly empty)

  return(cache)
}

cache_available <- function(path) {
  file.exists(path) || cache_allowed(path)
}

cache_allowed <- function(path) {
  if (!interactive()) return(FALSE)

  cat("Use a local file ('", path, "'), to cache OAuth access credentials ",
      "between R sessions?\n", sep = "")
  utils::menu(c("Yes", "No")) == 1
}

cache_create <- function(path) {

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

cache_read <- function(path) {
  if (file.size(path) == 0) {
    list()
  } else {
    validate_token_list(readRDS(path))
  }
}

cache_write <- function(tokens, path) {
  saveRDS(tokens, path)
}

validate_token_list <- function(existing) {
  hashes <- vapply(existing, function(x) x$hash(), character(1), USE.NAMES = FALSE)
  nms <- names(existing)

  if (!identical(nms, hashes)) {
    stop("Token names do not match their hash!", call. = FALSE)
  }

  if (anyDuplicated(nms)) {
    stop("Duplicate tokens!, call. = FALSE")
  }

  existing
}

## useful to jennybc during development
cache_show <- function(path = NULL) { # nocov start
  path <- path %||% getOption("gargle.oauth_cache")
  if (is.na(path) || isTRUE(path)) {
    path <- gargle_default_oauth_cache_path
  }
  if (!file.exists(path)) {
    message("No cache found.")
    return()
  }
  if (file.size(path) == 0) {
    message("Cache is empty.")
    return(list())
  }
  readRDS(path)
} # nocov end

# retrieve and insert tokens from cache -----------------------------------

## these two functions provide the "current token <--> token cache" interface
## for the Gargle2.0 class
token_from_cache <- function(candidate) {
  "!DEBUG in token_from_cache"
  cache_path <- candidate$cache_path

  if (is.null(cache_path)) {
    "!DEBUG in token_from_cache, no cache"
    return()
  }

  "!DEBUG in token_from_cache, searching the cache"
  token_match(candidate, cache_read(cache_path))
}

token_into_cache <- function(candidate) {
  "!DEBUG in token_into_cache"
  cache_path <- candidate$cache_path

  if (is.null(cache_path)) {
    "!DEBUG in token_into_cache, but there is no cache"
    return()
  }

  "!DEBUG in token_into_cache, upserting"
  existing <- cache_read(cache_path)
  existing <- token_upsert(candidate, existing)
  cache_write(existing, cache_path)
}

# tokens in relation to each other ----------------------------------------

## these functions have no knowledge of how tokens are stored on disk
## they work with a candidate token and a list of existing tokens
token_match <- function(candidate, existing) {
  "!DEBUG in token_match"
  m <- token_hash_match(candidate, existing)
  if (!is.na(m)) {
    "!DEBUG match found on full hash"
    return(existing[[m]])
  }
  "!DEBUG no match on full hash"

  if (!is.null(candidate$email)) {
    "!DEBUG email specified, so can't match on short hash"
    return()
  }

  m <- token_hash_short_match(candidate, existing)

  if (length(m) == 0 || is.na(m)) {
    "!DEBUG no match on short hash"
    return()
  }

  if (length(existing) == 1) {
    "!DEBUG unique match on short hash"
    return(existing[[m]])
  }

  if (!interactive() || is_testing()) {
    stop("Multiple cached tokens exist. Unclear which to use.", call. = FALSE)
  }

  existing <- existing[m]
  emails <- vapply(existing, function(x) x$email, character(1))
  cat("Multiple cached tokens are available.\n")
  cat("Pick the account you wish to use or enter '0' to obtain a new token.")
  this_one <- utils::menu(emails)

  if (this_one == 0) return()

  existing[[this_one]]
}

token_hash_match <- function(candidate, existing) {
  "!DEBUG candidate hash = `candidate$hash()`"
  "!DEBUG existing hashes = `names(existing)`"
  match2(candidate$hash(), names(existing))
}

token_hash_short_match <- function(candidate, existing) {
  "!DEBUG candidate short hash = `mask_email(candidate$hash())`"
  "!DEBUG existing short hashes = `mask_email(names(existing))`"
  match2(mask_email(candidate$hash()), mask_email(names(existing)))
}

token_upsert <- function(candidate, existing) {
  "!DEBUG token_upsert"
  m <- match2(candidate$hash(), names(existing))
  if (!is.na(m) && length(m) > 0) {
    existing[[m]] <- NULL
  }

  m <- length(existing) + 1
  existing[[m]] <- candidate
  names(existing)[[m]] <- candidate$hash()
  existing
}

## for this token hash:
## 2a46e6750476326f7085ebdab4ad103d_jenny@rstudio.com
## ^  mask_email() returns this   ^ ^ extract_email() returns this ^
mask_email    <- function(x) sub("^([0-9a-f]+)_.*", "\\1", x)

## match() but return location of all matches
match2 <- function(needle, haystack) {
  matches <- which(haystack == needle)
  if (length(matches) == 0) {
    matches <- NA
  }
  matches
}

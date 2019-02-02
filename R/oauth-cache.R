## this file has its origins in oauth-cache.R in httr
## nothing there is exported, so copied over, then it evolved

# cache --------------------------------------------------------------

gargle_default_oauth_cache_path <- function() {
  path_home(".R", "gargle", "gargle-oauth")
}

## this is the cache setup interface for the Gargle2.0 class
cache_establish <- function(cache = getOption("gargle.oauth_cache")) {
  if (length(cache) != 1) {
    stop_glue("{bt('cache')} must have length 1, not {length(cache)}.")
  }
  if (!is.logical(cache) && !is.character(cache)) {
    stop_glue_data(
      list(x = glue_collapse(class(cache), sep = "/")),
      "{bt('cache')} must be logical or character, not of class {sq(x)}."
    )
  }

  # If NA, consider default cache folder.
  # Request user's permission to create it, if doesn't exist yet.
  # Store outcome of this mission (TRUE or FALSE) in the option for the session.
  if (is.na(cache)) {
    cache <- cache_available(gargle_default_oauth_cache_path())
    options("gargle.oauth_cache" = cache)
  }
  ## cache is now TRUE, FALSE or path

  if (isFALSE(cache)) {
    return()
  }

  if (isTRUE(cache)) {
    cache <- gargle_default_oauth_cache_path()
  }
  ## cache is now a path

  if (!dir_exists(cache)) {
    cache_create(cache)
  }

  return(cache)
}

cache_available <- function(path) {
  dir_exists(path) || cache_allowed(path)
}

cache_allowed <- function(path) {
  if (!interactive()) {
    return(FALSE)
  }

  cat_glue(
    "Is it OK to cache OAuth access credentials in the folder {sq(path)} ",
    "between R sessions?"
  )
  utils::menu(c("Yes", "No")) == 1
}

cache_create <- function(path) {
  ## owner (and only owner) can read, write, execute
  dir_create(path, recursive = TRUE, mode = "0700")
  "!DEBUG cache exists: `path`"

  cache_parent <- path_dir(path)
  desc <- path(cache_parent, "DESCRIPTION")
  if (file_exists(desc)) {
    add_line(
      path(cache_parent, ".Rbuildignore"),
      paste0("^", gsub("\\.", "\\\\.", path), "$")
    )
  }
  git <- path(cache_parent, c(".gitignore", ".git"))
  if (any(file_exists(git))) {
    add_line(
      path(cache_parent, ".gitignore"),
      path
    )
  }

  TRUE
}

cache_ls <- function(path) {
  files <- as.character(dir_ls(path))
  files <- hash_paths(files)
  names(files) <- path_file(files)

  tokens <- lapply(files, readRDS)
  validate_token_list(tokens)
  names(tokens)
}

validate_token_list <- function(tokens) {
  hashes <- vapply(tokens, function(x) x$hash(), character(1), USE.NAMES = FALSE)
  nms <- names(tokens)

  if (!identical(nms, hashes)) {
    mismatches <- nms != hashes
    msg <- c(
      "Cache contains tokens with names that do not match their hash:",
      glue("
        * Token stored as {sq(nms[mismatches])}
              but hash is {sq(hashes[mismatches])}
      ")
    )
    stop_collapse(msg)
  }

  if (anyDuplicated(nms)) {
    dupes <- unique(nms[duplicated(nms)])
    msg <- c(
      "Cache contains duplicated tokens:",
      paste0("* ", dupes)
    )
    stop_collapse(msg)
  }

  tokens
}

## useful to jennybc during development
cache_show <- function(path = NULL) { # nocov start
  path <- path %||% getOption("gargle.oauth_cache")
  if (is.null(path) || is.na(path) || isTRUE(path)) {
    path <- gargle_default_oauth_cache_path()
  }
  if (!file_exists(path)) {
    message("No cache found.")
    return()
  }
  if (file_is_empty(path)) {
    message("Cache is empty.")
    return(list())
  }
  message("Reading from cache in '", path, "'")
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
  existing <- cache_ls(cache_path)
  this_one <- token_match(candidate$hash(), existing)
  if (is.null(this_one)) {
    NULL
  } else {
    readRDS(path(cache_path, this_one))
  }
}

token_into_cache <- function(candidate) {
  "!DEBUG in token_into_cache"
  cache_path <- candidate$cache_path

  if (is.null(cache_path)) {
    "!DEBUG in token_into_cache, but there is no cache"
    return()
  }

  "!DEBUG in token_into_cache, writing"
  saveRDS(candidate, path(cache_path, candidate$hash()))
}

# helpers to compare tokens based on SHORTHASH_EMAIL ------------------------
token_match <- function(candidate, existing) {
  if (length(existing) == 0) {
    return()
  }

  candidate_email <- extract_email(candidate)
  ## examples of possible values:
  ## 'blah@example.org' an actual email
  ## '*'                permission to use an email we find in the cache
  ## ''                 no email and no instructions

  ## if we have no instructions, we need user permission to consult the cache
  if (empty_string(candidate_email) && !interactive()) {
    return()
  }

  m <- match2(candidate, existing)
  if (!is.na(m)) {
    return(existing[[m]])
  }

  ## if email was specified and no full match, we're done
  if (!empty_string(candidate_email) && candidate_email != "*") {
    return()
  }
  ## possible scenarios:
  ## candidate_email is '*'
  ## candidate_email is '' and session is interactive

  ## match on the short hash
  m <- match2(mask_email(candidate), mask_email(existing))
  if (anyNA(m)) {
    return()
  }
  existing <- existing[m]

  if (length(existing) == 1 && candidate_email == "*") {
    message_glue("Using a cached token for {extract_email(existing)}.")
    return(existing)
  }
  ## we need user to OK our discovery or pick from multiple emails

  if (!interactive()) {
    stop_glue(
      "Suitable cached tokens exist, but user confirmation is required."
    )
  }

  emails <- extract_email(existing)
  cat_glue(
    "The PACKAGE package is requesting access to your Google account.",
    "Select a pre-authorised account or enter '0' to obtain a new token.",
    "Press Esc/Ctrl + C to abort."
  )
  choice <- utils::menu(emails)

  if (choice == 0) {
    NULL
  } else {
    existing[[choice]]
  }
}

## for this token hash:
## 2a46e6750476326f7085ebdab4ad103d_jenny@rstudio.com
## ^  mask_email() returns this   ^ ^ extract_email() returns this ^
hash_regex <- "^([0-9a-f]+)_(.*?)$"
mask_email    <- function(x) sub(hash_regex, "\\1", x)
extract_email <- function(x) sub(hash_regex, "\\2", x)
hash_paths <- function(x) x[grep(hash_regex, path_file(x))]

## match() but return location of all matches
match2 <- function(needle, haystack) {
  matches <- which(haystack == needle)
  if (length(matches) == 0) {
    matches <- NA
  }
  matches
}

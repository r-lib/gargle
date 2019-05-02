## this file has its origins in oauth-cache.R in httr
## nothing there is exported, so copied over, then it evolved

# cache setup, loading, validation --------------------------------------------

gargle_default_oauth_cache_path <- function() {
  path_home(".R", "gargle", "gargle-oauth")
}

## this is the cache setup interface for the Gargle2.0 class
## returns NULL or cache path
cache_establish <- function(cache = NULL) {
  cache <- cache %||% getOption("gargle.oauth_cache")
  if (length(cache) != 1) {
    stop_glue("{bt('cache')} must have length 1, not {length(cache)}.")
  }
  if (!is.logical(cache) && !is.character(cache)) {
    bad_class <- glue_collapse(class(cache), sep = "/")
    stop_glue(
      "{bt('cache')} must be logical or character, not of class {sq(bad_class)}."
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

  cat_line(glue(
    "Is it OK to cache OAuth access credentials in the folder {sq(path)} ",
    "between R sessions?"
  ))
  utils::menu(c("Yes", "No")) == 1
}

cache_create <- function(path) {
  ## owner (and only owner) can read, write, execute
  dir_create(path, recursive = TRUE, mode = "0700")

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
  names(cache_load(path))
}

cache_load <- function(path) {
  files <- as.character(dir_ls(path))
  files <- hash_paths(files)
  names(files) <- path_file(files)
  tokens <- map(files, readRDS)
  validate_token_list(tokens)
}

validate_token_list <- function(tokens) {
  hashes <- unname(map_chr(tokens, function(t) t$hash()))
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
    msg <- glue_collapse(msg, sep = "\n")
    stop_glue(msg)
  }

  if (anyDuplicated(nms)) {
    dupes <- unique(nms[duplicated(nms)])
    msg <- c(
      "Cache contains duplicated tokens:",
      paste0("* ", dupes)
    )
    msg <- glue_collapse(msg, sep = "\n")
    stop_glue(msg)
  }

  tokens
}

# retrieve and insert tokens from cache -----------------------------------

## these two functions provide the "current token <--> token cache" interface
## for the Gargle2.0 class
token_from_cache <- function(candidate) {
  cache_path <- candidate$cache_path

  if (is.null(cache_path)) {
    return()
  }

  existing <- cache_ls(cache_path)
  this_one <- token_match(candidate$hash(), existing, package = candidate$package)
  if (is.null(this_one)) {
    NULL
  } else {
    readRDS(path(cache_path, this_one))
  }
}

token_into_cache <- function(candidate) {
  cache_path <- candidate$cache_path
  if (is.null(cache_path)) {
    return()
  }
  saveRDS(candidate, path(cache_path, candidate$hash()))
}

# helpers to compare tokens based on SHORTHASH_EMAIL ------------------------
token_match <- function(candidate, existing, package = "gargle") {
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
    cat_line(glue(
      "The {package} package is using a cached token for {extract_email(existing)}."
    ))
    return(existing)
  }
  ## we need user to OK our discovery or pick from multiple emails

  if (!interactive()) {
    stop_glue(
      "Suitable cached tokens exist, but user confirmation is required."
    )
  }

  emails <- extract_email(existing)
  cat_line(glue(
    "The {package} package is requesting access to your Google account. ",
    "Select a pre-authorised account or enter '0' to obtain a new token. ",
    "Press Esc/Ctrl + C to abort."
  ))
  choice <- utils::menu(emails)

  if (choice == 0) {
    NULL
  } else {
    existing[[choice]]
  }
}

## for this token hash:
## 2a46e6750476326f7085ebdab4ad103d_jenny@example.org
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


# gargle situation report -------------------------------------------------

#' OAuth token situation report
#'
#' Get a human-oriented overview of the existing gargle OAuth tokens:
#'   * Filepath of the current cache
#'   * Number of tokens found there
#'   * Compact summary of the associated
#'     - Email = Google identity
#'     - OAuth app (actually, just its nickname)
#'     - Scopes
#'     - Hash (actually, just the first 7 characters)
#' Mostly useful for the development of gargle and client packages.
#'
#' @inheritParams gargle2.0_token
#'
#' @return A data frame with one row per cached token, invisibly.
#' @export
#'
#' @examples
#' gargle_oauth_sitrep()
gargle_oauth_sitrep <- function(cache = NULL) {
  withr::local_options(list(gargle_quiet = FALSE))
  withr::with_options(
    # I do not want to actively trigger cache establishment
    list(rlang_interactive = FALSE),
    path <- cache_establish(cache)
  )
  if (is.null(path)) {
    cat_line("No gargle OAuth cache has been established.")
    return(invisible())
  }

  cat_line("gargle OAuth cache path:")
  cat_line(path)
  cat_line()
  tokens <- cache_load(path)
  cat_line(glue("{length(tokens)} tokens found"))
  cat_line()

  nms    <- names(tokens)
  hash   <- mask_email(nms)
  email  <- extract_email(nms)
  app    <- map_chr(tokens, function(t) t$app$appname)
  scopes <- map(tokens, function(t) t$params$scope)
  email_scope <- "https://www.googleapis.com/auth/userinfo.email"
  scopes <- map(scopes, function(s) s[s != email_scope])
  scopes <- map_chr(scopes, function(s) commapse(base_scope(s)))

  df <- data.frame(
    email, app, scopes, hash, hash... = obfuscate(hash, first = 7, last = 0),
    stringsAsFactors = FALSE, row.names = NULL
  )

  format_transformer <- function(text, envir) {
    res <- eval(parse(text = text, keep.source = FALSE), envir)
    res <- format(c(text, res))
    c(
      res[1],
      # R 3.2 does not have strrep()
      paste(rep.int("_", nchar(res[1])), collapse = ""),
      res[-1]
    )
  }

  cat_line(glue_data(
    df,
    "{email} {app} {scopes} {hash...}",
    .transformer = format_transformer
  ))

  df$hash... <- NULL
  invisible(df)
}

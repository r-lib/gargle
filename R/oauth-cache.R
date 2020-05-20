## this file has its origins in oauth-cache.R in httr
## nothing there is exported, so copied over, then it evolved

# cache setup, loading, validation --------------------------------------------

gargle_default_oauth_cache_path <- function() {
  path_home(".R", "gargle", "gargle-oauth")
}

## this is the cache setup interface for the Gargle2.0 class
## returns NULL or cache path
cache_establish <- function(cache = NULL) {
  cache <- cache %||% gargle_oauth_cache()
  if (length(cache) != 1) {
    abort(glue("{bt('cache')} must have length 1, not {length(cache)}."))
  }
  if (!is.logical(cache) && !is.character(cache)) {
    stop_bad_class(cache, c("logical", "character"))
  }

  # If NA, consider default cache folder.
  # Request user's permission to create it, if doesn't exist yet.
  # Store outcome of this mission (TRUE or FALSE) in the option for the session.
  if (is.na(cache)) {
    cache <- cache_available(gargle_default_oauth_cache_path())
    options("gargle_oauth_cache" = cache)
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
  if (!is_interactive()) {
    return(FALSE)
  }

  withr::local_options(list(gargle_quiet = FALSE))
  ui_line(glue(
    "Is it OK to cache OAuth access credentials in the folder {sq(path)} ",
    "between R sessions?"
  ))
  utils::menu(c("Yes", "No")) == 1
}

cache_create <- function(path) {
  ## owner (and only owner) can read, write, execute
  dir_create(path, recurse = TRUE, mode = "0700")

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
  files <- keep_hash_paths(files)
  names(files) <- path_file(files)
  tokens <- map(files, readRDS)

  hashes <- map_chr(tokens, function(t) t$hash())

  mismatch <- names(hashes) != hashes

  if (any(mismatch)) {
    # we've seen this with tokens cached on R 3.5 but reloaded on 3.6
    # because $hash() calls serialize() and default version changed
    msg <- c(
      "Cache contains tokens with names that do not match their hash:",
      glue("
        * Token stored as {sq(names(hashes)[mismatch])}
              but hash is {sq(hashes[mismatch])}
      "),
      "Will attempt to repair by renaming."
    )
    ui_line(msg)
    file_move(files[mismatch], path(path, hashes[mismatch]))
    Recall(path)
  } else {
    tokens
  }
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
    ui_line("not caching token")
    return()
  }
  ui_line("putting token into the cache: ", cache_path)
  saveRDS(candidate, path(cache_path, candidate$hash()))
}

token_remove_from_cache <- function(candidate) {
  cache_path <- candidate$cache_path
  if (is.null(cache_path)) return()
  token_path <- path(cache_path, candidate$hash())
  ui_line("removing token from the cache: ", token_path)
  file_delete(token_path)
}

# helpers to compare tokens based on SHORTHASH_EMAIL ------------------------
token_match <- function(candidate, existing, package = "gargle") {
  if (length(existing) == 0) {
    return()
  }

  m <- match2(candidate, existing)
  if (!is.na(m)) {
    stopifnot(length(m) == 1)
    return(existing[[m]])
  }
  # there is no full match

  candidate_email <- extract_email(candidate)
  # possible values    what they mean
  # ------------------ ---------------------------------------------------------
  # 'blah@example.org' user specified an email
  # '*'                `email = TRUE`, i.e. permission to use *one* that we find
  #                    (we still scold for multiple matches)
  # ''                 user gave no email and no instructions

  # if email was specified, we're done
  if (!empty_string(candidate_email) && candidate_email != "*") {
    return()
  }
  # candidate_email is either '*' or ''

  # match on the short hash
  m <- match2(mask_email(candidate), mask_email(existing))

  # if no match on short hash, we're done
  if (anyNA(m)) {
    return()
  }
  existing <- existing[m]
  # existing holds at least one short hash match

  if (!is_interactive()) {
    # proceed, but make sure user sees messaging about how to do
    # non-interactive auth more properly
    # https://github.com/r-lib/gargle/issues/92
    withr::local_options(list(gargle_quiet = FALSE))
    candidate_email <- "*"
    if (length(existing) > 1) {
      emails <- extract_email(existing)
      emails <- glue("  * {emails}")
      ui_line(glue(
        "Suitable tokens found in the cache, associated with these emails:\n",
        "{glue_collapse(emails, sep = '\n')}", "\n",
        "The first will be used."
      ))
      existing <- existing[[1]]
    }
    msg <- c(
      "Using an auto-discovered, cached token.\n",
      "To suppress this message, modify your code or options to clearly ",
      "consent to the use of a cached token.\n",
      "See gargle's \"Non-interactive auth\" vignette for more details:\n",
      "https://gargle.r-lib.org/articles/non-interactive-auth.html"
    )
    msg <- glue_collapse(msg)
    # morally, I'd like to throw a warning but current design of token_fetch()
    # means warnings are caught
    ui_line(msg)
  }

  if (length(existing) == 1 && candidate_email == "*") {
    ui_line(glue(
      "The {package} package is using a cached token for {extract_email(existing)}."
    ))
    return(existing)
  }

  # we need user to OK our discovery or pick from multiple emails
  withr::local_options(list(gargle_quiet = FALSE))
  emails <- extract_email(existing)
  ui_line(glue(
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
keep_hash_paths <- function(x) x[grep(hash_regex, path_file(x))]

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
    ui_line("No gargle OAuth cache has been established.")
    return(invisible())
  }

  ui_line("gargle OAuth cache path:")
  ui_line(path)
  ui_line()
  tokens <- cache_load(path)
  ui_line(glue("{length(tokens)} tokens found"))
  ui_line()

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

  ui_line(glue_data(
    df,
    "{email} {app} {scopes} {hash...}",
    .transformer = format_transformer
  ))

  df$hash... <- NULL
  invisible(df)
}

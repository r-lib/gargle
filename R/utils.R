is_string <- function(x) is.character(x) && length(x) == 1

empty_string <- function(x) {
  stopifnot(is.character(x))
  !nzchar(x)
}

is_windows <- function() {
  tolower(Sys.info()[["sysname"]]) == "windows"
}

file_is_empty <- function(path) {
  stopifnot(is_string(path))
  file.info(path)$size == 0
}

isFALSE <- function(x) identical(x, FALSE)

isNA <- function(x) length(x) == 1 && is.na(x)

is.oauth_app <- function(x) inherits(x, "oauth_app")

is.oauth_endpoint <- function(x) inherits(x, "oauth_endpoint")

add_line <- function(path, line, quiet = FALSE) {
  if (file_exists(path)) {
    lines <- readLines(path, warn = FALSE)
    lines <- lines[lines != ""]
  } else {
    lines <- character()
  }

  if (line %in% lines) return(TRUE)
  if (!quiet) message("Adding ", line, " to ", path)

  lines <- c(lines, line)
  writeLines(lines, path)
  TRUE
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

## this function can be replaced by rlang::is_interactive()
## if this gets merged + released
## https://github.com/r-lib/rlang/pull/761
interactive <- function() {
  rlang::is_interactive() && !is_testing()
}

## in the spirit of basename(), but for Google scopes
## for printing purposes
base_scope <- function(x) {
  gsub("/$", "", gsub("(.*)/(.+$)", "...\\2", x))
}

normalize_scopes <- function(x) {
  stats::setNames(sort(unique(x)), NULL)
}

add_email_scope <- function(scopes = NULL) {
  url <- "https://www.googleapis.com/auth/userinfo.email"
  union(scopes %||% character(), url)
}

#' An expose object
#'
#' `expose()` returns a sentinel object, similar in spirit to `NULL`, that tells
#' the calling function to return its internal data source. Client packages such
#' as googledrive and googlesheets4 store information internally about the
#' target API, such as Drive file MIME types, and then expose this via helper
#' functions, like `googledrive::drive_mime_type()` and
#' `googlesheets4::sheets_endpoints()`. These internal objects are used to
#' provide nice defaults, check input validity, or lookup something cryptic,
#' like MIME type, based on something friendlier, like a file extension. Pass
#' `expose()` to such a function to see the internal object, in its full glory.
#' This is inspired by the `waiver()` object in ggplot2.
#'
#' @param x An object that might be an `expose` object.
#'
#' @name expose
#' @examples
#' \dontrun{
#' googledrive::drive_mime_type(expose())
#' googledrive::drive_fields(expose())
#'
#' is_expose(expose())
#' is_expose("nope")
#' }
#'
#' @export
#' @rdname expose
expose <- function() structure(list(), class = "expose")

#' @export
#' @rdname expose
is_expose <- function(x) inherits(x, "expose")

"%||%" <- function(a, b) {
  if (length(a) > 0) a else b
}

#' @importFrom glue glue glue_data glue_collapse
#' @importFrom magrittr %>%
NULL

is_string <- function(x) is.character(x) && length(x) == 1

commapse <- function(...) paste0(..., collapse = ", ")

cat_line <- function(...) cat(paste0(..., "\n"), sep = "")

bt <- function(x) encodeString(x, quote = "`")

stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                           call. = FALSE, .domain = NULL) {
  stop(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_collapse <- function(x) stop(glue_collapse(x, sep = "\n"), call. = FALSE)

warning_glue <- function(..., .sep = "", .envir = parent.frame(),
                         call. = FALSE, .domain = NULL) {
  warning(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              call. = FALSE, .domain = NULL) {
  warning(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

warning_collapse <- function(x) warning(glue_collapse(x, sep = "\n"))

message_glue <- function(..., .sep = "", .envir = parent.frame(),
                         .domain = NULL, .appendLF = TRUE) {
  message(
    glue(..., .sep = .sep, .envir = .envir),
    domain = .domain, appendLF = .appendLF
  )
}

message_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                              .domain = NULL) {
  message(
    glue_data(..., .sep = .sep, .envir = .envir),
    domain = .domain
  )
}

message_collapse <- function(x) message(glue_collapse(x, sep = "\n"))

isFALSE <- function(x) identical(x, FALSE)

is.oauth_app <- function(x) inherits(x, "oauth_app")

is.oauth_endpoint <- function(x) inherits(x, "oauth_endpoint")

add_line <- function(path, line, quiet = FALSE) {
  if (file.exists(path)) {
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

rhash <- function(obj) {
  # first 14 bytes are serialization header
  # skip them to allow hash comparison "across platforms and some R versions"
  # see digest::digest() help and source for more background
  msg <- serialize(obj, connection = NULL, ascii = FALSE)[-(1:14)]
  paste(openssl::md5(msg), collapse = "")
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

## in the spirit of basename(), but for Google scopes
## for printing purposes
base_scope <- function(x) {
  gsub("/$", "", gsub("(.*)/(.+$)", "...\\2", x))
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

#' @export
#' @rdname expose
expose <- function() structure(list(), class = "expose")

#' @export
#' @rdname expose
is_expose <- function(x) inherits(x, "expose")

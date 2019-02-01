"%||%" <- function(a, b) {
  if (length(a) > 0) a else b
}

is_string <- function(x) is.character(x) && length(x) == 1

commapse <- function(...) paste0(..., collapse = ", ")

cat_line <- function(...) cat(paste0(..., "\n"), sep = "")

bt <- function(x) encodeString(x, quote = "`")
sq <- function(x) encodeString(x, quote = "'")

is_windows <- function() {
  tolower(Sys.info()[["sysname"]]) == "windows"
}

file_is_empty <- function(path) {
  stopifnot(is_string(path))
  file.info(path)$size == 0
}

## obscure the middle bit of (sensitive?) strings with '...'
## obfuscate("sensitive", first = 3, last = 2) = "sen...ve"
obfuscate <- function(x, first = 6, last = 4) {
  nc <- nchar(x)
  ellipsize <- nc > first + last
  out <- x
  out[ellipsize] <-
    paste0(
      substr(x[ellipsize], start = 1, stop = first),
      "...",
      substr(x[ellipsize],
        start = nc[ellipsize] - last + 1,
        stop = nc[ellipsize]
      )
    )
  out
}

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

interactive <- function() {
  base::interactive() && !is_testing()
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
#'
#' @export
#' @rdname expose
expose <- function() structure(list(), class = "expose")

#' @export
#' @rdname expose
is_expose <- function(x) inherits(x, "expose")

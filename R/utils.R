"%||%" <- function(a, b) {
  if (length(a) > 0) a else b
}

#' @importFrom magrittr %>%
NULL

is_string <- function(x) is.character(x) && length(x) == 1

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

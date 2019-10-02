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
  cat_line("Adding ", line, " to ", path)

  lines <- c(lines, line)
  writeLines(lines, path)
  TRUE
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
  cat_line("adding 'userinfo.email' scope")
  url <- "https://www.googleapis.com/auth/userinfo.email"
  union(scopes %||% character(), url)
}

new_srcref <- function(lines) {
  n <- length(lines)

  srcref(
    srcfilecopy("HIDDEN", lines),
    c(1L, 1L, n, nchar(lines[[n]]))
  )
}

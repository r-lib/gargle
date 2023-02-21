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

is.oauth_app <- function(x) inherits(x, "oauth_app")

is.oauth_endpoint <- function(x) inherits(x, "oauth_endpoint")

is_rstudio_server <- function() {
  Sys.getenv("RSTUDIO") == "1" &&
    Sys.getenv("RSTUDIO_PROGRAM_MODE") == "server"
}

is_google_colab <- function() {
  # idea from https://stackoverflow.com/a/74930276
  # 2023-02-21 I created new notebook with
  # https://colab.research.google.com/#create=true&language=r
  # and I see:
  # Sys.getenv("COLAB_RELEASE_TAG") returns 'release-colab-20230216-060056-RC01'
  nzchar(Sys.getenv("COLAB_RELEASE_TAG"))
}

add_line <- function(path, line) {
  if (file_exists(path)) {
    lines <- readLines(path, warn = FALSE)
    lines <- lines[lines != ""]
  } else {
    lines <- character()
  }

  if (line %in% lines) {
    return(TRUE)
  }

  gargle_info("Adding {.val {line}} to {.file {path}}.")
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
  gargle_debug("adding {.val userinfo.email} scope")
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

empty_string <- function(x) {
  check_string(x)
  !nzchar(x)
}

is_windows <- function() {
  tolower(Sys.info()[["sysname"]]) == "windows"
}

is.oauth_app <- function(x) inherits(x, "oauth_app")

is.oauth_endpoint <- function(x) inherits(x, "oauth_endpoint")

# meant to evoke "RStudio, on a server", which includes RStudio Server and
# Posit Workbench
is_rstudio_server <- function() {
  Sys.getenv("RSTUDIO") == "1" &&
    Sys.getenv("RSTUDIO_PROGRAM_MODE") == "server"
}

is_positron <- function() {
  identical(Sys.getenv("POSITRON"), "1")
}

# meant to evoke "Positron, on a server", not Positron Server,
# which does not exist
is_positron_server <- function() {
  is_positron() &&
    # yes, it really is RSTUDIO_PROGRAM_MODE vs. POSITRON_MODE
    Sys.getenv("POSITRON_MODE") == "server"
}

# intended to detect execution on RStudio Server or Posit Workbench
# mostly aimed at detecting R use via VS Code on a server,
# since use via RStudio or Positron should be picked up by more specialized
# helpers: is_(rstudio|positron)_server()
is_workbench <- function() {
  # values seen on Workbench for RS_SERVER_URL in 2025-08-29 experimentation
  # VS Code, R in a terminal: "https://dev.palm.ptd.posit.it/"
  # Positron Pro, R Console and R in terminal: "https://dev.palm.ptd.posit.it/"
  # RStudio Pro, R Console and R in terminal: ""
  # yes, on RStudio Pro, RS_SERVER_URL is intentionally(?) set to the empty
  # string, but it IS set
  !is.na(Sys.getenv("RS_SERVER_URL", unset = NA_character_))
}

is_google_colab <- function() {
  # idea from https://stackoverflow.com/a/74930276
  # 2023-02-21 I created new notebook with
  # https://colab.research.google.com/#create=true&language=r
  # and I see:
  # Sys.getenv("COLAB_RELEASE_TAG") returns 'release-colab-20230216-060056-RC01'
  #
  # https://github.com/r-lib/gargle/issues/140#issuecomment-1439111627
  # via @craigcitro, the existence of this directory is another indicator:
  # /var/colab/hostname
  nzchar(Sys.getenv("COLAB_RELEASE_TAG"))
}

is_hosted_session <- function() {
  is_rstudio_server() ||
    is_positron_server() ||
    is_workbench() ||
    is_google_colab()
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

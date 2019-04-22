# All UI output must eventually go through cat_line() so that it
# can be silenced / activated with 'gargle_quiet'.
cat_line <- function(..., quiet = getOption("gargle_quiet", default = TRUE)) {
  if (quiet) {
    return(invisible())
  }

  lines <- paste0(..., "\n")
  cat(lines, sep = "")
}

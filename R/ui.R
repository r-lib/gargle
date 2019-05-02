#' @rdname gargle-options
#' @export
#' @section `gargle_quiet`:
#' `gargle_quiet()` returns the option named "gargle_quiet", which defaults to
#' `TRUE`. Set this option to `FALSE` to see more info about gargle's
#' activities, which can be helpful for troubleshooting.
gargle_quiet <- function() {
  getOption("gargle_quiet", default = TRUE)
}

# All UI output must eventually go through cat_line() so that it
# can be silenced / activated with 'gargle_quiet'.
cat_line <- function(..., quiet = gargle_quiet()) {
  if (quiet) {
    return(invisible())
  }

  lines <- paste0(..., "\n")
  cat(lines, sep = "")
}

cat_glue <- function(..., .sep = "", .envir = parent.frame()) {
  cat(glue(..., .sep = .sep, .envir = .envir), sep = "\n")
}

cat_glue_data <- function(..., .sep = "", .envir = parent.frame()) {
  cat(glue_data(..., .sep = .sep, .envir = .envir), sep = "\n")
}

commapse <- function(...) paste0(..., collapse = ", ")
bt <- function(x) encodeString(x, quote = "`")
sq <- function(x) encodeString(x, quote = "'")

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

glue_lines <- function(lines, ..., .env = parent.frame()) {
  # eliminate confusion re: `...` of glue_lines() vs. `...` of map_chr()
  g <- function(line) glue(line, ..., .envir = .env)
  map_chr(lines, g)
}

glue_data_lines <- function(.data, lines, ..., .env = parent.frame()) {
  # work around name collision of `.x` of map_chr() vs. of glue_data()
  # and confusion re: `...` of glue_data_lines() vs. `...` of map_chr()
  gd <- function(line) glue_data(.x = .data, line, ..., .envir = .env)
  map_chr(lines, gd)
}

#' @rdname gargle_options
#' @export
#' @section `gargle_verbosity`:
#' `gargle_verbosity()` returns the option named "gargle_verbosity", which
#' determines gargle's verbosity. There are three possible values, inspired by
#' the logging levels of log4j:
#' * "debug": Fine-grained information helpful when debugging, e.g. figuring out
#'   how `token_fetch()` is working through the registry of credential
#'   functions. Previously, this was activated by setting an option named
#'   "gargle_quiet" to `FALSE`.
#' * "info" (default): High-level information that a typical user needs to see.
#'   Since typical gargle usage is always indirect, i.e. gargle is called by
#'   another package, gargle itself is very quiet. There are very few messages
#'   emitted when `gargle_verbosity = "info"`.
#' * "silent": No messages at all. However, warnings or errors are still thrown
#'   normally.
gargle_verbosity <- function() {
  gv <- getOption("gargle_verbosity")

  # help people using the previous option
  if (is.null(gv)) {
    gq <- getOption("gargle_quiet")
    if (is_false(gq)) {
      options(gargle_verbosity = "debug")
      with_gargle_verbosity(
        "debug",
        gargle_debug(c(
          "Option {.val gargle_quiet} is deprecated in favor of \\
          {.val gargle_verbosity}",
          "Instead of: {.code options(gargle_quiet = FALSE)}",
          'Now do: {.code options(gargle_verbosity = "debug")}'
        ))
      )
    }
  }
  gv <- getOption("gargle_verbosity", "info")

  vals <- c("debug", "info", "silent")
  vals_fmt <- glue_collapse(sq(vals), sep = ", ")
  if (!is_string(gv) || !(gv %in% vals)) {
    abort(glue('
      Option "gargle_verbosity" must be one of: {vals_fmt}'))
  }
  gv
}

#' @rdname gargle_options
#' @export
gargle_quiet <- function() {
  getOption("gargle_quiet", default = TRUE)
}

# All UI output must eventually go through ui_line() so that it
# can be silenced / activated with 'gargle_quiet'.
ui_line <- function(..., quiet = gargle_quiet()) {
  if (!quiet) {
    inform(paste0(...))
  }

  invisible()
}

glue_lines <- function(lines, ..., .env = parent.frame()) {
  # eliminate confusion re: `...` of glue_lines() vs. `...` of map_chr()
  # plus: I've only got compat-purrr here, so I have to write a function
  g <- function(line) glue(line, ..., .envir = .env)
  map_chr(lines, g)
}

glue_data_lines <- function(.data, lines, ..., .env = parent.frame()) {
  # work around name collision of `.x` of map_chr() vs. of glue_data()
  # and confusion re: `...` of glue_data_lines() vs. `...` of map_chr()
  # plus: I've only got compat-purrr here, so I have to write a function
  gd <- function(line) glue_data(.x = .data, line, ..., .envir = .env)
  map_chr(lines, gd)
}

# inspired by
# https://github.com/rundel/ghclass/blob/6ed836c0e3750b4bfd1386c21b28b91fd7e24b4a/R/util_cli.R#L1-L7
# more discussion at
# https://github.com/r-lib/cli/issues/222
cli_format = function(..., .envir = parent.frame()) {
  txt <- cli::cli_format_method(cli::cli_text(..., .envir = .envir))
  # @rundel does this to undo wrapping done by cli_format_method()
  # I haven't had this need yet
  # paste(txt, collapse = " ")
  txt
}

commapse <- function(...) paste0(..., collapse = ", ")
bt <- function(x) encodeString(x, quote = "`")
sq <- function(x) encodeString(x, quote = "'")
fr <- function(x) format(x, justify = 'right')
fl <- function(x) format(x, justify = 'left')

## obscure part of (sensitive?) strings with '...'
## obfuscate("sensitive", first = 3, last = 2) = "sen...ve"
obfuscate <- function(x, first = 7, last = 0) {
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

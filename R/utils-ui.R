gargle_theme <- function() {
  list(
    span.field = list(transform = single_quote_if_no_color),
    # make the default bullet "regular" color, instead of explicitly colored
    # mostly motivated by consistency with googledrive, where the cumulative
    # use of color made me want to do this
    ".memo .memo-item-*" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::symbol$bullet, " ")
    )
  )
}

single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")
double_quote_if_no_color <- function(x) quote_if_no_color(x, '"')

quote_if_no_color <- function(x, quote = "'") {
  # TODO: if a better way appears in cli, use it
  # @gabor says: "if you want to have before and after for the no-color case
  # only, we can have a selector for that, such as:
  # span.field::no-color
  # (but, at the time I write this, cli does not support this yet)
  if (cli::num_ansi_colors() > 1) {
    x
  } else {
    paste0(quote, x, quote)
  }
}


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
          "!" = "Option {.val gargle_quiet} is deprecated in favor of \\
                 {.val gargle_verbosity}",
          "i" = "Instead of: {.code options(gargle_quiet = FALSE)}",
          " " = 'Now do: {.code options(gargle_verbosity = "debug")}'
        ))
      )
    }
  }
  gv <- getOption("gargle_verbosity", "info")

  vals <- c("debug", "info", "silent")
  if (!is_string(gv) || !(gv %in% vals)) {
    # ideally this would collapse with 'or' not 'and' but I'm going with it
    gargle_abort('Option "gargle_verbosity" must be one of: {.field {vals}}')
  }
  gv
}

#' @rdname gargle_options
#' @export
#' @param level Verbosity level: "debug" > "info" > "silent"
#' @param env The environment to use for scoping
local_gargle_verbosity <- function(level, env = parent.frame()) {
  withr::local_options(list(gargle_verbosity = level), .local_envir = env)
}

#' @rdname gargle_options
#' @export
#' @param code Code to execute with specified verbosity level
with_gargle_verbosity <- function(level, code) {
  withr::with_options(list(gargle_verbosity = level), code = code)
}

gargle_debug <- function(text, .envir = parent.frame()) {
  if (gargle_verbosity() == "debug") {
    cli::cli_div(theme = gargle_theme())
    cli::cli_bullets(text, .envir = .envir)
  }
}

gargle_info <- function(text, .envir = parent.frame()) {
  if (gargle_verbosity() %in% c("debug", "info")) {
    cli::cli_div(theme = gargle_theme())
    cli::cli_bullets(text, .envir = .envir)
  }
}

# inspired by
# https://github.com/rundel/ghclass/blob/6ed836c0e3750b4bfd1386c21b28b91fd7e24b4a/R/util_cli.R#L1-L7
# more discussion at
# https://github.com/r-lib/cli/issues/222
cli_this = function(..., .envir = parent.frame()) {
  txt <- cli::cli_format_method(cli::cli_text(..., .envir = .envir))
  # @rundel does this to undo wrapping done by cli_format_method()
  # I haven't had this need yet
  # paste(txt, collapse = " ")
  txt
}

commapse <- function(...) paste0(..., collapse = ", ")
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

message <- function(...) {
  gargle_abort("
    Internal error: use {.pkg gargle}'s UI functions, not {.fun message}.")
}

#' Error conditions for the gargle package
#'
#' @param class Use only if you want to subclass beyond `gargle_error`
#'
#' @keywords internal
#' @name gargle-conditions
#' @noRd
NULL

gargle_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  cli::cli_div(theme = gargle_theme())
  cli::cli_abort(
    message,
    class = c(class, "gargle_error"),
    .envir = .envir,
    ...
  )
}

# my heart's not totally in this because I'm not sure we should really be
# throwing any warnings, however we currently do re: token refresh
# so this wrapper makes the messaging more humane
# I am declining to add a class, e.g. gargle_warning
gargle_warn <- function(message, ..., class = NULL, .envir = parent.frame()) {
  cli::cli_div(theme = gargle_theme())
  cli::cli_warn(message, .envir = .envir, ...)
}

gargle_abort_bad_class <- function(object, expected_class) {
  nm <- as_name(ensym(object))
  actual_class <- class(object)
  expected <- glue_collapse(
    gargle_map_cli(expected_class, template = "{.cls <<x>>}"),
    sep = ", ", last = " or "
  )
  msg <- glue("
    {.arg {nm}} must be <<expected>>, not of class {.cls {actual_class}}.",
    .open = "<<", .close =">>")
  gargle_abort(
    msg,
    class = "gargle_error_bad_class",
    object_name = nm,
    actual_class = actual_class,
    expected_class = expected_class
  )
}

gargle_abort_bad_params <- function(names, reason) {
  gargle_abort(
    c(
      "These parameters are {reason}:",
      bulletize(gargle_map_cli(names))
    ),
    class = "gargle_error_bad_params",
    names = names,
    reason = reason
  )
}

#' Map a cli-styled template over an object
#'
#' For internal use in gargle, googledrive, and googlesheets4 (for now).
#'
#' @keywords internal
#' @export
gargle_map_cli <- function(x, ...) UseMethod("gargle_map_cli")

#' @export
gargle_map_cli.default <- function(x, ...) {
  gargle_abort("
    Don't know how to {.fun gargle_map_cli} an object of class \\
    {.cls {class(x)}}.")
}

#' @export
gargle_map_cli.NULL <- function(x, ...) NULL

#' @export
gargle_map_cli.character <- function(x,
                                     template = "{.field <<x>>}",
                                     .open = "<<", .close = ">>",
                                     ...) {
  as.character(glue(template, .open = .open, .close = .close))
}

#' Abbreviate a bullet list neatly
#'
#' For internal use in gargle, googledrive, and googlesheets4 (for now).
#'
#' @keywords internal
#' @export
bulletize <- function(x, bullet = "*", n_show = 5, n_fudge = 2) {
  n <- length(x)
  n_show_actual <- compute_n_show(n, n_show, n_fudge)
  out <- utils::head(x, n_show_actual)
  n_not_shown <- n - n_show_actual

  out <- set_names(out, rep_along(out, bullet))

  if (n_not_shown == 0) {
    out
  } else {
    c(out, " " = glue("{cli::symbol$ellipsis} and {n_not_shown} more"))
  }
}

# I don't want to do "... and x more" if x is silly, i.e. 1 or 2
compute_n_show <- function(n, n_show_nominal = 5, n_fudge = 2) {
  if (n > n_show_nominal && n - n_show_nominal > n_fudge) {
    n_show_nominal
  } else {
    n
  }
}

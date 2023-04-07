gargle_theme <- function() {
  list(
    span.field = list(transform = single_quote_if_no_color),
    # make the default bullet "regular" color, instead of explicitly colored
    # mostly motivated by consistency with googledrive, where the cumulative
    # use of color made me want to do this
    ".bullets .bullet-*" = list(
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
    if (isFALSE(gq)) {
      options(gargle_verbosity = "debug")
      lifecycle::deprecate_warn(
        when = "1.1.0",
        what = I('The "gargle_quiet" option'),
        with = I('the "gargle_verbosity" option'),
        details = c(
          "x" = "Don't do this: `options(gargle_quiet = FALSE)`",
          "v" = 'Do this instead: `options(gargle_verbosity = "debug")`'
        ),
        always = TRUE
      )
    }
  }
  gv <- getOption("gargle_verbosity", "info")

  vals <- c("debug", "info", "silent")
  if (!is_string(gv) || !(gv %in% vals)) {
    gargle_abort(
      'Option "gargle_verbosity" must be one of: {.or {.field {vals}}}.'
    )
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

commapse <- function(...) paste0(..., collapse = ", ")
fr <- function(x) format(x, justify = "right")
fl <- function(x) format(x, justify = "left")

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

gargle_abort <- function(message, ...,
                         class = NULL,
                         .envir = parent.frame(),
                         call = caller_env()) {
  cli::cli_div(theme = gargle_theme())
  cli::cli_abort(
    message,
    class = c(class, "gargle_error"),
    .envir = .envir,
    call = call,
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

gargle_abort_bad_params <- function(names,
                                    reason,
                                    endpoint_id,
                                    call = caller_env()) {
  gargle_abort(
    c(
      "These parameters are {reason}:",
      bulletize(gargle_map_cli(names), bullet = "x"),
      "i" = gargle_map_cli(
        endpoint_id,
        template = "API endpoint: {.field <<x>>}"
      )
    ),
    class = "gargle_error_bad_params",
    call = call,
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

# menu(), but based on readline() + cli and mockable ---------------------------
# https://github.com/r-lib/cli/issues/228
# https://github.com/rstudio/rsconnect/blob/main/R/utils-cli.R

cli_menu <- function(header,
                     prompt,
                     choices,
                     not_interactive = choices,
                     exit = integer(),
                     .envir = caller_env(),
                     error_call = caller_env()) {
  if (!is_interactive()) {
    cli::cli_abort(
      c(header, not_interactive),
      .envir = .envir,
      call = error_call
    )
  }

  choices <- paste0(cli::style_bold(seq_along(choices)), ": ", choices)
  cli::cli_inform(
    c(header, prompt, choices),
    .envir = .envir
  )

  repeat {
    selected <- cli_readline("Selection: ")
    if (selected %in% c("0", seq_along(choices))) {
      break
    }
    cli::cli_inform(
      "Enter a number between 1 and {length(choices)}, or enter 0 to exit."
    )
  }

  selected <- as.integer(selected)
  if (selected %in% c(0, exit)) {
    if (is_testing()) {
      cli::cli_abort("Exiting...", call = NULL)
    } else {
      cli::cli_alert_danger("Exiting...")
      # simulate user pressing Ctrl + C
      invokeRestart("abort")
    }
  }

  selected
}

cli_readline <- function(prompt) {
  local_input <- getOption("cli_input", character())

  # not convinced that we need to plan for multiple mocked inputs, but leaving
  # this feature in for now
  if (length(local_input) > 0) {
    input <- local_input[[1]]
    cli::cli_inform(paste0(prompt, input))
    options(cli_input = local_input[-1])
    input
  } else {
    readline(prompt)
  }
}

local_user_input <- function(x, env = caller_env()) {
  withr::local_options(
    rlang_interactive = TRUE,
    # trailing 0 prevents infinite loop if x only contains invalid choices
    cli_input = c(x, "0"),
    .local_envir = env
  )
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

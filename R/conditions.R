#' Error conditions for the gargle package
#'
#' @param class Use only if you want to subclass beyond `gargle_error`
#'
#' @keywords internal
#' @name gargle-conditions
#' @noRd
NULL

gargle_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  g <- function(line) glue(line, .envir = .envir)
  msg <- map_chr(message, g)
  abort(msg, class = c(class, "gargle_error"), ...)
}

# my heart's not totally in this because I'm not sure we should really be
# throwing any warnings, however we currently do re: token refresh
# so this wrapper makes the messaging more humane
# I am declining to add a class, e.g. gargle_warning
gargle_warn <- function(message, ..., class = NULL, .envir = parent.frame()) {
  g <- function(line) glue(line, .envir = .envir)
  msg <- map_chr(message, g)
  warn(msg, ...)
}

gargle_abort_bad_class <- function(object, expected_class) {
  nm <- as_name(ensym(object))
  actual_class <- class(object)
  actual <- glue("<{glue_collapse(actual_class, sep = '/')}>")
  expected <- glue_collapse(glue("<{expected_class}>"), sep = ", ", last = " or ")
  gargle_abort(
    "{bt(nm)} must be {expected}, not of class {sq(actual)}",
    class = "gargle_error_bad_class",
    object_name = nm,
    actual_class = actual_class,
    expected_class = expected_class
  )
}

gargle_abort_bad_params <- function(names, reason) {
  # TODO: there's no way this is the best/right method of forming this message
  message <- glue_collapse(
    c(glue("These parameters are {reason}:"), names),
    sep = "\n"
  )
  gargle_abort(
    message,
    class = "gargle_error_bad_params",
    names = names,
    reason = reason
  )
}

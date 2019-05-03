stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_bad_class <- function(object, expected_class) {
  nm <- rlang::as_name(rlang::ensym(object))
  actual_class <- class(object)
  actual <- glue_collapse(actual_class, sep = "/")
  expected <- glue_collapse(expected_class, sep = ", ", last = " or ")
  message <- glue("{bt(nm)} must be {expected}, not of class {sq(actual)}.")
  abort(
    "gargle_error_bad_class",
    message = message,
    object_name = nm,
    actual_class = actual_class,
    expected_class = expected_class
  )
}

stop_need_user_interaction <- function(message) {
  abort(
    "gargle_error_need_user_interaction",
    message = message
  )
}

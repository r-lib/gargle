stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_bad_class <- function(object, expected_class) {
  nm <- rlang::as_name(rlang::ensym(object))
  actual <- glue_collapse(class(object), sep = "/")
  expected <- glue_collapse(expected_class, sep = ", ", last = " or ")
  message <- glue("{bt(nm)} must be {expected}, not of class {sq(actual)}.")
  abort(
    "gargle_error_bad_class",
    message = message
  )
}

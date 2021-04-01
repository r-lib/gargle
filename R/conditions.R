gargle_abort_bad_class <- function(object, expected_class) {
  nm <- as_name(ensym(object))
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

gargle_abort_bad_params <- function(names, reason) {
  message <- glue_collapse(
    c(glue("These parameters are {reason}:"), names),
    sep = "\n"
  )
  abort(
    "gargle_error_bad_params",
    message = message,
    names = names,
    reason = reason
  )
}

expect_gargle2.0_token <- function(object, expected) {
  expect_identical(object$cache_path, expected$cache_path)
  expect_identical(  object$endpoint,   expected$endpoint)
  expect_identical(     object$email,      expected$email)
  expect_identical(       object$app,        expected$app)
  expect_identical(    object$params,     expected$params)
}

## useful during interactive test development to toggle the
## rlang_interactive escape hatch
interactive_mode <- function() {
  before <- getOption("rlang_interactive", default = TRUE)
  after <- if (before) FALSE else TRUE
  options(rlang_interactive = after)
  cat("rlang_interactive:", before, "-->", after, "\n")
  invisible()
}

skip_if_no_auth <- function() {
  testthat::skip_if_not(
    secret_can_decrypt("gargle"),
    "Authentication not available"
  )
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

expect_gargle2.0_token <- function(object, expected) {
  expect_equal(object$cache_path, expected$cache_path)
  expect_equal(  object$endpoint,   expected$endpoint)
  expect_equal(     object$email,      expected$email)
  expect_equal(       object$app,        expected$app)
  expect_equal(    object$params,     expected$params)
}

with_mock <- function(..., .parent = parent.frame()) {
  mockr::with_mock(..., .parent = .parent, .env = "gargle")
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

expect_info <- function(...) {
  if (is_interactive()) {
    expect_output(...)
  } else {
    expect_message(...)
  }
}

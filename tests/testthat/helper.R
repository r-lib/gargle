expect_gargle2.0_token <- function(object, expected) {
  expect_identical(object$cache_path, expected$cache_path)
  expect_identical(  object$endpoint,   expected$endpoint)
  expect_identical(     object$email,      expected$email)
  expect_identical(       object$app,        expected$app)
  expect_identical(    object$params,     expected$params)
}

## call during interactive test development to fake being "in tests" and thereby
## cause in-house interactive() to return FALSE
test_mode <- function() {
  before <- Sys.getenv("TESTTHAT")
  after <- if (before == "true") "false" else "true"
  Sys.setenv(TESTTHAT = after)
  cat("TESTTHAT:", before, "-->", after, "\n")
  invisible()
}

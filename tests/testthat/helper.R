expect_gargle2.0_token <- function(object, expected) {
  expect_equal(object$cache_path, expected$cache_path)
  expect_equal(  object$endpoint,   expected$endpoint)
  expect_equal(     object$email,      expected$email)
  expect_equal(       object$app,        expected$app)
  expect_equal(    object$params,     expected$params)
}

skip_if_no_auth <- function() {
  testthat::skip_if_not(
    secret_can_decrypt("gargle"),
    "Authentication not available"
  )
}

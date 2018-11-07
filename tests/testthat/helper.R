expect_same_token <- function(object, expected) {
  expect_identical(object$cache_path, expected$cache_path)
  expect_identical(  object$endpoint,   expected$endpoint)
  expect_identical(     object$email,      expected$email)
  expect_identical(       object$app,        expected$app)
  expect_identical(    object$params,     expected$params)
}

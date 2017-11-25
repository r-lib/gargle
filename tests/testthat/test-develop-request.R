context("requests")

test_that("develop_request() errors for unrecognized parameters", {
  expect_error(
    develop_request(
      endpoint = list(parameters = list(a = list())),
      params = list(b = list(), c = list())
    ),
    "These parameters are not recognized for this endpoint:\nb\nc"
  )
})

test_that("develop_request() errors if required parameter is missing", {
  expect_error(
    develop_request(
      endpoint = list(parameters = list(a = list(required = TRUE))),
      params = list(b = list())
    ),
    "Required parameter\\(s\\) are missing:\na"

  )
})

test_that("develop_request() separates body params from query", {
  req <- develop_request(
    endpoint = list(
      parameters = list(
        a = list(location = "body", required = FALSE),
        b = list(location = "query", required = FALSE)
      )
    ),
    params = list(a = list(), b = list())
  )
  expect_identical(req$body, list(a = list()))
  expect_identical(req$params, list(b = list()))
})

test_that("build_request() does substitution and puts remainder in query", {
  req <- build_request(
    path = "/{a}/xx/{b}",
    params = list(a = "A", b = "B", c = "C")
  )
  expect_identical(req$url, "https://www.googleapis.com/A/xx/B?c=C")
})

test_that("build_request() suppresses API key if token is non-NULL", {
  req <- build_request(
    params = list(key = "key in params"),
    key = "explicit key",
    token = httr::config(token = "token!")
  )
  expect_false(grepl("key", req$url))
})

test_that("build_request() adds key, if available when token = NULL", {
  req <- build_request(key = "abc", token = NULL)
  expect_match(req$url, "key=abc")
  req <- build_request(params = list(key = "abc"), token = NULL)
  expect_match(req$url, "key=abc")
})

test_that("build_request(): explicit API key > key in params", {
  req <- build_request(key = "abc", params = list(key = "def"), token = NULL)
  expect_match(req$url, "key=abc")
})

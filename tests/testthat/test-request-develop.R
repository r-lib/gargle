test_that("request_develop() errors for unrecognized parameters", {
  expect_snapshot_error(
    request_develop(
      endpoint = list(parameters = list(a = list())),
      params = list(b = list(), c = list())
    )
  )
})

test_that("request_develop() errors if required parameter is missing", {
  expect_snapshot_error(
    request_develop(
      endpoint = list(parameters = list(a = list(required = TRUE))),
      params = list(b = list())
    )
  )
})

test_that("request_develop() separates body params from query", {
  req <- request_develop(
    endpoint = list(
      parameters = list(
        a = list(location = "body", required = FALSE),
        b = list(location = "query", required = FALSE)
      )
    ),
    params = list(a = list(), b = list())
  )
  expect_equal(req$body, list(a = list()))
  expect_equal(req$params, list(b = list()))
})

# https://github.com/r-lib/gargle/issues/122
test_that("request_develop() copes with a param that goes to path and body", {
  req <- request_develop(
    endpoint = list(
      parameters = list(
        two_places = list(location = "path", required = FALSE),
        two_places = list(location = "body", required = FALSE),
        just_path  = list(location = "path", required = FALSE),
        just_body  = list(location = "body", required = FALSE),
        elsewhere  = list(location = "????", required = FALSE)
      )
    ),
    params = list(two_places = list(), just_path = list(), just_body = list())
  )
  expect_equal(req$params, list(two_places = list(), just_path = list()))
  expect_equal(req$body,   list(two_places = list(), just_body = list()))
})

test_that("request_build() does substitution and puts remainder in query", {
  req <- request_build(
    path = "/{a}/xx/{b}",
    params = list(a = "A", b = "B", c = "C")
  )
  expect_equal(req$url, "https://www.googleapis.com/A/xx/B?c=C")
})

test_that("request_build() suppresses API key if token is non-NULL", {
  req <- request_build(
    params = list(key = "key in params"),
    key = "explicit key",
    token = httr::config(token = "token!")
  )
  expect_false(grepl("key", req$url))
})

test_that("request_build() adds key, if available when token = NULL", {
  req <- request_build(key = "abc", token = NULL)
  expect_match(req$url, "key=abc")
  req <- request_build(params = list(key = "abc"), token = NULL)
  expect_match(req$url, "key=abc")
})

test_that("request_build(): explicit API key > key in params", {
  req <- request_build(key = "abc", params = list(key = "def"), token = NULL)
  expect_match(req$url, "key=abc")
})

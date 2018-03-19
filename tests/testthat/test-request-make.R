context("request (make)")

test_that("request_make() errors for invalid HTTP methods", {
  expect_error(
    request_make(list(method = 1L)),
    "is.character(x$method) is not TRUE",
    fixed = TRUE
  )
  expect_error(
    request_make(list(method = "THINGY")),
    "Not a recognized HTTP method: `THINGY`",
    fixed = TRUE
  )
})

test_that("request_make() looks up the HTTP method", {
  with_mock(
    `httr::GET` = function(url = NULL, ...) url, {
      expect_identical(request_make(list(method = "GET", url = "url")), "url")
    }
  )
})

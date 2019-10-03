test_that("request_make() errors for invalid HTTP methods", {
  expect_error(
    request_make(list(method = httr::GET)),
    "is.character(x$method) is not TRUE",
    fixed = TRUE
  )
  expect_error(
    request_make(list(method = "PETCH")),
    "Not a recognized HTTP method"
  )
})

test_that("request_make() looks up the HTTP method", {
  with_mock(
    `httr::GET` = function(url = NULL, ...) url, {
      expect_identical(request_make(list(method = "GET", url = "url")), "url")
    }
  )
})

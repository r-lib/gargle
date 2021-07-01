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

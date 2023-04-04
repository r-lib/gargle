test_that("request_make() errors for invalid HTTP methods", {
  expect_snapshot(
    request_make(list(method = httr::GET)),
    error = TRUE
  )
  expect_snapshot(
    request_make(list(method = "PETCH")),
    error = TRUE
  )
})

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

test_that("request_make() works with an API key", {
  skip_if_offline()

  req <- request_build(
    path = "webfonts/v1/webfonts",
    params = list(family = "Roboto"),
    key = gargle_api_key()
  )
  resp <- request_make(req)
  expect_equal(httr::status_code(resp), 200)
})

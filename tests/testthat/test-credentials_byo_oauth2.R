test_that("credentials_byo_oauth2() demands a Token2.0", {
  expect_snapshot(
    credentials_byo_oauth2(token = "a_naked_access_token"),
    error = TRUE
  )
})

test_that("credentials_byo_oauth2() rejects a token that obviously not Google", {
  fauxen <- gargle2.0_token(
    email = "a@example.org",
    client = gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "CLIENT"),
    credentials = list(access_token = "ACCESS_TOKEN_1"),
    cache = FALSE
  )
  fauxen$endpoint <- httr::oauth_endpoints("github")

  expect_snapshot(credentials_byo_oauth2(token = fauxen), error = TRUE)
})

test_that("credentials_byo_oauth2() just passes valid input through", {
  token <- httr::Token2.0$new(
    app = httr::oauth_app("x", "y", "z"),
    endpoint = httr::oauth_endpoints("google"),
    credentials = list(access_token = "ACCESS_TOKEN"),
    cache_path = FALSE
  )
  expect_equal(credentials_byo_oauth2(token = token), token)
})

test_that("credentials_byo_oauth2() extracts a token from a request", {
  token <- httr::Token2.0$new(
    app = httr::oauth_app("x", "y", "z"),
    endpoint = httr::oauth_endpoints("google"),
    credentials = list(access_token = "ACCESS_TOKEN"),
    cache_path = FALSE
  )
  configured_token <- httr::config(token = token)
  expect_equal(
    credentials_byo_oauth2(token = configured_token),
    token
  )
})

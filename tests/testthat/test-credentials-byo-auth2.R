test_that("credentials_byo_auth2() demands a Token2.0", {
  expect_error(
    credentials_byo_oauth2(token = "a_naked_access_token"),
    'inherits(token, "Token2.0") is not TRUE',
    fixed = TRUE
  )
})

test_that("credentials_byo_auth2() rejects a token that obviously not Google", {
  token <- httr::Token2.0$new(
    app = httr::oauth_app("x", "y", "z"),
    endpoint = httr::oauth_endpoints("github"),
    credentials = list(access_token = "ACCESS_TOKEN"),
    cache_path = FALSE
  )

  expect_error(
    credentials_byo_oauth2(token = token),
    "doesn't use Google's OAuth endpoint"
  )
})

test_that("credentials_byo_auth2() just passes valid input through", {
  token <- httr::Token2.0$new(
    app = httr::oauth_app("x", "y", "z"),
    endpoint = httr::oauth_endpoints("google"),
    credentials = list(access_token = "ACCESS_TOKEN"),
    cache_path = FALSE
  )
  expect_identical(credentials_byo_oauth2(token = token), token)
})

test_that("credentials_byo_auth2() extracts a token from a request", {
  token <- httr::Token2.0$new(
    app = httr::oauth_app("x", "y", "z"),
    endpoint = httr::oauth_endpoints("google"),
    credentials = list(access_token = "ACCESS_TOKEN"),
    cache_path = FALSE
  )
  configured_token <- httr::config(token = token)
  expect_identical(
    credentials_byo_oauth2(token = configured_token),
    token
  )
})

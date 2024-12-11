test_that("connect_credentials() explains why it doesn't work", {
  withr::local_options(gargle_verbosity = "debug")
  expect_snapshot(. <- credentials_connect())
  withr::local_envvar(RSTUDIO_PRODUCT = "CONNECT")
  expect_snapshot(. <- credentials_connect())
})

test_that("ConnectToken makes exchange requests to the Connect server as expected", {
  skip_if_not_installed("connectcreds")
  connectcreds::local_mocked_connect_responses(token = "token")
  token <- ConnectToken$new(
    session = connectcreds::example_connect_session(),
    scopes = c(
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/cloud-platform"
    )
  )
  expect_equal(token$credentials$access_token, "token")
  expect_snapshot(token)
})

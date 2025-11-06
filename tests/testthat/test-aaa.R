test_that("token works", {
  skip_if_offline()

  expect_no_error(
    token <- credentials_service_account(
      scopes = "https://www.googleapis.com/auth/userinfo.email",
      path = secret_decrypt_json(
        fs::path_package("gargle", "secret", "gargle-testing.json"),
        key = "GARGLE_KEY"
      )
    )
  )
  email <- token_email(token)
  expect_match(email, "^gargle-testing@.*[.]iam[.]gserviceaccount[.]com")
})

test_that("gargle_last_response() captures error response", {
  rds_file <- test_path("fixtures", "fitness-get-wrong-scope_403.rds")
  resp <- readRDS(rds_file)

  expect_error(
    response_process(resp),
    class = "gargle_error_request_failed"
  )

  last_resp <- gargle_last_response()
  expect_s3_class(last_resp, "response")
  expect_equal(httr::status_code(last_resp), 403)
  expect_equal(
    last_resp$url,
    "https://www.googleapis.com/fitness/v1/users/12345/dataSources"
  )

  last_content <- gargle_last_content()
  expect_equal(
    last_content$error$message,
    "Request had insufficient authentication scopes."
  )
})

test_that("remember = FALSE prevents capturing response", {
  rds_file <- test_path("fixtures", "fitness-get-wrong-scope_403.rds")
  resp <- readRDS(rds_file)

  gargle_env$last_response <- list(marker = "old_value")

  expect_error(
    response_process(resp, remember = FALSE),
    class = "gargle_error_request_failed"
  )

  expect_equal(gargle_env$last_response$marker, "old_value")
})

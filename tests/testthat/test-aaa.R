test_that("token works", {
  skip_if_offline()

  expect_no_error(
    token <- credentials_service_account(
      scopes = "https://www.googleapis.com/auth/userinfo.email",
      path = secret_read_json(
        fs::path_package("gargle", "secret", "gargle-testing.json"),
        key = "GARGLE_KEY"
      )
    )
  )
  email <- token_email(token)
  expect_match(email, "^gargle-testing@.*[.]iam[.]gserviceaccount[.]com")
})

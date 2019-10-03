test_that("token works", {
  skip_if_offline()
  skip_if_no_auth()

  expect_error_free(
    token <- credentials_service_account(
      scopes = "https://www.googleapis.com/auth/userinfo.email",
      path = rawToChar(secret_read("gargle", "gargle-testing.json"))
    )
  )
  email <- token_email(token)
  expect_match(email, "^gargle-testing@.*[.]iam[.]gserviceaccount[.]com")
})

test_that("token_*() functions work", {
  skip_if_offline()

  token <- credentials_service_account(
    scopes = "https://www.googleapis.com/auth/userinfo.email",
    path = secret_decrypt_json(
      fs::path_package("gargle", "secret", "gargle-testing.json"),
      key = "GARGLE_KEY"
    )
  )

  expect_no_error(
    # this implies a call to token_userinfo()
    email <- token_email(token)
  )
  expect_no_error(
    tokeninfo <- token_tokeninfo(token)
  )

  expect_match(email, "^gargle-testing@.*[.]iam[.]gserviceaccount[.]com")
  expect_equal(email, tokeninfo$email)
  expect_true(
    "https://www.googleapis.com/auth/userinfo.email" %in% tokeninfo$scope
  )
})

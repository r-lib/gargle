test_that("token_*() functions work", {
  skip_if_offline()
  skip_if_no_auth()

  token <- credentials_service_account(
    scopes = "https://www.googleapis.com/auth/userinfo.email",
    path = rawToChar(secret_read("gargle", "gargle-testing.json"))
  )

  expect_error_free(
    # this implies a call to token_userinfo()
    email <- token_email(token)
  )
  expect_error_free(
    tokeninfo <- token_tokeninfo(token)
  )

  expect_match(email, "^gargle-testing@.*[.]iam[.]gserviceaccount[.]com")
  expect_identical(email, tokeninfo$email)
  expect_true(
    "https://www.googleapis.com/auth/userinfo.email" %in% tokeninfo$scope
  )
})

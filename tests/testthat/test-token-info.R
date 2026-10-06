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
  # I believe `scope` to be a "space separated list of scopes"
  expect_true(grepl(
    "https://www.googleapis.com/auth/userinfo.email",
    tokeninfo$scope,
    fixed = TRUE
  ))
})

test_that("token_tokeninfo() does not eagerly refresh impersonated service account tokens", {
  refreshed <- FALSE
  token <- structure(
    list(
      refresh = function() {
        refreshed <<- TRUE
      }
    ),
    class = c("ImpersonatedServiceAccountToken", "Token2.0", "Token")
  )

  local_mocked_bindings(
    request_build = function(...) list(),
    request_make = function(...) {
      structure(list(status_code = 200), class = "response")
    },
    response_process = function(...) list(scope = character())
  )

  expect_no_error(token_tokeninfo(token))
  expect_false(refreshed)
})

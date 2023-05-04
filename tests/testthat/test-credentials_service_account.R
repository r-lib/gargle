test_that("check_is_service_account() errors for OAuth client", {
  # call indirectly, so we can also check the caller is reported
  PKG_auth <- function(path) {
    check_is_service_account(path, hint = "PKG_auth_configure")
  }
  expect_snapshot(
    error = TRUE,
    PKG_auth(
      test_path("fixtures", "client_secret_123.googleusercontent.com.json")
    )
  )
})

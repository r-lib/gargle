test_that("check_is_service_account() errors for OAuth client", {
  # call indirectly, so we can also check the caller is reported
  PKG_auth <- function(path) {
    check_is_service_account(path, hint = "PKG_auth_configure")
  }
  expect_snapshot(
    error = TRUE,
    PKG_auth(
      fs::path_package("gargle", "extdata", "client_secret_installed.googleusercontent.com.json")
    )
  )
})

test_that("check_is_service_account() errors for invalid input", {
  # call indirectly, so we can also check the caller is reported
  PKG_auth <- function(path) {
    check_is_service_account(path, hint = "PKG_auth_configure")
  }
  expect_snapshot(
    error = TRUE,
    PKG_auth("wut")
  )
})

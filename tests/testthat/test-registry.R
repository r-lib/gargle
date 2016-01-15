context("registry")

# These are used in several tests below.
creds_one <- function(scopes, ...) {}
creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}

test_that("We recognize the right credential functions", {
  expect_true(is_credential_function(creds_one))
  expect_true(is_credential_function(creds_two))

  invalid_one <- function(scope, ...) {}
  invalid_two <- function(scopes, arg1, arg2 = "optional") {}
  expect_false(gauth:::is_credential_function(invalid_one))
  expect_false(gauth:::is_credential_function(invalid_two))
})

test_that("We can register new credential functions", {
  add_credential_function(creds_one)
  expect_equal(1, length(all_credential_functions()))

  add_credential_function(creds_two)
  expect_equal(2, length(all_credential_functions()))

  set_credential_functions(list())
  expect_equal(0, length(all_credential_functions()))

  for (i in 1:5) {
    add_credential_function(creds_one)
    expect_equal(i, length(all_credential_functions()))
  }

  set_credential_functions(list(creds_two))
  expect_equal(1, length(all_credential_functions()))
})

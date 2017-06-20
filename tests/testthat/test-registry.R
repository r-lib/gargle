context("registry")

# These are used in several tests below.
creds_one <- function(scopes, ...) {}
creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}

test_that("We recognize the right credential functions", {
  expect_true(is_credential_function(creds_one))
  expect_true(is_credential_function(creds_two))

  invalid_one <- function(scope, ...) {}
  invalid_two <- function(scopes, arg1, arg2 = "optional") {}
  invalid_three <- 17
  expect_false(gargle:::is_credential_function(invalid_one))
  expect_false(gargle:::is_credential_function(invalid_two))
  expect_false(gargle:::is_credential_function(invalid_three))
})

test_that("We can register new credential functions", {
  on.exit(clear_credential_functions())
  clear_credential_functions()

  add_credential_function(creds_one)
  expect_equal(1, length(all_credential_functions()))

  add_credential_function(creds_two)
  expect_equal(2, length(all_credential_functions()))

  clear_credential_functions()
  expect_equal(0, length(all_credential_functions()))

  for (i in 1:5) {
    add_credential_function(creds_one)
    expect_equal(i, length(all_credential_functions()))
  }

  set_credential_functions(list(creds_two))
  expect_equal(1, length(all_credential_functions()))
})

test_that("We capture credential function names when possible", {
  on.exit(clear_credential_functions())
  clear_credential_functions()

  add_credential_function(a = creds_one)
  add_credential_function(b = function(scopes, ...) {})
  add_credential_function(creds_one)
  add_credential_function(function(scopes, ...) {})
  expect_identical(names(all_credential_functions()), c("", "", "b", "a"))

  clear_credential_functions()

  add_credential_function(
    function(scopes, ...) {},
    creds_one,
    b = function(scopes, ...) {},
    a = creds_one
  )
  expect_identical(names(all_credential_functions()), c("", "", "b", "a"))

})

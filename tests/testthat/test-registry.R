# These are used in several tests below.
creds_one <- function(scopes, ...) {}
creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}

test_that("We recognize the right credential functions", {
  expect_true(is_cred_fun(creds_one))
  expect_true(is_cred_fun(creds_two))

  invalid_one <- function(scope, ...) {}
  invalid_two <- function(scopes, arg1, arg2 = "optional") {}
  invalid_three <- 17
  expect_false(is_cred_fun(invalid_one))
  expect_false(is_cred_fun(invalid_two))
  expect_false(is_cred_fun(invalid_three))
})

test_that("We can register new credential functions", {
  on.exit(cred_funs_clear())
  cred_funs_clear()

  cred_funs_add(creds_one)
  expect_equal(1, length(cred_funs_list()))

  cred_funs_add(creds_two)
  expect_equal(2, length(cred_funs_list()))

  cred_funs_clear()
  expect_equal(0, length(cred_funs_list()))

  for (i in 1:5) {
    cred_funs_add(creds_one)
    expect_equal(i, length(cred_funs_list()))
  }

  cred_funs_set(list(creds_two))
  expect_equal(1, length(cred_funs_list()))
})

test_that("We capture credential function names when possible", {
  on.exit(cred_funs_clear())
  cred_funs_clear()

  cred_funs_add(a = creds_one)
  cred_funs_add(b = function(scopes, ...) {})
  cred_funs_add(creds_one)
  cred_funs_add(function(scopes, ...) {})
  expect_identical(names(cred_funs_list()), c("", "", "b", "a"))

  cred_funs_clear()

  cred_funs_add(
    function(scopes, ...) {},
    creds_one,
    b = function(scopes, ...) {},
    a = creds_one
  )
  expect_identical(names(cred_funs_list()), c("", "", "b", "a"))
})

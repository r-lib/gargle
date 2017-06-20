context("registry")

# These are used in several tests below.
creds_one <- function(scopes, ...) {}
creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}

test_that("We recognize the right credential functions", {
  expect_true(is_credfun(creds_one))
  expect_true(is_credfun(creds_two))

  invalid_one <- function(scope, ...) {}
  invalid_two <- function(scopes, arg1, arg2 = "optional") {}
  invalid_three <- 17
  expect_false(gargle:::is_credfun(invalid_one))
  expect_false(gargle:::is_credfun(invalid_two))
  expect_false(gargle:::is_credfun(invalid_three))
})

test_that("We can register new credential functions", {
  on.exit(credfuns_clear())
  credfuns_clear()

  credfuns_add(creds_one)
  expect_equal(1, length(credfuns_list()))

  credfuns_add(creds_two)
  expect_equal(2, length(credfuns_list()))

  credfuns_clear()
  expect_equal(0, length(credfuns_list()))

  for (i in 1:5) {
    credfuns_add(creds_one)
    expect_equal(i, length(credfuns_list()))
  }

  credfuns_set(list(creds_two))
  expect_equal(1, length(credfuns_list()))
})

test_that("We capture credential function names when possible", {
  on.exit(credfuns_clear())
  credfuns_clear()

  credfuns_add(a = creds_one)
  credfuns_add(b = function(scopes, ...) {})
  credfuns_add(creds_one)
  credfuns_add(function(scopes, ...) {})
  expect_identical(names(credfuns_list()), c("", "", "b", "a"))

  credfuns_clear()

  credfuns_add(
    function(scopes, ...) {},
    creds_one,
    b = function(scopes, ...) {},
    a = creds_one
  )
  expect_identical(names(credfuns_list()), c("", "", "b", "a"))

})

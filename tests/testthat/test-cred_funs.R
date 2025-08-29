test_that("is_cred_fun() recognizes a credential function signature", {
  creds_one <- function(scopes, ...) {}
  creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}
  expect_true(is_cred_fun(creds_one))
  expect_true(is_cred_fun(creds_two))

  invalid_one <- function(scope, ...) {}
  invalid_two <- function(scopes, arg1, arg2 = "optional") {}
  invalid_three <- 17
  expect_false(is_cred_fun(invalid_one))
  expect_false(is_cred_fun(invalid_two))
  expect_false(is_cred_fun(invalid_three))
})

test_that("cred_funs_add() and _set() can add and set credential functions", {
  creds_one <- function(scopes, ...) {}
  creds_two <- function(scopes, arg1, arg2 = "optional", ...) {}

  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(a = creds_one)
  expect_equal(names(cred_funs_list()), "a")

  cred_funs_add(b = creds_two)
  expect_equal(names(cred_funs_list()), c("b", "a"))

  cred_funs_clear()
  expect_equal(0, length(cred_funs_list()))

  for (i in 1:5) {
    nm <- glue("cf{i}")
    cred_funs_add(!!nm := creds_one)
    expect_equal(i, length(cred_funs_list()))
    expect_match(names(cred_funs_list()), "^cf[12345]")
  }

  cred_funs_set(list(first = creds_one, last = creds_two))
  expect_equal(names(cred_funs_list()), c("first", "last"))
})

test_that("We insist on valid credential function (or NULL)", {
  creds_one <- function(scopes, ...) {}

  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  expect_snapshot(
    error = TRUE,
    cred_funs_add(a = mean)
  )
  expect_snapshot(
    error = TRUE,
    cred_funs_set(list(a = NULL))
  )
})

test_that("We insist on uniquely named credential functions", {
  creds_one <- function(scopes, ...) {}

  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(a = creds_one)
  cred_funs_add(b = function(scopes, ...) {})
  expect_snapshot(
    error = TRUE,
    cred_funs_add(creds_one)
  )
  expect_snapshot(
    error = TRUE,
    cred_funs_add(a = creds_one)
  )
  expect_equal(names(cred_funs_list()), c("b", "a"))

  cred_funs_clear()

  expect_snapshot(
    error = TRUE,
    cred_funs_set(list(
      creds_one,
      a = function(scopes, ...) {}
    ))
  )
  expect_snapshot(
    error = TRUE,
    cred_funs_set(list(
      a = creds_one,
      a = function(scopes, ...) {}
    ))
  )
})

test_that("We can remove credential functions by name", {
  cred_fun <- function(scopes, ...) {}
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(a = cred_fun, b = cred_fun, c = cred_fun)
  cred_funs_add(b = NULL)
  expect_equal(names(cred_funs_list()), c("c", "a"))

  cred_funs_add(c = NULL, d = cred_fun)
  expect_equal(names(cred_funs_list()), c("d", "a"))
})

test_that("cred_funs_set() warns for use of `ls`", {
  withr::local_options(lifecycle_verbosity = "warning")
  withr::defer(cred_funs_set_default())
  expect_snapshot(
    out <- cred_funs_set(ls = list(a = function(scopes, ...) {}))
  )
  expect_equal(names(cred_funs_list()), "a")
})

test_that("local_cred_funs() works", {
  withr::defer(cred_funs_set_default())
  cred_fun <- function(scopes, ...) {}
  cred_funs_clear()

  cred_funs_add(a = cred_fun, b = cred_fun)

  local_cred_funs(funs = list(c = cred_fun), action = "modify")
  expect_equal(names(cred_funs_list()), c("c", "b", "a"))

  local_cred_funs(funs = list(d = cred_fun)) # action = "replace"
  expect_equal(names(cred_funs_list()), "d")

  local_cred_funs()
  expect_equal(names(cred_funs_list()), names(cred_funs_list_default()))
})

test_that("with_cred_funs() works", {
  withr::defer(cred_funs_set_default())
  cred_fun <- function(scopes, ...) {}
  cred_funs_clear()

  cred_funs_add(a = cred_fun, b = cred_fun)

  with_cred_funs(
    funs = list(c = cred_fun),
    action = "modify",
    expect_equal(names(cred_funs_list()), c("c", "b", "a"))
  )

  with_cred_funs(
    funs = list(d = cred_fun), # action = "replace"
    expect_equal(names(cred_funs_list()), "d")
  )

  with_cred_funs(
    code = expect_equal(
      names(cred_funs_list()),
      names(cred_funs_list_default())
    )
  )
})

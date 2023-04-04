# These are used in several tests below.
creds_always <- function(scopes, ...) {
  1
}
creds_never <- function(scopes, ...) {
  NULL
}
creds_failure <- function(scopes, ...) {
  stop("no creds")
}
creds_maybe <- function(scopes, arg1 = "", ...) {
  if (arg1 != "") {
    2
  }
}

test_that("Basic token fetching works", {
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(always = creds_always)
  expect_equal(1, token_fetch(c()))

  cred_funs_add(never = creds_never)
  expect_equal(1, token_fetch(c()))
})

test_that("We fetch tokens in order", {
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(always = creds_always)
  cred_funs_add(maybe = creds_maybe)

  expect_equal(1, token_fetch(c()))
  expect_equal(2, token_fetch(c(), arg1 = "abc"))

  cred_funs_set(list(always = creds_always, maybe = creds_maybe))

  expect_equal(1, token_fetch(c()))
  expect_equal(1, token_fetch(c(), arg1 = "abc"))
})

test_that("We sometimes return no token", {
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(never = creds_never)
  expect_null(token_fetch(c()))
})

test_that("We don't need any registered functions", {
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  expect_null(token_fetch(c()))
})

test_that("We keep looking for credentials on error", {
  withr::defer(cred_funs_set_default())
  cred_funs_clear()

  cred_funs_add(always = creds_always)
  cred_funs_add(failure = creds_failure)

  expect_equal(1, token_fetch(c()))
})

# These are used in several tests below.
creds_always <- function(scopes, ...) { 1 }
creds_never <- function(scopes, ...) { NULL }
creds_failure <- function(scopes, ...) { stop("no creds") }
creds_maybe <- function(scopes, arg1 = "", ...) {
  if (arg1 != "") {
    2
  }
}

test_that("Basic token fetching works", {
  on.exit(cred_funs_clear())

  cred_funs_add(creds_always)
  expect_equal(1, token_fetch(c()))

  cred_funs_add(creds_never)
  expect_equal(1, token_fetch(c()))
})

test_that("We fetch tokens in order", {
  on.exit(cred_funs_clear())

  cred_funs_add(creds_always)
  cred_funs_add(creds_maybe)

  expect_equal(1, token_fetch(c()))
  expect_equal(2, token_fetch(c(), arg1 = "abc"))

  cred_funs_set(list(creds_always, creds_maybe))

  expect_equal(1, token_fetch(c()))
  expect_equal(1, token_fetch(c(), arg1 = "abc"))
})

test_that("We sometimes return no token", {
  on.exit(cred_funs_clear())

  cred_funs_add(creds_never)
  expect_null(token_fetch(c()))
})

test_that("We don't need any registered functions", {
  expect_null(token_fetch(c()))
})

test_that("We keep looking for credentials on error", {
  on.exit(cred_funs_clear())

  cred_funs_add(creds_always)
  cred_funs_add(creds_failure)

  expect_equal(1, token_fetch(c()))
})

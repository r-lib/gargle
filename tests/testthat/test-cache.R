context("test-cache.R")

test_that("token_upsert() returns tibble-ized input if no cache", {
  fauxen <- gargle2.0_token(email = "a", credentials = list(a = 1))

  expect_identical(token_upsert(list(), fauxen), entibble(fauxen))
  expect_identical(token_upsert(tibble::tibble(), fauxen), entibble(fauxen))
})

test_that("token_upsert() inserts new token into non-empty cache", {
  fauxen_a <- gargle2.0_token(email = "a", credentials = list(a = 1))
  fauxen_b <- gargle2.0_token(email = "b", credentials = list(a = 1))

  cache <- token_upsert(list(), fauxen_a)
  cache <- token_upsert(cache, fauxen_b)
  expect_setequal(cache$email, c("a", "b"))
})

test_that("token_upsert() updates token already in cache", {
  fauxen_a <- gargle2.0_token(email = "a", credentials = list(a = 1))
  fauxen_b <- gargle2.0_token(email = "b", credentials = list(a = 1))
  cache <- token_upsert(list(), fauxen_a)
  cache <- token_upsert(cache, fauxen_b)

  fauxen_b_update <- gargle2.0_token(email = "b", credentials = list(a = 2))
  cache <- token_upsert(cache, fauxen_b_update)

  i <- which(cache$email == "b")
  expect_identical(cache$token[[i]][["credentials"]], list(a = 2))
})

test_that("token_match() retrieves an exact hash match", {
  tc <- tempfile("cache-")

  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = tc
  )
  fauxen_b <- gargle2.0_token(email = "a", scope = "a", cache = tc)
  expect_equal(fauxen_a, fauxen_b)
})

test_that("token_match() returns a single multi match", {
  tc <- tempfile("cache-")

  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = tc
  )
  fauxen_b <- gargle2.0_token(scope = "a", cache = tc)
  expect_equal(fauxen_a, fauxen_b)
})

test_that("token_match() fails for >1 multi match, if non-interactive", {
  tc <- tempfile("cache-")

  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = tc
  )
  fauxen_b <- gargle2.0_token(
    email = "b",
    scope = "a",
    credentials = list(b = 1),
    cache = tc
  )
  expect_error(
    gargle2.0_token(scope = "a", cache = tc),
    "Multiple cached tokens"
  )
})

test_that("token_match() works with normalized scopes, uses 'set' mentality ", {
  tc <- tempfile("cache-")

  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = c("a", "b", "c"),
    credentials = list(a = 1),
    cache = tc
  )

  fauxen_b <- gargle2.0_token(scope = "a", cache = tc)
  expect_equal(fauxen_a, fauxen_b)

  fauxen_c <- gargle2.0_token(scope = c("c", "a", "b"), cache = tc)
  expect_equal(fauxen_a, fauxen_c)
})

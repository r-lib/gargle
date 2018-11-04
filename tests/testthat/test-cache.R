context("test-cache.R")

test_that("token_upsert() adds novel tokens", {
  fauxen_a <- gargle2.0_token(
    email = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())

  expect_identical(cache[[1]], fauxen_a)
  expect_named(cache, fauxen_a$hash())

  fauxen_b <- gargle2.0_token(
    email = "b",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_b, cache)

  expect_identical(cache[[2]], fauxen_b)
  expect_named(cache, c(fauxen_a$hash(), fauxen_b$hash()))
})

test_that("token_upsert() updates pre-existng, matching token", {
  fauxen_a <- gargle2.0_token(
    email = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  fauxen_b <- gargle2.0_token(
    email = "b",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())
  cache <- token_upsert(fauxen_b, cache)

  fauxen_b_update <- gargle2.0_token(
    email = "b",
    credentials = list(a = 2),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_b_update, cache)

  i <- which(vapply(cache, function(t) t$email, character(1)) == "b")
  expect_identical(cache[[i]][["credentials"]], list(a = 2))
})

test_that("token_match() retrieves a unique, exact hash match", {
  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())

  fauxen_a2 <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 2),
    cache = FALSE
  )

  expect_equal(fauxen_a, token_match(fauxen_a2, cache))
})

test_that("token_match() retrieves a unique, exact short hash match", {
  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())

  fauxen_a2 <- gargle2.0_token(
    scope = "a",
    credentials = list(a = 2),
    cache = FALSE
  )

  expect_equal(fauxen_a, token_match(fauxen_a2, cache))
})

test_that("token_match() fails for >1 short hash match, if non-interactive", {
  fauxen_a <- gargle2.0_token(
    email = "a",
    scope = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  fauxen_b <- gargle2.0_token(
    email = "b",
    scope = "a",
    credentials = list(b = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())
  cache <- token_upsert(fauxen_b, cache)

  fauxen_c <- gargle2.0_token(
    scope = "a",
    credentials = list(c = 1),
    cache = FALSE
  )

  expect_error(
    token_match(fauxen_c, cache),
    "Multiple cached tokens"
  )
})

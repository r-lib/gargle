context("test-cache.R")

test_that("token_upsert() returns tibble-ized input if no cache", {
  fauxen <- Gargle2.0$new(email = "email", credentials = list(a = 1))

  expect_identical(token_upsert(list(), fauxen), entibble(fauxen))
  expect_identical(token_upsert(tibble::tibble(), fauxen), entibble(fauxen))
})

test_that("token_upsert() inserts new token into non-empty cache", {
  fauxen_a <- Gargle2.0$new(email = "a", credentials = list(a = 1))
  fauxen_b <- Gargle2.0$new(email = "b", credentials = list(a = 1))

  cache <- token_upsert(list(), fauxen_a)
  cache <- token_upsert(cache, fauxen_b)
  expect_setequal(cache$email, c("a", "b"))
})

test_that("token_upsert() updates token already in cache", {
  fauxen_a <- Gargle2.0$new(email = "a", credentials = list(a = 1))
  fauxen_b <- Gargle2.0$new(email = "b", credentials = list(a = 1))
  cache <- token_upsert(list(), fauxen_a)
  cache <- token_upsert(cache, fauxen_b)

  fauxen_b_update <- Gargle2.0$new(email = "b", credentials = list(a = 2))
  cache <- token_upsert(cache, fauxen_b_update)

  i <- which(cache$email == "b")
  expect_identical(cache$token[[i]][["credentials"]], list(a = 2))
})

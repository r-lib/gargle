context("test-cache.R")

# cache_establish (interface) ------------------------------------------------

test_that("cache_establish() insists on sensible input", {
  expect_error(
    cache_establish(letters[1:2]),
    "should be length 1"
  )
  expect_error(
    cache_establish(1),
    "logical or string"
  )
  expect_error(
    cache_establish(list(1)),
    "logical or string"
  )
})

test_that("`cache = TRUE` defers to default file path", {
  expect_identical(cache_establish(TRUE), gargle_default_oauth_cache_path)
})

test_that("`cache = FALSE` does nothing", {
  expect_null(cache_establish(FALSE))
})

test_that("`cache = <filepath>` creates cache file, recursively", {
  tmpfile <- file.path(tempfile(), "foo", "bar")
  on.exit(unlink(tmpfile, recursive = TRUE))

  cache_establish(tmpfile)
  expect_true(file.exists(tmpfile))
})

test_that("`cache = <filepath>` add new cache file to relevant 'ignores'", {
  tmpproj <- tempfile()
  on.exit(unlink(tmpproj, recursive = TRUE))
  dir.create(tmpproj)
  writeLines("", file.path(tmpproj, "DESCRIPTION"))
  writeLines("", file.path(tmpproj, ".gitignore"))
  cache_establish(file.path(tmpproj, "oauth-cache"))
  expect_match(readLines(file.path(tmpproj, ".gitignore")), "oauth-cache$")
  expect_match(
    readLines(file.path(tmpproj, ".Rbuildignore")),
    "oauth-cache$",
    fixed = TRUE
  )
})

# token into and out of cache ---------------------------------------------
test_that("token_from_cache() returns NULL when caching turned off", {
  fauxen <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  expect_null(token_from_cache(fauxen) )
})

test_that("token_into_cache(), token_from_cache() roundtrip", {
  cache_file <- tempfile()
  on.exit(file.remove(cache_file))
  file.create(cache_file)

  ## this calls token_into_cache()
  token_in <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = cache_file
  )

  ## this calls token_from_cache()
  token_out <- gargle2.0_token(
    email = "a@example.org",
    cache = cache_file
  )

  expect_gargle2.0_token(token_in, token_out)
  expect_identical(token_out$credentials, list(a = 1))
})

# tokens in relation to each other ----------------------------------------

test_that("token_upsert() adds novel tokens", {
  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())

  expect_gargle2.0_token(cache[[1]], fauxen_a)
  expect_named(cache, fauxen_a$hash())

  fauxen_b <- gargle2.0_token(
    email = "b@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_b, cache)

  expect_gargle2.0_token(cache[[2]], fauxen_b)
  expect_named(cache, c(fauxen_a$hash(), fauxen_b$hash()))
})

test_that("token_upsert() updates pre-existng, matching token", {
  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  fauxen_b <- gargle2.0_token(
    email = "b@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())
  cache <- token_upsert(fauxen_b, cache)

  fauxen_b_update <- gargle2.0_token(
    email = "b@example.org",
    credentials = list(a = 2),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_b_update, cache)

  i <- which(vapply(cache, function(t) t$email, character(1)) == "b@example.org")
  expect_identical(cache[[i]][["credentials"]], list(a = 2))
})

test_that("token_match() retrieves a unique, exact hash match", {
  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
    scope = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  cache <- token_upsert(fauxen_a, list())

  fauxen_a2 <- gargle2.0_token(
    email = "a@example.org",
    scope = "a",
    credentials = list(a = 2),
    cache = FALSE
  )

  expect_gargle2.0_token(fauxen_a, token_match(fauxen_a2, cache))
})

test_that("token_match() handling of a unique, exact short hash match", {
  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
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

  expect_error(
    token_match(fauxen_a2, cache),
    "user confirmation is required"
  )

  fauxen_a2$email <- TRUE
  expect_gargle2.0_token(fauxen_a, token_match(fauxen_a2, cache))
})

test_that("token_match() fails for >1 short hash match, if non-interactive", {
  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
    scope = "a",
    credentials = list(a = 1),
    cache = FALSE
  )
  fauxen_b <- gargle2.0_token(
    email = "b@example.org",
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
    "user confirmation is required"
  )
})

# helpers -----------------------------------------------------------

test_that("match2() works", {
  expect_identical(match2("a", c("a", "b", "a")), c(1L, 3L))
  expect_identical(match2("b", c("a", "b", "a")), 2L)
  expect_true(is.na(match2("c", c("a", "b", "a"))))
})

test_that("mask_email() works", {
  hash <- "2a46e6750476326f7085ebdab4ad103d"
  expect_identical(
    mask_email(c(
      "2a46e6750476326f7085ebdab4ad103d_jenny@example.com",
      "2a46e6750476326f7085ebdab4ad103d_NA",
      "2a46e6750476326f7085ebdab4ad103d_",
      "2a46e6750476326f7085ebdab4ad103d_FIRST_LAST@example.com"
    )),
    rep_len(hash, 4)
  )
})

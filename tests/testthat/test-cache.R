context("test-cache.R")

# cache_establish ---------------------------------------------------------

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

# token handling ----------------------------------------------------------

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

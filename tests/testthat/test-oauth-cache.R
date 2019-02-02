context("test-cache.R")

# cache_establish ------------------------------------------------------------

test_that("cache_establish() insists on sensible input", {
  expect_error(
    cache_establish(letters[1:2]),
    "must have length 1"
  )
  expect_error(
    cache_establish(1),
    "logical or character"
  )
  expect_error(
    cache_establish(list(1)),
    "logical or character"
  )
})

test_that("`cache = TRUE` defers to default cache path", {
  with_mock(
    ## we don't want to actually initialize a cache
    `gargle:::cache_create` = function(path) NULL,
    expect_identical(cache_establish(TRUE), gargle_default_oauth_cache_path())
  )
})

test_that("`cache = FALSE` does nothing", {
  expect_null(cache_establish(FALSE))
})

test_that("`cache = NA` is like `cache = FALSE` if cache not available", {
  with_mock(
    `gargle:::gargle_default_oauth_cache_path` = function() file_temp(),
    `gargle:::cache_allowed` = function(path) FALSE,
    expect_identical(cache_establish(NA), cache_establish(FALSE))
  )
})

test_that("`cache = <filepath>` creates cache folder, recursively", {
  tmpfolder <- path_temp("foo", "bar")
  on.exit(dir_delete(tmpfolder))

  cache_establish(tmpfolder)
  expect_true(dir_exists(tmpfolder))
})

test_that("`cache = <filepath>` adds new cache folder to relevant 'ignores'", {
  tmpproj <- file_temp()
  on.exit(dir_delete(tmpproj))
  dir_create(tmpproj)
  writeLines("", path(tmpproj, "DESCRIPTION"))
  writeLines("", path(tmpproj, ".gitignore"))
  cache_establish(path(tmpproj, "oauth-cache"))
  expect_match(readLines(path(tmpproj, ".gitignore")), "oauth-cache$")
  expect_match(
    readLines(path(tmpproj, ".Rbuildignore")),
    "oauth-cache$",
    fixed = TRUE
  )
})

test_that("default is to consult and write the oauth cache option", {
  withr::with_options(
    list(gargle.oauth_cache = NA),
    with_mock(
      `gargle:::gargle_default_oauth_cache_path` = function() file_temp(),
      `gargle:::cache_allowed` = function(path) FALSE, {
        expect_identical(getOption("gargle.oauth_cache"), NA)
        cache_establish()
        expect_false(getOption("gargle.oauth_cache"))
      }
    )
  )
})

# cache_allowed() ---------------------------------------------------------

test_that("cache_allowed() returns false when non-interactive (or testing)", {
  expect_false(cache_allowed(getwd()))
})

# token into and out of cache ---------------------------------------------
test_that("token_from_cache() returns NULL when caching turned off", {
  fauxen <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = FALSE
  )
  expect_null(token_from_cache(fauxen))
})

test_that("token_into_cache(), token_from_cache() roundtrip", {
  cache_folder <- file_temp()
  on.exit(dir_delete(cache_folder))
  dir_create(cache_folder)

  ## this calls token_into_cache()
  token_in <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = cache_folder
  )

  ## this calls token_from_cache()
  token_out <- gargle2.0_token(
    email = "a@example.org",
    cache = cache_folder
  )

  expect_gargle2.0_token(token_in, token_out)
  expect_identical(token_out$credentials, list(a = 1))
})

# token_match() ----------------------------------------
test_that("token_match() returns NULL if nothing to match against", {
  expect_null(token_match("whatever", character()))
})

test_that("token_match() returns NULL if email is empty", {
  expect_null(token_match("aaa_", "aaa_"))
})

test_that("token_match() returns NULL email given, but no match", {
  candidate <- "a0_a@example.org"
  expect_null(token_match(candidate, "b1_a@example.org"))
  expect_null(token_match(candidate, "a0_b@example.org"))
  expect_null(token_match(candidate, "a@example.org"))
  expect_null(token_match(candidate, "a0"))
  expect_null(token_match(candidate, "a0_"))
})

test_that("token_match() fails for >1 short hash match, if non-interactive", {
  candidate <- "a0_"
  existing <- c("a0_a@example.org", "a0_b@example.org")
  expect_null(token_match(candidate, existing))
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

test_that("extract_email() works", {
  expect_identical(extract_email("abc123_a"), "a")
  expect_identical(extract_email("abc123_b@example.com"), "b@example.com")
  expect_identical(extract_email("abc123_"), "")
  expect_identical(extract_email("abc123_FIRST_LAST@a.com"), "FIRST_LAST@a.com")
})

test_that("hash_paths() works", {
  x <- c("aa_bb_cc", "a.md", "b.rds", "c.txt", "dd123_e@example.org")
  expect_identical(hash_paths(x), x[c(1, 5)])
})

# cache_establish ------------------------------------------------------------

test_that("cache_establish() insists on sensible input", {
  expect_error(
    cache_establish(letters[1:2]),
    "must have length 1"
  )
  expect_error(
    cache_establish(1),
    class = "gargle_error_bad_class"
  )
  expect_error(
    cache_establish(list(1)),
    class = "gargle_error_bad_class"
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
    list(gargle_oauth_cache = NA),
    with_mock(
      `gargle:::gargle_default_oauth_cache_path` = function() file_temp(),
      `gargle:::cache_allowed` = function(path) FALSE, {
        expect_identical(getOption("gargle_oauth_cache"), NA)
        cache_establish()
        expect_false(getOption("gargle_oauth_cache"))
      }
    )
  )
})

# cache_allowed() ---------------------------------------------------------

test_that("cache_allowed() returns false when non-interactive (or testing)", {
  expect_false(cache_allowed(getwd()))
})

# validate_token_list() ------------------------------------------------------
test_that("cache_load() copes repairs tokens stored with names != their hash", {
  cache_folder <- file_temp()
  on.exit(dir_delete(cache_folder))

  fauxen_a <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = cache_folder
  )
  fauxen_b <- gargle2.0_token(
    email = "b@example.org",
    credentials = list(b = 1),
    cache = cache_folder
  )
  file_move(
    dir_ls(cache_folder),
    path(cache_folder, c("abc123_c@example.org", "def456_d@example.org"))
  )
  withr::local_options(list(gargle_quiet = FALSE))
  expect_output(
    tokens <- cache_load(cache_folder),
    "do not match their hash"
  )
  expect_gargle2.0_token(tokens[[1]], fauxen_a)
  expect_gargle2.0_token(tokens[[2]], fauxen_b)
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

test_that("token_match() returns the full match", {
  one_existing <- "abc_a@example.com"
  two_existing <- c(one_existing, "def_b@example.com")

  expect_identical(
    one_existing,
    token_match(one_existing, one_existing)
  )
  expect_identical(
    one_existing,
    token_match(one_existing, two_existing)
  )
})

test_that("token_match() returns NULL if email given, but no full match", {
  candidate <- "abc_a@example.org"
  expect_null(token_match(candidate, "def_a@example.org"))
  expect_null(token_match(candidate, "abc_b@example.org"))
  expect_null(token_match(candidate, "a@example.org"))
  expect_null(token_match(candidate, "abc"))
  expect_null(token_match(candidate, "abc_"))
})

test_that("token_match() returns NULL if no email and no short hash match", {
  expect_null(token_match("abc_", "def_a@example.org"))
  expect_null(token_match("abc_*", "def_a@example.org"))
})

test_that("token_match() scolds but returns short hash match when non-interactive", {
  withr::local_options(list(rlang_interactive = FALSE))

  one_existing <- "abc_a@example.com"
  two_existing <- c(one_existing, "abc_b@example.com")

  expect_output(
    m <- token_match("abc_", one_existing),
    "modify your code or options"
  )
  expect_identical(m, one_existing)

  expect_output(
    m <- token_match("abc_*", one_existing),
    "modify your code or options"
  )
  expect_identical(m, one_existing)

  expect_output(
    m <- token_match("abc_", two_existing),
    "first will be used"
  )
  expect_identical(m, one_existing)

  expect_output(
    m <- token_match("abc_*", two_existing),
    "first will be used"
  )
  expect_identical(m, one_existing)
})
# 1 short hash match, interactive
# >1 short hash match, interactive

# situation report ----------------------------------------------------------

test_that("gargle_oauth_sitrep() does not initiate cache establishment", {
  expect_output(
    cache <- gargle_oauth_sitrep(cache = FALSE),
    "No"
  )
  expect_null(cache)
})

test_that("gargle_oauth_sitrep() reports on specified cache", {
  tmp_cache <- file_temp()
  on.exit(dir_delete(tmp_cache))

  gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = tmp_cache
  )
  gargle2.0_token(
    email = "b@example.org",
    credentials = list(b = 2),
    cache = tmp_cache
  )

  expect_output(
    out <- gargle_oauth_sitrep(tmp_cache),
    "2 tokens found"
  )
  expect_is(out, "data.frame")
  expect_identical(nrow(out), 2L)
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

test_that("keep_hash_paths() works", {
  x <- c("aa_bb_cc", "a.md", "b.rds", "c.txt", "dd123_e@example.org")
  expect_identical(keep_hash_paths(x), x[c(1, 5)])
})

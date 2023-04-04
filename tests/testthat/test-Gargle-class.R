test_that("email is ingested correctly", {
  fauxen_email <- function(email = NULL) {
    gargle2.0_token(email = email, credentials = list(a = 1))$email
  }
  expect_null(fauxen_email())
  expect_null(fauxen_email(NULL))
  expect_equal(fauxen_email(NA), NA_character_)
  expect_equal(fauxen_email(FALSE), NA_character_)
  expect_equal(fauxen_email(TRUE), "*")
  expect_equal(fauxen_email("a@example.org"), "a@example.org")
})

test_that("email can be set in option", {
  fauxen_email <- function(email = NULL) {
    withr::with_options(
      list(gargle_oauth_email = email),
      gargle2.0_token(credentials = list(a = 1))$email
    )
  }
  expect_null(fauxen_email(NULL))
  expect_equal(fauxen_email(NA), NA_character_)
  expect_equal(fauxen_email(FALSE), NA_character_)
  expect_equal(fauxen_email(TRUE), "*")
  expect_equal(fauxen_email("a@example.org"), "a@example.org")
})

test_that("Attempt to initiate OAuth2 flow fails if non-interactive", {
  rlang::local_interactive(FALSE)
  expect_snapshot(gargle2.0_token(cache = FALSE), error = TRUE)
})

test_that("`email = NA`, `email = FALSE` means we don't consult the cache", {
  cache_folder <- path_temp("email-na-test")
  withr::defer(dir_delete(cache_folder))
  local_interactive(FALSE)

  # make sure there's one token in the cache and that, by default, we use it
  fauxen_in <- gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1),
    cache = cache_folder
  )
  # can't use with_gargle_verbosity() here, because we use
  # local_gargle_verbosity("info") in token_match(), to force the user to
  # see messaging about auto-discovery
  suppressMessages(
    fauxen_out <- gargle2.0_token(cache = cache_folder)
  )
  expect_gargle2.0_token(fauxen_in, fauxen_out)

  # `email = NA` and `email = FALSE` prevent the cache from being consulted
  expect_snapshot(
    gargle2.0_token(email = NA, cache = cache_folder),
    error = TRUE
  )
  expect_snapshot(
    gargle2.0_token(email = FALSE, cache = cache_folder),
    error = TRUE
  )
})

test_that("Gargle2.0 prints nicely", {
  fauxen <- gargle2.0_token(
    email = "a@example.org",
    app = httr::oauth_app("APPNAME", key = "KEY", secret = "SECRET"),
    credentials = list(a = 1),
    cache = FALSE
  )
  expect_snapshot(print(fauxen))
})

test_that("we reject redirect URIs from conventional OOB for pseudo-OOB flow", {
  expect_snapshot(
    error = TRUE,
    select_pseudo_oob_value("urn:ietf:wg:oauth:2.0:oob")
  )
  expect_error(
    select_pseudo_oob_value("urn:ietf:wg:oauth:2.0:oob:auto"),
    class = "gargle_error"
  )
  expect_error(
    select_pseudo_oob_value("oob"),
    class = "gargle_error"
  )
})

test_that("we reject local web server redirect URIs for pseudo-OOB flow", {
  expect_snapshot(
    error = TRUE,
    select_pseudo_oob_value("http://localhost")
  )
  expect_error(
    select_pseudo_oob_value("http://localhost:4000"),
    class = "gargle_error"
  )
  expect_error(
    select_pseudo_oob_value("http://127.0.0.1:1410"),
    class = "gargle_error"
  )
})

test_that("we reject non-https redirect URIs for pseudo-OOB flow", {
  expect_error(
    select_pseudo_oob_value("http://example.com/google-callback/blah.html"),
    class = "gargle_error"
  )
})

test_that("we insist on finding exactly one redirect URI for pseudo-OOB flow", {
  redirect_uris <- c(
    "https://example.com/google-callback/one.html",
    "https://example.com/google-callback/two.html"
  )
  expect_snapshot(error = TRUE, select_pseudo_oob_value(redirect_uris))
})

test_that("we can identify the redirect URI suitable for pseudo-OOB flow", {
  redirect_uris <- c(
    "http://localhost:8111/",
    "http://localhost:8111",
    "http://127.0.0.1:8100/",
    "https://codepen.io/USER/full/abcdef123456"
  )
  expect_equal(select_pseudo_oob_value(redirect_uris), redirect_uris[4])
})

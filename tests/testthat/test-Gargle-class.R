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
  expect_error(gargle2.0_token(cache = FALSE), "requires an interactive session")
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
  expect_error(
    gargle2.0_token(email = NA, cache = cache_folder),
    "OAuth2 flow requires an interactive session"
  )
  expect_error(
    gargle2.0_token(email = FALSE, cache = cache_folder),
    "OAuth2 flow requires an interactive session"
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

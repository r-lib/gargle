test_that("email is ingested correctly", {
  fauxen_email <- function(email = NULL) {
    gargle2.0_token(email = email, credentials = list(a = 1))$email
  }
  expect_null(fauxen_email())
  expect_null(fauxen_email(NULL))
  expect_null(fauxen_email(NA))
  expect_null(fauxen_email(FALSE))
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
  expect_null(fauxen_email(NA))
  expect_null(fauxen_email(FALSE))
  expect_equal(fauxen_email(TRUE), "*")
  expect_equal(fauxen_email("a@example.org"), "a@example.org")
})

test_that("Attempt to initiate OAuth2 flow fails if non-interactive", {
  rlang::local_interactive(FALSE)
  expect_error(gargle2.0_token(cache = FALSE), "requires an interactive session")
})


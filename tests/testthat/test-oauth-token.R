test_that("email is ingested correctly", {
  fauxen_email <- function(email = NULL) {
    gargle2.0_token(email = email, credentials = list(a = 1))$email
  }
  expect_null(fauxen_email())
  expect_null(fauxen_email(NULL))
  expect_null(fauxen_email(NA))
  expect_null(fauxen_email(FALSE))
  expect_identical(fauxen_email(TRUE), "*")
  expect_identical(fauxen_email("a@example.org"), "a@example.org")
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
  expect_identical(fauxen_email(TRUE), "*")
  expect_identical(fauxen_email("a@example.org"), "a@example.org")
})

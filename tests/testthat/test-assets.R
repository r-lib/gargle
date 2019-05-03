context("package options and built-in objects")

test_that("default options", {
  withr::local_options(list(
    gargle_oauth_cache = NULL,
    gargle_oob_default = NULL,
    gargle_oauth_email = NULL,
    gargle_quiet       = NULL
  ))
  expect_identical(gargle_oauth_cache(), NA)
  expect_false(gargle_oob_default())
  expect_null(gargle_oauth_email())
  expect_true(gargle_quiet())
})

test_that("tidyverse oauth app", {
  oa <- tidyverse_app()
  expect_s3_class(oa, "oauth_app")
  expect_identical(oa$appname, "tidyverse")
})

test_that("gargle oauth app", {
  oa <- gargle_app()
  expect_s3_class(oa, "oauth_app")
  expect_identical(oa$appname, "gargle-demo")
})

test_that("tidyverse API key", {
  key <- tidyverse_api_key()
  expect_true(is_string(key))
})

test_that("gargle API key", {
  key <- gargle_api_key()
  expect_true(is_string(key))
})

context("package options and built-in objects")

test_that("default options", {
  expect_identical(getOption("gargle.oauth_cache"), NA)
  expect_false(getOption("gargle.oob_default"))
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

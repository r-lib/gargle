test_that("default options", {
  withr::local_options(list(
    gargle_oauth_cache = NULL,
    gargle_oob_default = NULL, httr_oob_default = NULL,
    gargle_oauth_email = NULL,
    gargle_quiet       = NULL
  ))
  expect_identical(gargle_oauth_cache(), NA)
  expect_false(gargle_oob_default())
  expect_null(gargle_oauth_email())
  expect_true(gargle_quiet())
})

test_that("gargle_oob_default() consults gargle's option before httr's", {
  withr::local_options(list(
    gargle_oob_default = TRUE,
    httr_oob_default = FALSE
  ))
  expect_true(gargle_oob_default())
})

test_that("gargle_oob_default() consults httr's option", {
  withr::local_options(list(
    gargle_oob_default = NULL,
    httr_oob_default = TRUE
  ))
  expect_true(gargle_oob_default())
})

test_that("gargle API key", {
  key <- gargle_api_key()
  expect_true(is_string(key))
})

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

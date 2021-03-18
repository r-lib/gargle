test_that("gargle_verbosity() defaults to 'info'", {
  withr::local_options(list(
    gargle_verbosity = NULL,
    gargle_quiet = NULL
  ))
  expect_equal(gargle_verbosity(), "info")
})

test_that("gargle_verbosity() validates the value it finds", {
  withr::local_options(list(gargle_verbosity = TRUE))
  expect_snapshot_error(gargle_verbosity())
})

test_that("gargle_verbosity() accomodates people using the old option", {
  withr::local_options(list(
    gargle_verbosity = NULL,
    gargle_quiet = FALSE
  ))
  expect_snapshot(
    out <- gargle_verbosity()
  )
  expect_equal(out, "debug")
})

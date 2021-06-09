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

test_that("gargle_info() works", {
  blah <- "BLAH"

  local_gargle_verbosity("debug")
  expect_snapshot(gargle_info(c("aa {.field {blah}} bb", "cc {.emph xyz} dd")))

  local_gargle_verbosity("info")
  expect_snapshot(gargle_info(c("ee {.field {blah}} ff", "gg {.emph xyz} hh")))

  local_gargle_verbosity("silent")
  expect_snapshot(gargle_info(c("ii {.field {blah}} jj", "kk {.emph xyz} ll")))
})

test_that("gargle_debug() works", {
  foo <- "FOO"

  local_gargle_verbosity("debug")
  expect_snapshot(gargle_debug(c("11 {.field {foo}} 22", "33 {.file a/b/c} 44")))

  local_gargle_verbosity("info")
  expect_snapshot(gargle_debug(c("55 {.field {foo}} 66", "77 {.file a/b/c} 88")))

  local_gargle_verbosity("silent")
  expect_snapshot(gargle_debug(c("99 {.field {foo}} 00", "11 {.file a/b/c} 22")))
})

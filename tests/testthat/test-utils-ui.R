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
  expect_snapshot(gargle_debug(c(
    "11 {.field {foo}} 22",
    "33 {.file a/b/c} 44"
  )))

  local_gargle_verbosity("info")
  expect_snapshot(gargle_debug(c(
    "55 {.field {foo}} 66",
    "77 {.file a/b/c} 88"
  )))

  local_gargle_verbosity("silent")
  expect_snapshot(gargle_debug(c(
    "99 {.field {foo}} 00",
    "11 {.file a/b/c} 22"
  )))
})

test_that("bulletize() works", {
  expect_snapshot(cli::cli_bullets(bulletize(letters)))
  expect_snapshot(cli::cli_bullets(bulletize(letters, bullet = "x")))
  expect_snapshot(cli::cli_bullets(bulletize(letters, n_show = 2)))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:6])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:7])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:8])))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:6], n_fudge = 0)))
  expect_snapshot(cli::cli_bullets(bulletize(letters[1:8], n_fudge = 3)))
})

# menu(), but based on readline() + cli and mockable ---------------------------

test_that("cli_menu() basic usage", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    cli_menu(
      "Found multiple thingies.",
      "Which one do you want to use?",
      glue("label {head(letters, 3)}")
    )
  }

  expect_snapshot(cli_menu_with_mock(1))
})

test_that("cli_menu() does not infinite loop with invalid mocked input", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    cli_menu(
      "Found multiple thingies.",
      "Which one do you want to use?",
      glue("label {head(letters, 3)}")
    )
  }

  expect_snapshot(cli_menu_with_mock("nope"), error = TRUE)
})

test_that("cli_menu() can work through multiple valid mocked inputs", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    header <- "Found multiple thingies."
    prompt <- "Which one do you want to use?"
    choices <- glue("label {1:3}")
    first <- cli_menu(header, prompt, choices)
    second <- cli_menu(header, prompt, choices)
    c(first, second)
  }

  expect_snapshot(
    out <- cli_menu_with_mock(c(1, 3))
  )
  expect_equal(out, c(1, 3))
})

test_that("cli_menu(), request exit via 0", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    cli_menu(
      "Found multiple thingies.",
      "Which one do you want to use?",
      glue("label {head(letters, 3)}")
    )
  }

  expect_snapshot(error = TRUE, cli_menu_with_mock(0))
})

test_that("cli_menu(exit =) works", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    cli_menu(
      header = "Hey we need to talk.",
      prompt = "What do you want to do?",
      choices = c(
        "Give up",
        "Some other thing"
      ),
      exit = 1
    )
  }

  expect_snapshot(error = TRUE, cli_menu_with_mock(1))
  expect_snapshot(cli_menu_with_mock(2))
})

test_that("cli_menu() inline markup and environment passing", {
  cli_menu_with_mock <- function(x) {
    local_user_input(x)
    verb <- "talk"
    action <- "do"
    pkg_name <- "nifty"
    cli_menu(
      header = "Hey we need to {.str {verb}}.",
      prompt = "What do you want to {.str {action}}?",
      choices = c(
        "Send email to {.email jane@example.com}",
        "Install the {.pkg {pkg_name}} package"
      )
    )
  }
  expect_snapshot(cli_menu_with_mock(1))
})

test_that("cli_menu() not_interactive, many strings, chained error", {
  wrapper_fun <- function() {
    local_interactive(FALSE)
    things <- glue("thing {1:3}")
    cli_menu(
      header = "Multiple things found.",
      prompt = "Which one do you want to use?",
      choices = things,
      not_interactive = c(
        i = "Use {.arg thingy} to specify one of {.str {things}}."
      )
    )
  }
  expect_snapshot(wrapper_fun(), error = TRUE)
})

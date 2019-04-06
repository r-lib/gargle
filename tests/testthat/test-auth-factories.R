context("Authorization function factories.")

test_that("make_auth returns the expected function.", {
  test_drive_auth <- make_auth(
    pkg_name = "googledrive",
    scopes = "https://www.googleapis.com/auth/drive",
    error_message = "Can't get Google credentials.\n Are you running googledrive in a non-interactive session? Consider:\n   * `drive_deauth()` to prevent the attempt to get credentials.\n   * Call `drive_auth()` directly with all necessary specifics.\n"
  )
  drive_auth <- function(email = NULL,
                              path = NULL,
                              scopes = "https://www.googleapis.com/auth/drive",
                              cache = getOption("gargle.oauth_cache"),
                              use_oob = getOption("gargle.oob_default")) {
    cred <- gargle::token_fetch(
      scopes = scopes,
      app = .auth$app,
      email = email,
      path = path,
      package = "googledrive",
      cache = cache,
      use_oob = use_oob
    )
    if (!gargle::is_legit_token(cred, verbose = TRUE)) {
      error_message <- paste(
        "Can't get Google credentials.\n",
        "Are you running googledrive in a non-interactive session? Consider:\n",
        "  * `drive_deauth()` to prevent the attempt to get credentials.\n",
        "  * Call `drive_auth()` directly with all necessary specifics.\n"
      )
      stop(
        error_message,
        call. = FALSE
      )
    }
    .auth$set_cred(cred)
    .auth$set_auth_active(TRUE)

    invisible()
  }

  expect_identical(formals(test_drive_auth), formals(drive_auth))

  # The body isn't strictly identical, but is equivalent.
  # The first two parts are identical.
  expect_identical(body(test_drive_auth)[[1]], body(drive_auth)[[1]])
  expect_identical(body(test_drive_auth)[[2]], body(drive_auth)[[2]])

  # The error_message is where things fall slightly apart.
  expect_identical(body(test_drive_auth)[[3]][[1]], body(drive_auth)[[3]][[1]])
  expect_identical(body(test_drive_auth)[[3]][[2]], body(drive_auth)[[3]][[2]])

  # Specifically it's in this part.
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[1]],
         body(drive_auth)[[3]][[3]][[1]]
  )
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[2]][[1]],
         body(drive_auth)[[3]][[3]][[2]][[1]]
  )
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[2]][[2]],
         body(drive_auth)[[3]][[3]][[2]][[2]]
  )
  # The evaluated thing that's being assigned to error_message should be
  # identical.
  expect_identical(
    eval(body(test_drive_auth)[[3]][[3]][[2]][[3]]),
    eval(     body(drive_auth)[[3]][[3]][[2]][[3]])
  )

  # The rest is strictly identical.
  expect_identical(body(test_drive_auth)[[4]], body(drive_auth)[[4]])
  expect_identical(body(test_drive_auth)[[5]], body(drive_auth)[[5]])
  expect_identical(body(test_drive_auth)[[6]], body(drive_auth)[[6]])

  # Repeat tests for the googlesheets4 version.
  test_sheets_auth <- make_auth(
    pkg_name = "googlesheets4",
    scopes = "https://www.googleapis.com/auth/spreadsheets",
    error_message = paste(
      "Can't get Google credentials.\n",
      "Are you running googlesheets4 in a non-interactive session? Consider:\n",
      "  * sheets_deauth() to prevent the attempt to get credentials.\n",
      "  * Call sheets_auth() directly with all necessary specifics.\n"
    )
  )

  sheets_auth <- function(email = NULL,
                          path = NULL,
                          scopes = "https://www.googleapis.com/auth/spreadsheets",
                          cache = getOption("gargle.oauth_cache"),
                          use_oob = getOption("gargle.oob_default")) {
    cred <- gargle::token_fetch(
      scopes = scopes,
      app = .auth$app,
      email = email,
      path = path,
      package = "googlesheets4",
      cache = cache,
      use_oob = use_oob
    )
    if (!gargle::is_legit_token(cred, verbose = TRUE)) {
      error_message <- paste(
        "Can't get Google credentials.\n",
        "Are you running googlesheets4 in a non-interactive session? Consider:\n",
        "  * sheets_deauth() to prevent the attempt to get credentials.\n",
        "  * Call sheets_auth() directly with all necessary specifics.\n"
      )
      stop(
        error_message,
        call. = FALSE
      )
    }
    .auth$set_cred(cred)
    .auth$set_auth_active(TRUE)

    return(invisible())
  }

  expect_identical(formals(test_drive_auth), formals(drive_auth))

  # The body isn't strictly identical, but is equivalent.
  expect_equal(length(body(test_drive_auth)), length(body(drive_auth)))
  expect_length(body(test_drive_auth), 6)


  # The first two parts are identical.
  expect_identical(body(test_drive_auth)[[1]], body(drive_auth)[[1]])
  expect_identical(body(test_drive_auth)[[2]], body(drive_auth)[[2]])

  # The error_message is where things fall slightly apart.
  expect_identical(body(test_drive_auth)[[3]][[1]], body(drive_auth)[[3]][[1]])
  expect_identical(body(test_drive_auth)[[3]][[2]], body(drive_auth)[[3]][[2]])

  # Specifically it's in this part.
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[1]],
         body(drive_auth)[[3]][[3]][[1]]
  )
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[2]][[1]],
         body(drive_auth)[[3]][[3]][[2]][[1]]
  )
  expect_identical(
    body(test_drive_auth)[[3]][[3]][[2]][[2]],
         body(drive_auth)[[3]][[3]][[2]][[2]]
  )
  # The evaluated thing that's being assigned to error_message should be
  # identical.
  expect_identical(
    eval(body(test_drive_auth)[[3]][[3]][[2]][[3]]),
    eval(     body(drive_auth)[[3]][[3]][[2]][[3]])
  )

  # The rest is strictly identical.
  expect_identical(body(test_drive_auth)[[4]], body(drive_auth)[[4]])
  expect_identical(body(test_drive_auth)[[5]], body(drive_auth)[[5]])
  expect_identical(body(test_drive_auth)[[6]], body(drive_auth)[[6]])
})

test_that("make_deauth returns the expected function.", {
  test_drive_deauth <- make_deauth()
  drive_deauth <- function() {
    .auth$set_auth_active(FALSE)
    return(invisible())
  }
  expect_identical(formals(test_drive_deauth), formals(drive_deauth))
  expect_equal(length(body(test_drive_deauth)), length(body(drive_deauth)))
  expect_length(body(test_drive_deauth), 3)
  expect_identical(body(test_drive_deauth)[[1]], body(drive_deauth)[[1]])
  expect_identical(body(test_drive_deauth)[[2]], body(drive_deauth)[[2]])
  expect_identical(body(test_drive_deauth)[[3]], body(drive_deauth)[[3]])
})

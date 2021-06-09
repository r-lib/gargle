
test_that("'deleted_client' causes extra special feedback", {
  err <- list(
    error = "deleted_client",
    error_description = "The OAuth client was deleted."
  )

  expect_snapshot(
    gargle_refresh_failure(
      err,
      httr::oauth_app(appname = NULL, key = "KEY", secret = "SECRET")
    )
  )

  expect_snapshot(
    gargle_refresh_failure(
      err,
      httr::oauth_app(appname = "APPNAME", key = "KEY", secret = "SECRET")
    )
  )

  expect_snapshot(
    gargle_refresh_failure(
      err,
      httr::oauth_app(appname = "APPNAME", key = "KEY", secret = "SECRET"),
      package = "PACKAGE"
    )
  )

  expect_snapshot(
    gargle_refresh_failure(
      err,
      httr::oauth_app(appname = "fake-calliope", key = "KEY", secret = "SECRET")
    )
  )

  expect_snapshot(
    gargle_refresh_failure(
      err,
      httr::oauth_app(appname = "fake-calliope", key = "KEY", secret = "SECRET"),
      package = "PACKAGE"
    )
  )
})

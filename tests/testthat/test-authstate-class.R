test_that("inputs are checked when creating AuthState", {
  app <- httr::oauth_app("APPNAME", key = "KEY", secret = "SECRET")

  expect_error(
    init_AuthState(
      package = NULL,
      app = app,
      api_key = "API_KEY",
      auth_active = TRUE
    ),
    'is_string(package) is not TRUE',
    fixed = TRUE
  )
  expect_error(init_AuthState(app = "not_an_oauth_app"), 'is not TRUE')
  expect_error(init_AuthState(app = app, api_key = 1234), 'is not TRUE')
  expect_error(
    init_AuthState(app = app, api_key = "API_KEY", auth_active = NULL),
    'is not TRUE'
  )

  a <- init_AuthState(
    package = "PACKAGE",
    app = app,
    api_key = "API_KEY",
    auth_active = TRUE
  )
  expect_is(a, "AuthState")
})

test_that("AuthState app can be modified and cleared", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- init_AuthState(app = app, api_key = "API_KEY", auth_active = TRUE)
  expect_identical(a$app$appname, "AAA")

  app2 <- httr::oauth_app("BBB", key = "KEY", secret = "SECRET")
  a$set_app(app2)
  expect_identical(a$app$appname, "BBB")

  a$set_app(NULL)
  expect_null(a$app)
})

test_that("AuthState api_key can be modified and cleared", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- init_AuthState(app = app, api_key = "AAA", auth_active = TRUE)
  expect_identical(a$api_key, "AAA")

  a$set_api_key("BBB")
  expect_identical(a$api_key, "BBB")

  a$set_api_key(NULL)
  expect_null(a$api_key)
})

test_that("AuthState auth_active can be toggled", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- init_AuthState(app = app, api_key = "AAA", auth_active = TRUE)
  expect_true(a$auth_active)

  a$set_auth_active(FALSE)
  expect_false(a$auth_active)
})

test_that("AuthState supports basic handling of cred", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- init_AuthState(app = app, api_key = "A", auth_active = TRUE)

  a$set_cred("hi")
  expect_true(a$has_cred())
  expect_identical(a$get_cred(), "hi")
  a$clear_cred()
  expect_false(a$has_cred())
  a$set_cred("bye")
  expect_identical(a$get_cred(), "bye")
})

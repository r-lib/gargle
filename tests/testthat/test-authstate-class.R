context("test-authstate-class")

test_that("we are pedantic about inputs when creating AuthState", {
  expect_error(
    AuthState$new(package = NULL),
    'is_string(package) is not TRUE',
    fixed = TRUE
  )
  expect_error(AuthState$new(), '"app" is missing')

  app <- httr::oauth_app("APPNAME", key = "KEY", secret = "SECRET")
  expect_error(AuthState$new(app = app), '"api_key" is missing')

  expect_error(
    AuthState$new(app = app, api_key = "API_KEY"),
    '"auth_active" is missing'
  )

  a <- AuthState$new(
    package = "PACKAGE",
    app = app,
    api_key = "API_KEY",
    auth_active = TRUE
  )
  expect_is(a, "AuthState")
})

test_that("AuthState app can be modified", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- AuthState$new(app = app, api_key = "API_KEY", auth_active = TRUE)
  expect_identical(a$app$appname, "AAA")

  app2 <- httr::oauth_app("BBB", key = "KEY", secret = "SECRET")
  a$set_app(app2)
  expect_identical(a$app$appname, "BBB")
})

test_that("AuthState api_key can be modified", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- AuthState$new(app = app, api_key = "AAA", auth_active = TRUE)
  expect_identical(a$api_key, "AAA")

  a$set_api_key("BBB")
  expect_identical(a$api_key, "BBB")
})

test_that("AuthState auth_active can be toggled", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- AuthState$new(app = app, api_key = "AAA", auth_active = TRUE)
  expect_true(a$auth_active)

  a$set_auth_active(FALSE)
  expect_false(a$auth_active)
})

test_that("AuthState supports basic handling of cred", {
  app <- httr::oauth_app("AAA", key = "KEY", secret = "SECRET")
  a <- AuthState$new(app = app, api_key = "A", auth_active = TRUE, cred = "hi")

  expect_true(a$has_cred())
  expect_identical(a$get_cred(), "hi")
  a$clear_cred()
  expect_false(a$has_cred())
  a$set_cred("bye")
  expect_identical(a$get_cred(), "bye")
})

test_that("inputs are checked when creating AuthState", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET")

  expect_snapshot(
    init_AuthState(
      package = NULL,
      client = client,
      api_key = "API_KEY",
      auth_active = TRUE
    ),
    error = TRUE
  )
  expect_snapshot(init_AuthState(client = "not_an_oauth_client"), error = TRUE)
  expect_snapshot(init_AuthState(client = client, api_key = 1234), error = TRUE)
  expect_snapshot(
    init_AuthState(client = client, api_key = "API_KEY", auth_active = NULL),
    error = TRUE
  )

  a <- init_AuthState(
    package = "PACKAGE",
    client = client,
    api_key = "API_KEY",
    auth_active = TRUE
  )
  expect_s3_class(a, "AuthState")
})

test_that("AuthState client can be modified and cleared", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(client = client, api_key = "API_KEY", auth_active = TRUE)
  expect_equal(a$client$name, "AAA")

  client2 <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "BBB")
  a$set_client(client2)
  expect_equal(a$client$name, "BBB")

  a$set_client(NULL)
  expect_null(a$client)
})

test_that("AuthState api_key can be modified and cleared", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(client = client, api_key = "AAA", auth_active = TRUE)
  expect_equal(a$api_key, "AAA")

  a$set_api_key("BBB")
  expect_equal(a$api_key, "BBB")

  a$set_api_key(NULL)
  expect_null(a$api_key)
})

test_that("AuthState auth_active can be toggled", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(client = client, api_key = "AAA", auth_active = TRUE)
  expect_true(a$auth_active)

  a$set_auth_active(FALSE)
  expect_false(a$auth_active)
})

test_that("AuthState supports basic handling of cred", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(client = client, api_key = "AAA", auth_active = TRUE)

  a$set_cred("hi")
  expect_true(a$has_cred())
  expect_equal(a$get_cred(), "hi")
  a$clear_cred()
  expect_false(a$has_cred())
  a$set_cred("bye")
  expect_equal(a$get_cred(), "bye")
})

test_that("AuthState prints nicely", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(
    package = "PKG",
    client = client,
    api_key = "API_KEY",
    auth_active = TRUE
  )
  a$set_cred(structure("TOKEN", class = "some_sort_of_token"))
  expect_snapshot(print(a))
})

test_that("init_Authstate(app) argument is deprecated, but still works", {
  withr::local_options(lifecycle_verbosity = "warning")
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET")

  expect_snapshot(
    a <- init_AuthState(
      package = "PACKAGE",
      app = client,
      api_key = "API_KEY",
      auth_active = TRUE
    )
  )
  expect_s3_class(a, "AuthState")
  expect_s3_class(a$client, "gargle_oauth_client")
})

test_that("AuthState$new(app) is deprecated, but still works", {
  withr::local_options(lifecycle_verbosity = "warning")
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET")

  expect_snapshot(
    a <- AuthState$new(
      package = "PACKAGE",
      app = client,
      api_key = "API_KEY",
      auth_active = TRUE
    )
  )
  expect_s3_class(a, "AuthState")
  expect_s3_class(a$client, "gargle_oauth_client")
})

test_that("$set_app is deprecated, but still works", {
  withr::local_options(lifecycle_verbosity = "warning")

  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(
    client = client,
    # this just needs to be some package that is guaranteed to be installed, in
    # order to fully exercise the deprecation warning
    package = "rlang",
    api_key = "API_KEY",
    auth_active = TRUE
  )
  client2 <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "BBB")

  expect_snapshot(
    a$set_app(client2)
  )
  expect_equal(a$client$name, "BBB")
})

test_that("$app still returns the client", {
  client <- gargle_oauth_client(id = "CLIENT_ID", secret = "SECRET", name = "AAA")
  a <- init_AuthState(client = client, api_key = "API_KEY", auth_active = TRUE)
  expect_equal(a$app, client)
})

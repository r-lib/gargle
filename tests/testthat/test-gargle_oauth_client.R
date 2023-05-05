test_that("gargle_oauth_client() rejects bad input", {
  expect_snapshot(error = TRUE, gargle_oauth_client())
  expect_snapshot(error = TRUE, gargle_oauth_client(1234))
  expect_snapshot(error = TRUE, gargle_oauth_client(id = "ID"))
  expect_snapshot(error = TRUE, gargle_oauth_client(id = "ID", secret = 1234))
  expect_snapshot(
    error = TRUE,
    gargle_oauth_client("ID", "SECRET", type = "nope")
  )
})

test_that("gargle_oauth_client() has special handling for web clients", {
  expect_snapshot(
    error = TRUE,
    gargle_oauth_client("ID", "SECRET", type = "web")
  )
  expect_snapshot(
    gargle_oauth_client(
      "ID", "SECRET", type = "web",
      redirect_uris = c(
        "http://localhost:8111/",
        "http://127.0.0.1:8100/",
        "https://example.com/aaa/bbb/v"
      )
    )
  )
})

test_that("service account JSON throws an informative error", {
  expect_snapshot(
    error = TRUE,
    gargle_oauth_client_from_json(
      test_path("fixtures", "service-account-token.json")
    )
  )
})

# deprecated functions ----

test_that("oauth app from JSON", {
  withr::local_options(lifecycle_verbosity = "quiet")
  oa <- oauth_app_from_json(
    fs::path_package("gargle", "extdata", "client_secret_installed.googleusercontent.com.json")
  )
  expect_s3_class(oa, "oauth_app")
  expect_match(oa$appname, "^a_project")
  expect_equal(oa$secret, "ssshh-i-am-a-secret")
  expect_equal(oa$key, "abc.apps.googleusercontent.com")

  oa <- oauth_app_from_json(
    fs::path_package("gargle", "extdata", "client_secret_web.googleusercontent.com.json")
  )
  expect_s3_class(oa, "oauth_app")
  expect_match(oa$appname, "^a_project")
  expect_equal(oa$secret, "ssshh-i-am-a-secret")
  expect_equal(oa$key, "abc.apps.googleusercontent.com")
})


context("oauth-app")

test_that("oauth app from JSON", {
  oa <- oauth_app_from_json(
    test_path(
      "fixtures", "client_secret_123.googleusercontent.com.json"
    )
  )
  expect_s3_class(oa, "oauth_app")
  expect_identical(oa$appname, "a_project")
  expect_identical(oa$secret, "ssshh-i-am-a-secret")
  expect_identical(oa$key, "abc.apps.googleusercontent.com")
})

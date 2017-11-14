context("oauth-app")

test_that("oauth app, from JSON", {
  oa <- oauth_app(
    path = test_path(
      "test-files", "client_secret_123.googleusercontent.com.json"
    )
  )
  expect_s3_class(oa, "oauth_app")
  expect_identical(oa$appname, "a_project")
  expect_identical(oa$secret, "ssshh-i-am-a-secret")
  expect_identical(oa$key, "abc.apps.googleusercontent.com")
})

test_that("oauth app, not from JSON", {
  oa_gargle <- oauth_app(
    appname = "aaa",
    key = "keykeykey",
    secret = "secretsecret"
  )
  oa_httr <- httr::oauth_app(
    appname = "aaa",
    key = "keykeykey",
    secret = "secretsecret"
  )
  expect_identical(oa_gargle, oa_httr)
})

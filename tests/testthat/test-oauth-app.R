test_that("oauth app from JSON", {
  oa <- oauth_app_from_json(
    test_path(
      "fixtures", "client_secret_123.googleusercontent.com.json"
    )
  )
  expect_s3_class(oa, "oauth_app")
  expect_equal(oa$appname, "a_project")
  expect_equal(oa$secret, "ssshh-i-am-a-secret")
  expect_equal(oa$key, "abc.apps.googleusercontent.com")

  oa <- oauth_app_from_json(
    test_path(
      "fixtures", "client_secret_456.googleusercontent.com.json"
    )
  )
  expect_s3_class(oa, "oauth_app")
  expect_equal(oa$appname, "a_project")
  expect_equal(oa$secret, "ssshh-i-am-a-secret")
  expect_equal(oa$key, "abc.apps.googleusercontent.com")
})

test_that("JSON that is apparently not an oauth app triggers error", {
  nope <- jsonlite::toJSON(test_path("fixtures", "service-account-token.json"))
  expect_error(
    oauth_app_from_json(nope),
    "Can't find .* in the JSON"
  )
})

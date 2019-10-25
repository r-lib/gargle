test_that("credentials_app_default_path() returns the default application credentials path on non-Windows",
  with_mock(
    `gargle::is_windows` = function() FALSE,
    expect_equal(
      credentials_app_default_path(),
      path_home(".config", "gcloud", "application_default_credentials.json")
   )
  )
)

test_that("credentials_app_default_path() returns the default application credentials path on Windows",
  with_mock(
    `gargle::is_windows` = function() TRUE,
    expect_equal(
      credentials_app_default_path(),
      path_join(c("C:", "gcloud", "application_default_credentials.json"))
   )
  )
)

test_that("credentials_app_default_path() uses the CLOUDSDK_CONFIG environment variable", {
  config_path <- path_join(c("config", "path"))
  with_mock(
    Sys.getenv = function(key) {
      if (key == "CLOUDSDK_CONFIG") config_path else ""
    },
    expect_equal(
      credentials_app_default_path(),
      path_join(c(config_path, "application_default_credentials.json"))
    )
  )
})

test_that("credentials_app_default_path() uses the GOOGLE_APPLICATION_CREDENTIALS environment variable", {
  credentials_path <- path_join(c("path", "to", "credentials.json"))
  with_mock(
    Sys.getenv = function(key) {
      if (key == "GOOGLE_APPLICATION_CREDENTIALS") credentials_path else ""
    },
    expect_equal(credentials_app_default_path(), credentials_path)
  )
})

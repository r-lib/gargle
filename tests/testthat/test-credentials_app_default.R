test_that("credentials_app_default() uses user creds by default, not for drive", {
  path <- withr::local_tempfile(fileext = ".json")
  jsonlite::write_json(list(type = "authorized_user"), path, auto_unbox = TRUE)
  withr::local_envvar(GOOGLE_APPLICATION_CREDENTIALS = path)
  local_mocked_bindings(adc_user_token = function(info) "user token")

  expect_equal(credentials_app_default(), "user token")
  expect_null(
    credentials_app_default(scopes = "https://www.googleapis.com/auth/drive")
  )
})

test_that("credentials_app_default_path(), default, non-Windows", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = NA,
    CLOUDSDK_CONFIG = NA,
    APPDATA = NA,
    SystemDrive = NA
  ))
  local_mocked_bindings(is_windows = function() FALSE)
  expect_equal(
    credentials_app_default_path(),
    path_home(".config", "gcloud", "application_default_credentials.json")
  )
})

test_that("credentials_app_default_path(), default, Windows", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = NA,
    CLOUDSDK_CONFIG = NA,
    APPDATA = NA,
    SystemDrive = NA
  ))
  local_mocked_bindings(is_windows = function() TRUE)
  expect_equal(
    credentials_app_default_path(),
    path("C:", "gcloud", "application_default_credentials.json")
  )
})

test_that("credentials_app_default_path(), system drive, Windows", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = NA,
    CLOUDSDK_CONFIG = NA,
    APPDATA = NA,
    SystemDrive = "D:"
  ))
  local_mocked_bindings(is_windows = function() TRUE)
  expect_equal(
    credentials_app_default_path(),
    path("D:", "gcloud", "application_default_credentials.json")
  )
})

test_that("credentials_app_default_path(), APPDATA env var, Windows", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = NA,
    CLOUDSDK_CONFIG = NA,
    APPDATA = path("D:", "AppData"),
    SystemDrive = "D:"
  ))
  local_mocked_bindings(is_windows = function() TRUE)
  expect_equal(
    credentials_app_default_path(),
    path("D:", "AppData", "gcloud", "application_default_credentials.json")
  )
})

test_that("credentials_app_default_path(), CLOUDSDK_CONFIG env var", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = NA,
    CLOUDSDK_CONFIG = path("CLOUDSDK", "path")
  ))
  expect_equal(
    credentials_app_default_path(),
    path("CLOUDSDK", "path", "application_default_credentials.json")
  )
})

test_that("credentials_app_default_path(), GOOGLE_APPLICATION_CREDENTIALS env var", {
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = path("GAC", "path"),
    CLOUDSDK_CONFIG = path("CLOUDSDK", "path")
  ))
  expect_equal(
    credentials_app_default_path(),
    path("GAC", "path")
  )
})

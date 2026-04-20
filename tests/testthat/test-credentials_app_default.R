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

test_that("credentials_app_default() reports unsupported ADC types", {
  path <- withr::local_tempfile(fileext = ".json")
  writeLines(
    jsonlite::toJSON(
      list(type = "mystery_credentials"),
      auto_unbox = TRUE
    ),
    path
  )
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = path,
    CLOUDSDK_CONFIG = NA
  ))

  seen <- character()
  local_mocked_bindings(
    gargle_debug = function(text, .envir = parent.frame()) {
      seen <<- c(
        seen,
        vapply(
          text,
          function(x) cli::ansi_strip(cli::format_inline(x, .envir = .envir)),
          character(1)
        )
      )
    }
  )

  expect_null(credentials_app_default())
  expect_true(any(grepl(
    "ADC cred type is not supported",
    seen,
    fixed = TRUE
  )))
  expect_true(any(grepl("mystery_credentials", seen, fixed = TRUE)))
})

test_that("credentials_app_default() supports impersonated service accounts", {
  path <- withr::local_tempfile(fileext = ".json")
  writeLines(
    jsonlite::toJSON(
      list(
        type = "impersonated_service_account",
        delegates = list("projects/-/serviceAccounts/delegate@example.com"),
        service_account_impersonation_url = paste0(
          "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/",
          "impersonated@example.com"
        ),
        source_credentials = list(
          type = "authorized_user",
          client_id = "CLIENT_ID",
          client_secret = "CLIENT_SECRET",
          refresh_token = "REFRESH_TOKEN"
        )
      ),
      auto_unbox = TRUE
    ),
    path
  )
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = path,
    CLOUDSDK_CONFIG = NA
  ))

  source_token <- structure(list(source = TRUE), class = "Token2.0")
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    app_default_authorized_user_token = function(info, scope) {
      seen$source_credentials <- info
      seen$source_scope <- scope
      source_token
    },
    fetch_impersonated_service_account_access_token = function(
      source_token,
      impersonation_url,
      scope,
      delegates = NULL
    ) {
      seen$source_token <- source_token
      seen$impersonation_url <- impersonation_url
      seen$scope <- scope
      seen$delegates <- delegates
      list(
        accessToken = "ACCESS_TOKEN",
        expireTime = "2026-04-20T12:34:56Z"
      )
    }
  )

  out <- credentials_app_default("https://www.googleapis.com/auth/bigquery")

  expect_true(inherits(out, "ImpersonatedServiceAccountToken"))
  expect_identical(out$credentials$access_token, "ACCESS_TOKEN")
  expect_identical(out$credentials$expire_time, "2026-04-20T12:34:56Z")
  expect_equal(seen$source_credentials$type, "authorized_user")
  expect_identical(
    seen$source_scope,
    "https://www.googleapis.com/auth/cloud-platform"
  )
  expect_identical(seen$source_token, source_token)
  expect_identical(
    seen$impersonation_url,
    paste0(
      "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/",
      "impersonated@example.com:generateAccessToken"
    )
  )
  expect_equal(
    seen$scope,
    c(
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/userinfo.email"
    )
  )
  expect_equal(
    seen$delegates,
    list("projects/-/serviceAccounts/delegate@example.com")
  )
})

test_that("credentials_app_default() defaults impersonated ADC scopes to cloud-platform", {
  path <- withr::local_tempfile(fileext = ".json")
  writeLines(
    jsonlite::toJSON(
      list(
        type = "impersonated_service_account",
        service_account_impersonation_url = paste0(
          "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/",
          "impersonated@example.com"
        ),
        source_credentials = list(
          type = "authorized_user",
          client_id = "CLIENT_ID",
          client_secret = "CLIENT_SECRET",
          refresh_token = "REFRESH_TOKEN"
        )
      ),
      auto_unbox = TRUE
    ),
    path
  )
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = path,
    CLOUDSDK_CONFIG = NA
  ))

  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    app_default_authorized_user_token = function(...) {
      structure(list(), class = "Token2.0")
    },
    fetch_impersonated_service_account_access_token = function(
      source_token,
      impersonation_url,
      scope,
      delegates = NULL
    ) {
      seen$scope <- scope
      list(
        accessToken = "ACCESS_TOKEN",
        expireTime = "2026-04-20T12:34:56Z"
      )
    }
  )

  expect_no_error(credentials_app_default())
  expect_equal(
    seen$scope,
    c(
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/userinfo.email"
    )
  )
})

test_that("credentials_app_default() errors for unsupported impersonation sources", {
  path <- withr::local_tempfile(fileext = ".json")
  writeLines(
    jsonlite::toJSON(
      list(
        type = "impersonated_service_account",
        service_account_impersonation_url = paste0(
          "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/",
          "impersonated@example.com:generateAccessToken"
        ),
        source_credentials = list(type = "service_account")
      ),
      auto_unbox = TRUE
    ),
    path
  )
  withr::local_envvar(c(
    GOOGLE_APPLICATION_CREDENTIALS = path,
    CLOUDSDK_CONFIG = NA
  ))

  expect_error(
    credentials_app_default("https://www.googleapis.com/auth/cloud-platform"),
    "Unsupported impersonated service account source credential type"
  )
})


get_application_default_credentials_path <- function() {
  if (nzchar(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))) {
    return(path.expand(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")))
  }
  
  root <- ""
  if (nzchar(Sys.getenv("CLOUDSDK_CONFIG"))) {
    root <- Sys.getenv("CLOUDSDK_CONFIG")
  } else if (Sys.info()["sysname"] == "windows") {
    appdata <- Sys.getenv("APPDATA", file.path(Sys.getenv("SystemDrive", "C:"), "\\"))
    root <- file.path(appdata, "gcloud")
  } else {
    root <- path.expand(file.path("~", ".config", "gcloud"))
  }
  file.path(root, "application_default_credentials.json")
}

#' Fetch the ADC.
#' @export
get_application_default_credentials <- function(scopes, ...) {
  # In general, application default credentials only include the cloud-platform
  # scope. This means we need our scopes to be *implied* by the cloud-platform
  # scope, which is hard to validate; instead, we just approximate.
  valid_scopes <- c(
    'https://www.googleapis.com/auth/bigquery',
    'https://www.googleapis.com/auth/bigquery',
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/cloud-platform.readonly'
  )
  if (!all(scopes %in% valid_scopes)) {
    return(NULL)
  }
  path <- get_application_default_credentials_path()
  if (!file.exists(path)) {
    return(NULL)
  }

  info <- jsonlite::fromJSON(path)
  endpoint <- httr::oauth_endpoints("google")
  app <- httr::oauth_app("google", info$client_id, secret = info$client_secret)
  scope <- 'https://www.googleapis.com/auth/cloud.platform'
  token <- httr::Token2.0$new(endpoint = endpoint, app = app, credentials = list(refresh_token = info$refresh_token), params = list(scope = scope))
  token$refresh()
  token
}

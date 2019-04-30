credentials_app_default_path <- function() {
  if (nzchar(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"))) {
    return(path_expand(Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")))
  }

  pth <- "application_default_credentials.json"
  if (nzchar(Sys.getenv("CLOUDSDK_CONFIG"))) {
    pth <- c(Sys.getenv("CLOUDSDK_CONFIG"), pth)
  } else if (is_windows()) {
    appdata <- Sys.getenv("APPDATA", Sys.getenv("SystemDrive", "C:"))
    pth <- c(appdata, "gcloud", pth)
  } else {
    pth <- path_home(".config", "gcloud")
  }
  path_join(pth)
}

#' Fetch the Application Default Credentials
#'
#' @inheritParams token_fetch
#' @export
#' @family credential functions
credentials_app_default <- function(scopes, ...) {
  cat_line("trying credentials_app_default()")
  # In general, application default credentials only include the cloud-platform
  # scope.
  path <- credentials_app_default_path()
  if (!file_exists(path)) {
    return(NULL)
  }

  # The JSON file stored on disk can be either a user credential or a service
  # account.
  info <- jsonlite::fromJSON(path)
  if (info$type == "authorized_user") {
    # In the case of *user* credentials stored as the application default, only
    # the cloud-platform scope will be included. This means we need our scopes to
    # be *implied* by the cloud-platform scope, which is hard to validate;
    # instead, we just approximate.
    valid_scopes <- c(
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/cloud-platform.readonly"
    )
    if (!all(scopes %in% valid_scopes)) {
      return(NULL)
    }
    endpoint <- httr::oauth_endpoints("google")
    app <- httr::oauth_app("google", info$client_id, secret = info$client_secret)
    scope <- "https://www.googleapis.com/auth/cloud.platform"
    token <- httr::Token2.0$new(
        endpoint = endpoint,
        app = app,
        credentials = list(refresh_token = info$refresh_token),
        # ADC is already cached.
        cache_path = FALSE,
        params = list(scope = scope)
    )
    token$refresh()
    token
  } else {
    credentials_service_account(scopes, path)
  }
}

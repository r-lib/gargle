#' Load Application Default Credentials
#'
#' @description

#' Loads credentials from a file identified via a search strategy known as
#' Application Default Credentials (ADC). The hope is to make auth "just work"
#' for someone working on Google-provided infrastructure or who has used Google
#' tooling to get started, such as the [`gcloud` command line
#' tool](https://cloud.google.com/sdk/gcloud).
#'
#' A sequence of paths is consulted, which we describe here, with some abuse of
#' notation. ALL_CAPS represents the value of an environment variable and `%||%`
#' is used in the spirit of a [null coalescing
#' operator](https://en.wikipedia.org/wiki/Null_coalescing_operator).

#' ```
#' GOOGLE_APPLICATION_CREDENTIALS
#' CLOUDSDK_CONFIG/application_default_credentials.json
#' # on Windows:
#' (APPDATA %||% SystemDrive %||% C:)\gcloud\application_default_credentials.json
#' # on not-Windows:
#' ~/.config/gcloud/application_default_credentials.json
#' ```

#' If the above search successfully identifies a JSON file, it is parsed and
#' ingested as a service account, an external account ("workload identity
#' federation"), or a user account. Literally, if the JSON describes a service
#' account, we call [credentials_service_account()] and if it describes an
#' external account, we call [credentials_external_account()].
#'
#' @inheritParams credentials_service_account
#'
#' @seealso

#' * <https://cloud.google.com/docs/authentication#adc>

#' * <https://cloud.google.com/sdk/docs/>

#' @return An [`httr::TokenServiceAccount`][httr::Token-class], a [`WifToken`],
#'   an [`httr::Token2.0`][httr::Token-class] or `NULL`.

#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' credentials_app_default()
#' }
credentials_app_default <- function(scopes = NULL, ..., subject = NULL) {
  gargle_debug("trying {.fun credentials_app_default}")
  # In general, application default credentials only include the cloud-platform
  # scope.
  path <- credentials_app_default_path()
  if (!file_exists(path)) {
    return(NULL)
  }
  gargle_debug(c("file exists at ADC path:", "{.file {path}}"))

  info <- jsonlite::fromJSON(path, simplifyVector = FALSE)
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
    if (is.null(scopes) || !all(scopes %in% valid_scopes)) {
      return(NULL)
    }
    gargle_debug("ADC cred type: {.val authorized_user}")
    app <- httr::oauth_app(
      "google",
      info$client_id,
      secret = info$client_secret
    )
    scope <- "https://www.googleapis.com/auth/cloud.platform"
    token <- httr::Token2.0$new(
      endpoint = gargle_oauth_endpoint(),
      app = app,
      credentials = list(refresh_token = info$refresh_token),
      # ADC is already cached.
      cache_path = FALSE,
      params = list(scope = scope, as_header = TRUE)
    )
    token$refresh()
    token
  } else if (info$type == "service_account") {
    gargle_debug("ADC cred type: {.val service_account}")
    credentials_service_account(scopes, path = path, subject = subject)
  } else if (info$type == "external_account") {
    gargle_debug("ADC cred type: {.val external_account}")
    credentials_external_account(scopes, path = path)
  }
}

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
    pth <- path_home(".config", "gcloud", pth)
  }
  path_join(pth)
}

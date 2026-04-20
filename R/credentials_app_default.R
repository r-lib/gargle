#' Load Application Default Credentials
#'
#' @description

#' Loads credentials from a file identified via a search strategy known as
#' Application Default Credentials (ADC). The hope is to make auth "just work"
#' for someone working on Google-provided infrastructure or who has used Google
#' tooling to get started, such as the [`gcloud` command line
#' tool](https://docs.cloud.google.com/sdk/gcloud).
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
#' ingested as a service account, an impersonated service account, an external
#' account ("workload identity federation"), or a user account. Literally, if
#' the JSON describes a service account, we call [credentials_service_account()]
#' and if it describes an external account, we call
#' [credentials_external_account()].
#'
#' @inheritParams credentials_service_account
#'
#' @seealso

#' * <https://docs.cloud.google.com/docs/authentication>

#' * <https://docs.cloud.google.com/sdk/docs>

#' @return An [`httr::TokenServiceAccount`][httr::Token-class], an impersonated
#'   service account token, a [`WifToken`], an
#'   [`httr::Token2.0`][httr::Token-class] or `NULL`.

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
    app_default_authorized_user_token(
      info,
      scope = "https://www.googleapis.com/auth/cloud.platform"
    )
  } else if (info$type == "service_account") {
    gargle_debug("ADC cred type: {.val service_account}")
    credentials_service_account(scopes, path = path, subject = subject)
  } else if (info$type == "external_account") {
    gargle_debug("ADC cred type: {.val external_account}")
    credentials_external_account(scopes, path = path)
  } else if (info$type == "impersonated_service_account") {
    gargle_debug("ADC cred type: {.val impersonated_service_account}")
    credentials_impersonated_service_account(scopes, path = path)
  } else {
    gargle_debug("ADC cred type is not supported: {.val {info$type}}")
    NULL
  }
}

app_default_authorized_user_token <- function(
  info,
  scope = "https://www.googleapis.com/auth/cloud.platform"
) {
  app <- httr::oauth_app(
    "google",
    info$client_id,
    secret = info$client_secret
  )
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
}

credentials_impersonated_service_account <- function(
  scopes = NULL,
  path = "",
  ...
) {
  if (is.null(scopes)) {
    scopes <- "https://www.googleapis.com/auth/cloud-platform"
  }
  scopes <- normalize_scopes(add_email_scope(scopes))

  token <- oauth_impersonated_service_account(path = path, scopes = scopes)

  if (
    is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)
  ) {
    NULL
  } else {
    gargle_debug("service account email: {.email {token_email(token)}}")
    token
  }
}

oauth_impersonated_service_account <- function(
  path = "",
  scopes = "https://www.googleapis.com/auth/cloud-platform"
) {
  info <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  if (!identical(info[["type"]], "impersonated_service_account")) {
    gargle_debug(
      "JSON does not appear to represent an impersonated service account"
    )
    return()
  }

  params <- c(
    list(scopes = scopes),
    info,
    as_header = TRUE
  )
  ImpersonatedServiceAccountToken$new(params = params)
}

ImpersonatedServiceAccountToken <- R6::R6Class(
  "ImpersonatedServiceAccountToken",
  inherit = httr::Token2.0,
  list(
    initialize = function(params = list()) {
      gargle_debug("ImpersonatedServiceAccountToken initialize")
      params$scope <- params$scopes
      self$params <- params

      self$init_credentials()
    },
    init_credentials = function() {
      gargle_debug("ImpersonatedServiceAccountToken init_credentials")
      creds <- init_oauth_impersonated_service_account(params = self$params)
      names(creds) <- google_api_token_snake_case(names(creds))
      self$credentials <- creds
      self
    },
    refresh = function() {
      gargle_debug("ImpersonatedServiceAccountToken refresh")
      self$init_credentials()
    },
    format = function(...) {
      x <- list(
        scopes = commapse(base_scope(self$params$scope)),
        credentials = commapse(names(self$credentials))
      )
      c(
        cli::cli_format_method(
          cli::cli_h1("<ImpersonatedServiceAccountToken (via {.pkg gargle})>")
        ),
        glue("{fr(names(x))}: {fl(x)}")
      )
    },
    print = function(...) {
      cli::cat_line(self$format())
    },
    can_refresh = function() {
      TRUE
    },
    cache = function() self,
    load_from_cache = function() self,
    validate = function() {},
    revoke = function() {}
  )
)

init_oauth_impersonated_service_account <- function(params) {
  source_credentials <- params[["source_credentials"]]
  source_credentials_type <- source_credentials[["type"]]

  if (!identical(source_credentials_type, "authorized_user")) {
    gargle_abort(
      c(
        "Unsupported impersonated service account source credential type.",
        "i" = "Expected {.val authorized_user}, not {.val {source_credentials_type}}."
      )
    )
  }

  source_token <- app_default_authorized_user_token(
    source_credentials,
    scope = "https://www.googleapis.com/auth/cloud-platform"
  )

  fetch_impersonated_service_account_access_token(
    source_token = source_token,
    impersonation_url = normalize_impersonation_url(
      params[["service_account_impersonation_url"]]
    ),
    scope = params[["scope"]],
    delegates = params[["delegates"]]
  )
}

fetch_impersonated_service_account_access_token <- function(
  source_token,
  impersonation_url,
  scope = "https://www.googleapis.com/auth/cloud-platform",
  delegates = NULL
) {
  req <- list(
    method = "POST",
    url = impersonation_url,
    body = rlang::compact(list(
      scope = scope,
      delegates = delegates
    )),
    token = source_token
  )
  resp <- request_make(req)
  response_process(resp)
}

normalize_impersonation_url <- function(x) {
  suffix <- ":generateAccessToken"
  if (grepl(paste0(suffix, "$"), x)) {
    x
  } else {
    paste0(x, suffix)
  }
}

google_api_token_snake_case <- function(x) {
  gsub("([a-z0-9])([A-Z])", "\\1_\\L\\2", x, perl = TRUE)
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

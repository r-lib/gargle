#' Get a token using Github Actions
#'
#' @description

#' `r lifecycle::badge('experimental')`
#'
#' @inheritParams token_fetch

#' @param project_id The google cloud project id
#' @param workload_identity_provider The workload identity provider
#' @param service_account The service account email address
#' @param lifetime Lifespan of token in seconds as a string `"300s"`
#' @param scopes Requested scopes for the access token
#'

#' @seealso There is some setup required in GCP to enable this auth flow.
#'   This function reimplements the `google-github-actions/auth`. The
#'   documentation for that workflow provides instructions on the setup steps.

#' * <https://github.com/google-github-actions/auth?tab=readme-ov-file#indirect-wif>

#' @return A [WifToken()] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' credentials_github_actions(
#'   project_id = "project-id-12345",
#'   workload_identity_provider = "projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider"
#'   service_account = "my-service-account@my-project.iam.gserviceaccount.com",
#'   scopes = "https://www.googleapis.com/auth/drive.file"
#' )
#' }
credentials_github_actions <- function(
    project_id,
    workload_identity_provider,
    service_account,
    lifetime = "300s",
    scopes = "https://www.googleapis.com/auth/drive.file",
    ...) {
  gargle_debug("trying {.fun credentials_github_actions}")
  if (!detect_github_actions() || is.null(scopes)) {
    return(NULL)
  }

  scopes <- normalize_scopes(add_email_scope(scopes))

  token <- oauth_gha_token(
    project_id = project_id,
    workload_identity_provider = workload_identity_provider,
    service_account = service_account,
    lifetime = lifetime,
    scopes = scopes,
    ...
  )

  if (is.null(token$credentials$access_token) ||
    !nzchar(token$credentials$access_token)) {
    NULL
  } else {
    gargle_debug("service account email: {.email {token_email(token)}}")
    token
  }
}

#' Generate OAuth token for an external account on Github Actions
#'
#' @inheritParams credentials_github_actions
#' @param universe Set the domain for the endpoints
#'
#' @keywords internal
#' @export
oauth_gha_token <- function(project_id,
                            workload_identity_provider,
                            service_account,
                            lifetime,
                            scopes = "https://www.googleapis.com/auth/drive.file",
                            id_token_url = Sys.getenv("ACTIONS_ID_TOKEN_REQUEST_URL"),
                            id_token_request_token = Sys.getenv("ACTIONS_ID_TOKEN_REQUEST_TOKEN")) {
  if (id_token_url == "" || id_token_request_token == "") {
    gargle_abort(paste0(
      "GitHub Actions did not inject $ACTIONS_ID_TOKEN_REQUEST_TOKEN or ",
      "$ACTIONS_ID_TOKEN_REQUEST_URL into this job. This most likely means the ",
      "GitHub Actions workflow permissions are incorrect, or this job is being ",
      "run from a fork. For more information, please see ",
      "https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token"
    ))
  }

  params <- list(
    scopes = scopes, # this is $scopes but WifToken$new() copies it to $scope
    lifetime = lifetime,
    id_token_url = id_token_url,
    id_token_request_token = id_token_request_token,
    github_actions = TRUE,
    token_url = "https://sts.googleapis.com/v1/token",
    audience = paste0("//iam.googleapis.com/", workload_identity_provider),
    oidc_token_audience = paste0("https://iam.googleapis.com/", workload_identity_provider),
    subject_token_type = "urn:ietf:params:oauth:token-type:jwt",
    service_account_impersonation_url = paste0(
      "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/",
       service_account, 
       ":generateAccessToken"
      ),
      as_header = TRUE
  )
  WifToken$new(params = params)
}


detect_github_actions <- function() {
  if (Sys.getenv("GITHUB_ACTIONS") == "true") {
    return(TRUE)
  }
  gargle_debug("Environment variable GITHUB_ACTIONS is not 'true'")
  FALSE
}

gha_subject_token <- function(params) {
  gargle_debug("gha_subject_token")

  req <- list(
    method = "GET",
    url = params[["id_token_url"]],
    token = httr::add_headers(Authorization = paste("Bearer", params$id_token_request_token))
  )
  query_audience <- list(audience = params$oidc_token_audience)
  resp <- request_make(req, query = query_audience)
  response_process(resp)$value
}

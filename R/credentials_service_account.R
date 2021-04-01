#' Load a service account token
#'
#' @inheritParams token_fetch
#' @param path JSON identifying the service account, in one of the forms
#'   supported for the `txt` argument of [jsonlite::fromJSON()] (typically, a
#'   file path or JSON string).
#' @param subject An optional subject claim. Use for a service account which has
#'   been granted domain-wide authority by an administrator. Such delegation of
#'   domain-wide authority means that the service account is permitted to act on
#'   behalf of users, without their consent. Identify the user to impersonate
#'   via their email, e.g. `subject = "user@example.com"`.
#'
#' @seealso Additional reading on delegation of domain-wide authority:
#' * <https://developers.google.com/identity/protocols/oauth2/service-account#delegatingauthority>
#'
#' @return An [`httr::TokenServiceAccount`][httr::Token-class] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' token <- credentials_service_account(
#'   scopes = "https://www.googleapis.com/auth/userinfo.email",
#'   path = "/path/to/your/service-account.json"
#' )
#' }
credentials_service_account <- function(scopes = NULL,
                                        path = "",
                                        ...,
                                        subject = NULL) {
  gargle_debug("trying {.fun credentials_service_account}")
  info <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  if (!identical(info[["type"]], "service_account")) {
    gargle_debug(c(
      "JSON does not appear to represent a service account",
      "Did you provide the JSON for an OAuth client instead of for a \\
       service account?"
    ))
    return()
  }

  # I add email scope explicitly, whereas I don't need to do so in
  # credentials_user_oauth2(), because it's done in Gargle2.0$new().
  scopes <- normalize_scopes(add_email_scope(scopes))
  token <- httr::oauth_service_token(
    ## FIXME: not sure endpoint is truly necessary, but httr thinks it is.
    ## https://github.com/r-lib/httr/issues/576
    endpoint = gargle_oauth_endpoint(),
    secrets = info,
    scope = scopes,
    sub = subject
  )
  if (is.null(token$credentials$access_token) ||
    !nzchar(token$credentials$access_token)) {
    NULL
  } else {
    gargle_debug("service account email: {.email {token_email(token)}}")
    token
  }
}

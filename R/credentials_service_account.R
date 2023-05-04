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
#' @details Note that fetching a token for a service account requires a reasonably accurate system clock. For more information, see the vignette [How gargle gets
#' tokens](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html).
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

#' Check for a service account
#'
#' This pre-checks information provided to a high-level, user-facing auth
#' function, such as `googledrive::drive_auth()`, before passing the user's
#' input along to [token_fetch()], which is designed to silently swallow errors.
#' Some users are confused about the difference between an OAuth client and a
#' service account and they provide the (path to the) JSON for one, when the
#' other is what's actually expected.
#'
#' @inheritParams credentials_service_account
#' @param hint The relevant function to call for configuring an OAuth client.
#' @inheritParams rlang::abort
#'
#' @return Nothing. Exists purely to throw an error.
#' @export
#' @keywords internal
check_is_service_account <- function(path, hint, call = caller_env()) {
  if (is.null(path)) {
    return(invisible())
  }

  tryCatch(
    info <- jsonlite::fromJSON(path, simplifyVector = FALSE),
    error = NULL
  )

  if (!is.null(info) && !identical(info[["type"]], "service_account")) {
    cli::cli_abort(c(
      "{.arg path} does not represent a service account.",
      "Did you provide the JSON for an OAuth client instead of for a \\
         service account?",
      "Use {.fun {hint}} to configure the OAuth client."
      ),
      call = call
    )
  }
}

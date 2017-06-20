
#' Create a token for a user via the browser flow.
#' @param scopes List of scopes required for the returned token.
#' @param oauth_app `httr::oauth_app` to use for this token fetch. (Optional.)
#' @param ... Additional arguments (ignored)
#' @export
credentials_user_oauth2 <- function(scopes, oauth_app = NULL, ...) {

  app <- httr::oauth_app(
    "google",
    key = "603366585132-nku3fbd298ma3925l12o2hq0cc1v8u11.apps.googleusercontent.com",
    secret = "as_N12yfWLRL9RMz5nVpgCZt"
  )
  token <- httr::oauth2.0_token(
    endpoint = httr::oauth_endpoints("google"),
    app = app,
    scope = scopes
  )
  token
}

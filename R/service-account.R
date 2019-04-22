#' Create a token for a Google service account.
#'
#' @param scopes List of scopes required for the returned token.
#' @param path Path to the downloaded JSON file
#' @param ... Additional arguments (ignored)
#' @return A `httr::TokenServiceAccount` or `NULL`.
#' @export
credentials_service_account <- function(scopes, path = "", ...) {
  cat_line("trying credentials_service_account()")
  info <- jsonlite::fromJSON(path)
  scopes <- normalize_scopes(add_email_scope(scopes))
  token <- httr::oauth_service_token(
    ## FIXME: not sure endpoint is truly necessary, but httr thinks it is.
    ## https://github.com/r-lib/httr/issues/576
    endpoint = gargle_outh_endpoint(),
    secrets = info,
    scope = scopes
  )
  if (is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)) {
    NULL
  } else {
    cat_line("email: ", get_email(token))
    token
  }
}

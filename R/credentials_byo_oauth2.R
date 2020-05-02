#' Load a user-provided token
#'
#' @description
#' This function does very little when called directly with a token:
#'   * If input has class `request`, i.e. it is a token that has been prepared
#'     with [httr::config()], the `auth_token` component is extracted. For
#'     example, such input could be produced by `googledrive::drive_token()`
#'     or `bigrquery::bq_token()`.
#'   * Checks that the input appears to be a Google OAuth token, based on
#'     the embedded `oauth_endpoint`.
#'   * Refreshes the token, if it's refreshable.
#'   * Returns its input.
#'
#' There is no point providing `scopes`. They are ignored because the `scopes`
#' associated with the token have already been baked in to the token itself and
#' gargle does not support incremental authorization. The main point of
#' `credentials_byo_oauth2()` is to allow `token_fetch()` (and packages that
#' wrap it) to accomodate a "bring your own token" workflow.
#'
#' This also makes it possible to obtain a token with one package and then
#' register it for use with another package. For example, the default scope
#' requested by googledrive is also sufficient for operations available in
#' googlesheets4. You could use a shared token like so:
#' ```
#' library(googledrive)
#' library(googlesheets4)
#' drive_auth(email = "jane_doe@example.com")
#' sheets_auth(token = drive_token())
#' # work with both packages freely now
#' ```
#'
#' @inheritParams token_fetch
#' @inheritParams token-info
#'
#' @return An [Token2.0][httr::Token-class].
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' # assume `my_token` is a Token2.0 object returned by a function such as
#' # httr::oauth2.0_token() or gargle::gargle2.0_token()
#' credentials_byo_oauth2(token = my_token)
#' }
credentials_byo_oauth2 <- function(scopes = NULL, token, ...) {
  ui_line("trying credentials_byo_oauth()")
  if (inherits(token, "request")) {
    token <- token$auth_token
  }
  stopifnot(inherits(token, "Token2.0"))

  if (!is.null(scopes)) {
    ui_line(
      "`scopes` cannot be specified when user brings their own OAuth token; ",
      "`scopes` are already implicit in the token"
    )
  }

  check_endpoint(token$endpoint)
  if (token$can_refresh()) {
    token$refresh()
  }
  token
}

check_endpoint <- function(endpoint) {
  stopifnot(inherits(endpoint, "oauth_endpoint"))
  urls <- endpoint[c("authorize", "access", "validate", "revoke")]
  urls_ok <- all(grepl("google", urls))
  if (!urls_ok) {
    abort("token doesn't use Google's OAuth endpoint")
  }
  endpoint
}

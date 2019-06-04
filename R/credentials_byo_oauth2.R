#' Load a user-provided token
#'
#' @description
#' This function does very little when called directly with a token:
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
#' @inheritParams token_fetch
#' @param token A token with class [Token2.0][httr::Token-class]
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
  cat_line("trying credentials_byo_oauth()")
  stopifnot(inherits(token, "Token2.0"))

  if (!is.null(scopes)) {
    cat_line(
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

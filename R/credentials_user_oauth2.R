#' Get an OAuth token for a user
#'
#' @description Consults the token cache for a suitable OAuth token and, if
#'   unsuccessful, gets a token via the browser flow. A cached token is suitable
#'   if it's compatible with the user's request in this sense:
#'   * OAuth client must be same.
#'   * Scopes must be same.
#'   * Email, if provided, must be same. If specified email is a glob pattern
#'     like `"*@example.com"`, email matching is done at the domain level.
#'

#' gargle is very conservative about using OAuth tokens discovered in the user's
#' cache and will generally seek interactive confirmation. Therefore, in a
#' non-interactive setting, it's important to explicitly specify the `"email"`
#' of the target account or to explicitly authorize automatic discovery. See
#' [gargle2.0_token()], which this function wraps, for more. Non-interactive use
#' also suggests it might be time to use a [service account
#' token][credentials_service_account] or [workload identity
#' federation][credentials_external_account].
#'

#' @param scopes A character vector of scopes to request. Pick from those listed
#'   at <https://developers.google.com/identity/protocols/oauth2/scopes>.
#'
#'   For certain token flows, the
#'   `"https://www.googleapis.com/auth/userinfo.email"` scope is unconditionally
#'   included. This grants permission to retrieve the email address associated
#'   with a token; gargle uses this to index cached OAuth tokens. This grants no
#'   permission to view or send email and is generally considered a low-value
#'   scope.
#' @inheritParams gargle2.0_token
#' @inheritDotParams gargle2.0_token -scope -app -package
#'
#' @return A [Gargle2.0] token.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' # Drive scope, built-in gargle demo client
#' scopes <- "https://www.googleapis.com/auth/drive"
#' credentials_user_oauth2(scopes, app = gargle_client())
#'
#' # bring your own client
#' client <- gargle_oauth_client_from_json(
#'   path = "/path/to/the/JSON/you/downloaded/from/gcp/console.json",
#'   name = "my-nifty-oauth-client"
#' )
#' credentials_user_oauth2(scopes, client)
#' }
credentials_user_oauth2 <- function(scopes = NULL,
                                    app = gargle_client(),
                                    package = "gargle",
                                    ...) {
  gargle_debug("trying {.fun credentials_user_oauth2}")
  gargle2.0_token(
    app = app,
    scope = scopes,
    package = package,
    ...
  )
}

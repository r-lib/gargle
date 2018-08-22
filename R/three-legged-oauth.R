#' Get an OAuth token for a user
#'
#' @description Consults the token cache for a suitable OAuth token and, if
#'   unsuccessful, gets a token via the browser flow. A cached token is suitable
#'   if it's compatible with the user's request in this sense:
#'   * OAuth app must be same.
#'   * Scopes. This is a check for inclusion, not exact equality.
#'   * Email, if provided, must be same.
#'
#' If multiple suitable tokens are found, user is presented with a chooser.
#' Therefore, in a non-interactive setting, it's important to uniquely identify
#' the token, by providing the `"email"`, or by making sure only one suitable
#' token will be found in the cache. Non-interactive use also suggests it might
#' be time to use a [service account token][credentials_service_account]. This
#' is a wrapper around [gargle2.0_token()].
#'
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @inheritDotParams gargle2.0_token -scope -app
#' @export
#' @examples
#' \dontrun{
#' ## Drive scope, built-in gargle demo app
#' scopes <- "https://www.googleapis.com/auth/drive"
#' credentials_user_oauth2(scopes, app = gargle_app())
#'
#' ## bring your own app
#' app <- httr::oauth_app(
#'   appname = "my_awesome_app",
#'   key = "keykeykeykeykeykey",
#'   secret = "secretsecretsecret"
#' )
#' credentials_user_oauth2(scopes, app)
#' }
credentials_user_oauth2 <- function(scopes,
                                    app = gargle_app(),
                                    ...) {
  "!DEBUG trying credentials_user_oauth2"
  if (missing(scopes)) {
    scopes <- "email"
  }
  gargle2.0_token(
    app = app,
    scope = scopes,
    ...
  )
}

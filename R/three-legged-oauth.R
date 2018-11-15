#' Get an OAuth token for a user
#'
#' @description Consults the token cache for a suitable OAuth token and, if
#'   unsuccessful, gets a token via the browser flow. A cached token is suitable
#'   if it's compatible with the user's request in this sense:
#'   * OAuth app must be same.
#'   * Scopes must be same.
#'   * Email, if provided, must be same.
#'
#' gargle is very conservative about using OAuth tokens discovered in the user's
#' cache and will generally seek interactive confirmation. Therefore, in a
#' non-interactive setting, it's important to explicitly specify the `"email"`
#' of the target account or to explicitly authorize automatic discovery. See
#' [gargle2.0_token()], which this function wraps, for more. Non-interactive use
#' also suggests it might be time to use a [service account
#' token][credentials_service_account].
#'
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @param package Name of the package requesting a token. Used in messages.
#' @inheritDotParams gargle2.0_token -scope -app -package
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
                                    package = "gargle",
                                    ...) {
  "!DEBUG trying credentials_user_oauth2"
  ## TODO(jennyb): hadley says "Just put in args?" re: this handling of scopes
  if (missing(scopes)) {
    scopes <- "email"
  }
  gargle2.0_token(
    app = app,
    scope = scopes,
    package = package,
    ...
  )
}

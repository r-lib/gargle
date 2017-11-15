
#' Create a token for a user via the browser flow.
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @inheritDotParams httr::oauth2.0_token -endpoint -scope -app
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
  gargle2.0_token(
    app = app,
    scope = scopes,
    ...
  )
}

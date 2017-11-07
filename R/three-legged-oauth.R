
#' Create a token for a user via the browser flow.
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @inheritDotParams httr::oauth2.0_token -endpoint -scope -app
#' @export
#' @examples
#' \dontrun{
#' scope <- "https://www.googleapis.com/auth/drive"
#' app <- httr::oauth_app(
#'   appname = "my_awesome_app",
#'   key = "keykeykeykeykeykey",
#'   secret = "secretsecretsecret"
#' )
#'
#' ## credentials_user_oauth2() is one of the functions token_fetch() will try
#' token_fetch(scope, app = app)
#' }
credentials_user_oauth2 <- function(scopes,
                                    app = gargle_app(),
                                    ...) {
  message("trying credentials_user_oauth2")
  token <- httr::oauth2.0_token(
    endpoint = httr::oauth_endpoints("google"),
    app = app,
    scope = scopes,
    ...
  )
  token
}

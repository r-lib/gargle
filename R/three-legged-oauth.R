
#' Create a token for a user via the browser flow.
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @inheritDotParams httr::oauth2.0_token -endpoint -scope -app
#' @export
#' @examples
#' \dontrun{
#' credentials_user_oauth2("https://www.googleapis.com/auth/drive")
#' }
credentials_user_oauth2 <- function(scopes,
                                    app = gargle_app(),
                                    ...) {
  token <- httr::oauth2.0_token(
    endpoint = httr::oauth_endpoints("google"),
    app = app,
    scope = scopes,
    ...
  )
  token
}

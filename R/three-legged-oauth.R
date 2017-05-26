
#' Create a token for a user via the browser flow.
#' @param scopes List of scopes required for the returned token.
#' @param oauth_app \code{httr::oauth_app} to use for this token fetch. (Optional.)
#' @export
get_user_oauth2_credentials <- function(scopes, oauth_app = NULL, ...) {
  
  endpoint <- httr::oauth_endpoints("google")
  app <- httr::oauth_app("google",
                         "465736758727.apps.googleusercontent.com",
                         "fJbIIyoIag0oA6p114lwsV2r")
  token <- httr::oauth2.0_token(endpoint = endpoint, app = app, scope = scopes,
                                  use_oob = FALSE)
  token
}


#' Create a token for a user via the browser flow.
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

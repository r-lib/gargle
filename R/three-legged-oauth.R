
#' Create a token for a user via the browser flow.
#' @inheritParams httr::oauth2.0_token
#' @param ... Additional arguments (ignored)
#' @export
credentials_user_oauth2 <- function(scopes,
                                    app,
                                    cache = getOption("httr_oauth_cache"),
                                    ...) {
  token <- httr::oauth2.0_token(
    endpoint = httr::oauth_endpoints("google"),
    app = app,
    scope = scopes,
    use_oob = FALSE,
    cache = cache
  )
  token
}

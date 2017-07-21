
#' Create a token for a user via the browser flow.
#' @param scopes A character vector of scopes to request.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @param cache A logical value or a string. `TRUE` means to cache using the
#'   default cache file, `.httr-oauth`. `FALSE` means don't cache, and `NA`
#'   means to guess using some sensible heuristics. A string means use the
#'   specified path as the cache file.
#' @param ... Additional arguments (ignored)
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

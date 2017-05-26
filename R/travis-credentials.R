
#' Create credentials from a service account token stored by travis.
#' @export
get_travis_credentials <- function(scopes, path = "", ...) {
  if (Sys.getenv('TRAVIS') != 'true') {
    return(NULL)
  }
  if (!nzchar(path)) {
    return(NULL)
  }

  get_service_account_credentials(scopes, path)
}


#' Create credentials from a service account token stored by travis.
#'
#' @param scopes List of scopes required for the returned token.
#' @param path Path to the decrypted travis service account.
#' @param ... Additional arguments (ignored)
#' @export
credentials_travis <- function(scopes, path = "", ...) {
  message("trying credentials_travis")
  if (Sys.getenv('TRAVIS') != 'true') {
    return(NULL)
  }
  if (!nzchar(path)) {
    return(NULL)
  }

  credentials_service_account(scopes, path)
}

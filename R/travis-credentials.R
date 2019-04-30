
#' Create credentials from a service account token stored by travis.
#'
#' @inheritParams credentials_user_oauth2
#' @param path Path to the decrypted travis service account.
#' @param ... Additional arguments (ignored)
#' @export
credentials_travis <- function(scopes, path = "", ...) {
  cat_line("trying credentials_travis()")
  if (Sys.getenv("TRAVIS") != "true") {
    return(NULL)
  }
  if (!nzchar(path)) {
    return(NULL)
  }

  credentials_service_account(scopes, path)
}

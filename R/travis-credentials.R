
#' Create credentials from a service account token stored by travis.
#'
#' @inheritParams token_fetch
#' @param path Path to the decrypted travis service account.
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

#' Fetch a token for the given scopes.
#'
#' @param scopes A list of scopes this token is authorized for.
#' @param ... Additional arguments passed to all credentials functions.
#' @return A \code{\link[httr]{Token}} or \code{NULL}.
#' @name fetch_token
#' @export
fetch_token <- function(scopes, ...) {
  for (f in gauth_env$credential_functions) {
    token <- NULL
    # TODO(craigcitro): Expose error handling and/or silencing here.
    try(
      token <- f(scopes, ...)
    )
    if (!is.null(token)) {
      return(token)
    }
  }
  NULL
}

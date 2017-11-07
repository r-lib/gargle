#' Fetch a token for the given scopes.
#'
#' @param scopes A list of scopes this token is authorized for.
#' @param ... Additional arguments passed to all credentials functions.
#' @return A [httr::Token()] or `NULL`.
#' @export
token_fetch <- function(scopes, ...) {
  message("in token_fetch()")
  for (f in gargle_env$cred_funs) {
    token <- NULL
    # TODO(craigcitro): Expose error handling and/or silencing here.
    token <- tryCatch(
      f(scopes, ...),
      #error = function(e) NULL
      error = function(e) {print(e$message); NULL}
    )
    if (!is.null(token)) {
      return(token)
    }
  }
  NULL
}

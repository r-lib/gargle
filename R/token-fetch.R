#' Fetch a token for the given scopes.
#'
#' @inheritParams credentials_user_oauth2
#' @param ... Additional arguments passed to all credential functions.
#'
#' @return A [`httr::Token`][httr::Token-class] or `NULL`.
#' @family credential functions
#' @export
token_fetch <- function(scopes, ...) {
  cat_line("trying token_fetch()")
  for (f in gargle_env$cred_funs) {
    token <- NULL
    token <- tryCatch(
      f(scopes, ...),
      # error = function(e) NULL
      error = function(e) {
        cat_line("Error: ", e$message)
        NULL
      }
    )
    if (!is.null(token)) {
      return(token)
    }
  }
  NULL
}

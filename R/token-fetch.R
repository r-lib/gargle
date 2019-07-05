#' Fetch a token for the given scopes
#'
#' This is a rather magical function that calls a series of concrete
#' credential-fetching functions, each wrapped in a `tryCatch()`.
#' `token_fetch()` keeps trying until it succeeds or there are no more functions
#' to try. Use [cred_funs_list()] to see the current registry, in order. See the
#' vignette [How gargle gets
#' tokens](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html) for a
#' full description of `token_fetch()`.
#'
#' @inheritParams credentials_user_oauth2
#' @param ... Additional arguments passed to all credential functions.
#'
#' @return An [`httr::Token`][httr::Token-class] or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")
#' }
token_fetch <- function(scopes = NULL, ...) {
  cat_line("trying token_fetch()")
  for (f in gargle_env$cred_funs) {
    token <- NULL
    token <- tryCatch(
      f(scopes, ...),
      warning = function(e) {
        cat_line("Warning: ", e$message)
        NULL
      },
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

#' Fetch a token for the given scopes
#'
#' This is a rather magical function that calls a series of concrete
#' credential-fetching functions, each wrapped in a `tryCatch()`.
#' `token_fetch()` keeps trying until it succeeds or there are no more functions
#' to try. See the `vignette("how-gargle-gets-tokens")` for a full description
#' of `token_fetch()`.
#'
#' @seealso [cred_funs_list()] reveals the current registry of
#'   credential-fetching functions, in order.
#'
#' @inheritParams credentials_user_oauth2
#' @param ... Additional arguments passed to all credential functions.
#'
#' @return An [`httr::Token`][httr::Token-class] (often an instance of something
#'   that inherits from `httr::Token`) or `NULL`.
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email")
#' }
token_fetch <- function(scopes = NULL, ...) {
  gargle_debug("trying {.fun token_fetch}")
  for (f in gargle_env$cred_funs) {
    token <- NULL
    token <- tryCatch(
      error = function(e) {
        gargle_debug(c("Error caught by {.fun token_fetch}:", e$message))
        NULL
      },
      withCallingHandlers(
        f(scopes, ...),
        warning = function(e) {
          gargle_debug(c("Warning caught by {.fun token_fetch}:", e$message))
        }
      )
    )
    if (!is.null(token)) {
      return(token)
    }
  }
  NULL
}

#' Fetch a token for the given scopes.
#'
#' @param scopes A list of scopes this token is authorized for.
#' @param ... Additional arguments passed to all credentials functions.
#' @return A [httr::Token()] or `NULL`.
#' @export
token_fetch <- function(scopes, ...) {
  message("in token_fetch()")
  for (i in seq_along(gargle_env$cred_funs)) {
    f <- gargle_env$cred_funs[[i]]
    token <- NULL
    # TODO(craigcitro): Expose error handling and/or silencing here.
    token <- tryCatch(
      f(scopes, ...),
      #error = function(e) NULL
      error = function(e) {print(e$message); NULL}
    )
    if (!is.null(token)) {
      message("token fetched!")
      gargle_env$auth$active <- TRUE
      gargle_env$auth$token <- token
      gargle_env$auth$method <- names(gargle_env$cred_funs)[[i]]
      return(token)
    }
  }
  NULL
}

#' Hand over a token
#'
#' Coughs up a token. From gargle's cache, if possible. Fetches new one if
#' necessary. Returns `NULL` if auth is inactive.
#'
#' @param scopes scopes!
#' @param ... dots!
#'
#' @return things!
#' @export
#'
#' @examples
#' \dontrun{
#' token_deliver()
#' }
token_deliver <- function(scopes = "https://www.googleapis.com/auth/drive",
                          ...) {
  if (gargle_env$auth$active) {
    gargle_env$auth$token %||% token_fetch(scopes = scopes, ...)
  } else {
    NULL
  }
}

#' Ingest a token
#'
#' @param token Path to an `.rds` file containing a token or an actual token.
#'
#' @return logical
#' @export
token_ingest <- function(token) {
  orig_token <- token
  if (inherits(token, "character")) {
    token <- tryCatch(
      suppressWarnings(readRDS(token)),
      error = function(e) {
        msg <- sprintf(
          "Cannot read token from alleged .rds file:\n  * %s", orig_token
        )
        stop(msg, call. = FALSE)
      }
    )
  }
  if (!inherits(token, "Token2.0")) {
    stop(
      paste0(
        "Input provided via 'token' is neither a token,\n",
        "nor a path to an .rds file containing a token."
      )
    )
  }
  gargle_env$auth$token <- token
  gargle_env$auth$method <- "ingest"
  ## TODO(jennybc) how/whether to interact with the default cache?
  invisible(TRUE)
}

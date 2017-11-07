
#' Environment used for gargle global state.
#'
#' This environment contains:
#' * `$cred_funs`: an ordered list of credential methods to use when trying
#'   to fetch credentials.
#' * `$auth`: a list that records current auth state:
#'   - `$active` Logical, indicates whether a token or `NULL` should be
#'     delivered upon request via `token_deliver()`.
#'   - `$token` The most recently fetched token. If none has been fetched, value
#'     is `NULL`.
#'   - `$method` The name of the credential function that produced the token. If
#'     none has been used, value if `NA_character_`.
#'
#' @noRd
#' @format An environment.
#' @keywords internal
gargle_env <- new.env(parent = emptyenv())

gargle_env$cred_funs <- list()

gargle_env$auth <- list(
  active = logical(0),
  token = NULL,
  method = NA_character_
)


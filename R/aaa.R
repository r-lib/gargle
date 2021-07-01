#' Environment used for gargle global state
#'
#' This environment contains:
#' * `$cred_funs` is the ordered list of credential functions to use when trying
#'   to fetch credentials. It is populated by a call to
#'   `cred_funs_set_default()` in `.onLoad()`.
#' * `$last_response` is the most recent response provided to
#'   `response_process()`.
#'
#' @noRd
#' @format An environment.
#' @keywords internal
gargle_env <- new.env(parent = emptyenv())
gargle_env$cred_funs <- list()
gargle_env$last_response <- list()
gargle_env$last_error <- list()

gargle_last_response <- function() {
  gargle_env$last_response
}

gargle_last_content <- function() {
  resp <- gargle_last_response()
  if (inherits(resp, "response")) {
    tryCatch(
      response_as_json(resp),
      gargle_error_request_failed = function(e) e$message
    )
  } else {
    list()
  }
}

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

#' Access the last response
#'
#' These functions give access to the most recent response processed by
#' [response_process()] (if the argument `remember = TRUE`, which is the
#' default). They can be useful for *post mortem* analysis of puzzling or
#' failed API interactions.
#'
#' @returns
#'   * `gargle_last_response()` returns the most recent [httr::response()]
#'     object.
#'   * `gargle_last_content()` returns the parsed JSON content from the most
#'     recent response or an empty list if unavailable.
#'
#' @keywords internal
#' @export
#' @rdname internal-last-response
gargle_last_response <- function() {
  gargle_env$last_response
}

#' @export
#' @rdname internal-last-response
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

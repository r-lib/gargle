
#' Create a token for a Google service account.
#'
#' @param scopes List of scopes required for the returned token.
#' @param path Path to the downloaded JSON file
#' @param ... Additional arguments (ignored)
#' @return A `httr::TokenServiceAccount` or `NULL`.
#' @export
credentials_service_account <- function(scopes, path = "", ...) {
  if (!endsWith(path, ".json")) {
    stop("Path must end in .json")
  }
  info <- jsonlite::fromJSON(path)
  token <- httr::TokenServiceAccount$new(NULL, info, list(scope = scopes))
  if (is.null(token$credentials$access_token) ||
      !nzchar(token$credentials$access_token)) {
    NULL
  } else {
    token
  }
}

#' Make a Google API request
#'
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users. `make_request()` does very little: calls an
#' HTTP method, only adding a user agent. Typically the input is created with
#' [build_request()] and the output is processed with `process_response()`.
#'
#' @param x List. Holding the components for an HTTP request, presumably created
#'   with [develop_request()] or [build_request()]. Must contain the a `method`
#'   and `url`. If present, `body` and `token` are used.
#' @param user_agent A user agent string, prepared by [httr::user_agent()].
#' @param ... Optional arguments passed through to the HTTP method.
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family requests and responses
make_request <- function(x, ..., user_agent = gargle_user_agent()) {
  method <- list(
    "GET" = httr::GET,
    "POST" = httr::POST,
    "PATCH" = httr::PATCH,
    "PUT" = httr::PUT,
    "DELETE" = httr::DELETE
  )[[x$method]]
  method(
    url = x$url,
    body = x$body,
    x$token,
    user_agent,
    ...
  )
}

gargle_user_agent <- function() {
  httr::user_agent(paste0(
    "gargle/", utils::packageVersion("gargle"), " ",
    "httr/", utils::packageVersion("httr")
  ))
}

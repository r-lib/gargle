#' Make a Google API request
#'
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users. `request_make()` does very little: calls an
#' HTTP method, only adding a user agent. Typically the input is created with
#' [request_build()] and the output is processed with `process_response()`.
#'
#' @param x List. Holds the components for an HTTP request, presumably created
#'   with [request_develop()] or [request_build()]. Must contain a `method` and
#'   `url`. If present, `body` and `token` are used.
#' @param user_agent A user agent string, prepared by [httr::user_agent()]. When
#'   in doubt, a client package should have an internal function that extends
#'   `gargle_user_agent()` by prepending its return value with the client
#'   package's name and version.
#' @param ... Optional arguments passed through to the HTTP method.
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family requests and responses
request_make <- function(x, ..., user_agent = gargle_user_agent()) {
  stopifnot(is.character(x$method))
  method <- switch(
    x$method,
    GET = httr::GET,
    POST = httr::POST,
    PATCH = httr::PATCH,
    PUT = httr::PUT,
    DELETE = httr::DELETE,
    stop_glue("Not a recognized HTTP method: {bt(m)}", m = x$method)
  )
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

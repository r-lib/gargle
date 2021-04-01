#' Make a Google API request
#'
#' @description
#' Intended primarily for internal use in client packages that provide
#' high-level wrappers for users. `request_make()` does relatively little:
#' * Calls an HTTP method.
#' * Adds a user agent.
#' * Enforces `"json"` as the default for `encode`. This differs from httr's
#'   default behaviour, but aligns better with Google APIs.
#'
#' Typically the input is created with [request_build()] and the output is
#' processed with [response_process()].
#'
#' @param x List. Holds the components for an HTTP request, presumably created
#'   with [request_develop()] or [request_build()]. Must contain a `method` and
#'   `url`. If present, `body` and `token` are used.
#' @param user_agent A user agent string, prepared by [httr::user_agent()]. When
#'   in doubt, a client package should have an internal function that extends
#'   `gargle_user_agent()` by prepending its return value with the client
#'   package's name and version.
#' @inheritParams httr::POST
#' @param ... Optional arguments passed through to the HTTP method. Currently
#'   neither gargle nor httr checks that all are used, so be aware that unused
#'   arguments may be silently ignored.
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family requests and responses
#' @examples
#' \dontrun{
#' req <- gargle::request_build(
#'   method = "GET",
#'   path = "path/to/the/resource",
#'   token = "PRETEND_I_AM_TOKEN"
#' )
#' gargle::request_make(req)
#' }
request_make <- function(x,
                         ...,
                         encode = "json",
                         user_agent = gargle_user_agent()) {
  stopifnot(is.character(x$method))
  method <- switch(
    x$method,
    GET    = httr::GET,
    POST   = httr::POST,
    PATCH  = httr::PATCH,
    PUT    = httr::PUT,
    DELETE = httr::DELETE,
    gargle_abort("Not a recognized HTTP method: {bt(x$method)}")
  )
  method(
    url = x$url,
    body = x$body,
    x$token,
    encode = encode,
    user_agent,
    ...
  )
}

gargle_user_agent <- function() {
  httr::user_agent(paste0(
    "gargle/", utils::packageVersion("gargle"), " ",
    "(GPN:RStudio; )", " ",
    "httr/", utils::packageVersion("httr")
  ))
}

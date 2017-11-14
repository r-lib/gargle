#' Create an OAuth application.
#'
#' Essentially a wrapper around [httr::oauth_app()] with an additional argument,
#' `path`, that enables app creation from the JSON download from [Google
#' Developers Console](https://console.developers.google.com). The client secret
#' and id are contained in this file and, if no `appname` is given, the
#' `"project_id"` from the JSON is used.
#'
#' @param path Path to the JSON file. If given, any input provided via `key`
#'   (the "client_id", in Google's vocabulary) and `secret` is ignored.
#' @inheritParams httr::oauth_app
#' @export
#' @examples
#' \dontrun{
#' oauth_app(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#' google_app <- oauth_app(
#'   appname = "my-awesome-google-api-wrapping-package",
#'   key = "123456789.apps.googleusercontent.com",
#'   secret = "abcdefghijklmnopqrstuvwxyz"
#' )
oauth_app <- function(appname = NULL,
                      key = NULL,
                      secret = NULL,
                      path = NULL) {

  if (!is.null(path)) {
    stopifnot(is.character(path), length(path) == 1)
    info <- jsonlite::fromJSON(readChar(path, nchars = 1e5))
    appname <- appname %||% info$installed$project_id
    key <- info$installed$client_id
    secret <- info$installed$client_secret
  }

  httr::oauth_app(
    appname = appname,
    key = key,
    secret = secret
  )
}

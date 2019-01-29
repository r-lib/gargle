#' Create an OAuth app from JSON
#'
#' Essentially a wrapper around [httr::oauth_app()] that extracts client id (aka
#' key) and secret from JSON downloaded from [Google Developers
#' Console](https://console.developers.google.com). If no `appname` is given,
#' the `"project_id"` from the JSON is used.
#'
#' @param path Path to the JSON file.
#' @inheritParams httr::oauth_app
#' @export
#' @examples
#' \dontrun{
#' oauth_app(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
oauth_app_from_json <- function(path,
                                appname = NULL) {
  stopifnot(is_string(path), is.null(appname) || is_string(appname))

  info <- jsonlite::read_json(path)

  httr::oauth_app(
    appname = appname %||% info$installed$project_id,
    key = info$installed$client_id,
    secret = info$installed$client_secret
  )
}

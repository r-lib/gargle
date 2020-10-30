#' Create an OAuth app from JSON
#'
#' Essentially a wrapper around [httr::oauth_app()] that extracts the necessary
#' info from JSON obtained from [Google Cloud Platform
#' Console](https://console.cloud.google.com). If no `appname` is given,
#' the `"project_id"` from the JSON is used.
#'
#' @param path JSON downloaded from Google Cloud Platform Console, containing a
#'   client id (aka key) and secret, in one of the forms supported for the `txt`
#'   argument of [jsonlite::fromJSON()] (typically, a file path or JSON string).
#'
#' @inheritParams httr::oauth_app
#' @export
#' @examples
#' \dontrun{
#' oauth_app(
#'   path = "/path/to/the/JSON/you/downloaded/from/gcp/console.json"
#' )
#' }
oauth_app_from_json <- function(path,
                                appname = NULL) {
  stopifnot(is_string(path), is.null(appname) || is_string(appname))

  json <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  info <- json[["installed"]]
  if (is.null(info)) {
    # Web client credentials use this key instead
    info <- json[["web"]]
  }

  if (!all(c("client_id", "client_secret") %in% names(info))) {
    stop("Can't find 'client_id' and 'client_secret' in the JSON", call. = FALSE)
  }

  httr::oauth_app(
    appname = appname %||% info$project_id,
    key = info$client_id,
    secret = info$client_secret
  )
}

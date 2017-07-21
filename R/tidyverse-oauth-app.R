#' Oauth app for tidyverse packages
#'
#' Returns an OAuth app for use in tidyverse packages, e.g., googledrive,
#' googlesheets, bigrquery. Developers of other packages should create their own
#' [Cloud Platform Project](https://support.google.com/cloud/answer/6158853) in
#' the [Google Developers Console](https://console.developers.google.com) and
#' obtain their own client ID and secret. These can then be used with
#' [httr::oauth_app()].
#'
#' @return An OAuth consumer application, produced by [httr::oauth_app()].
#' @export
#'
#' @examples
#' tidyverse_app()
tidyverse_app <- function() {
  httr::oauth_app(
    appname = "tidyverse",
    key = "603366585132-nku3fbd298ma3925l12o2hq0cc1v8u11.apps.googleusercontent.com",
    secret = "as_N12yfWLRL9RMz5nVpgCZt"
  )
}

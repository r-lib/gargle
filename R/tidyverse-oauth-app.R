#' OAuth app for tidyverse packages
#'
#' Returns an OAuth app for use in tidyverse packages, e.g., googledrive,
#' googlesheets, bigrquery. Please don't use this app directly in non-tidyverse
#' projects.
#'
#' @seealso For a default app to use while getting to know gargle and
#'   instructions on how to make your own app, see [gargle_app()].
#'
#' @return An OAuth consumer application, produced by [httr::oauth_app()].
#' @keywords internal
#' @export
#' @examples
#' tidyverse_app()
tidyverse_app <- function() {
  httr::oauth_app(
    appname = "tidyverse",
    key = "603366585132-nku3fbd298ma3925l12o2hq0cc1v8u11.apps.googleusercontent.com",
    secret = "as_N12yfWLRL9RMz5nVpgCZt"
  )
}

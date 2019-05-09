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
    key = paste0(
      "603366585132-n",
      # NUtAKHPpnghcn
      "ku3fbd298ma392",
      # FyPP6YFdCPItQ
      "5l12o2hq0cc1v8",
      # hT74HRpdnJacj
      "u11.apps.google",
      # 5dbyGDyIYBkFU
      "usercontent.com"
    ),
    secret = paste0(
      "as_N12yf",
      # X2eBeHKb
      "WLRL9RMz",
      # TIdQWNVi
      "5nVpgCZt"
    )
  )
}

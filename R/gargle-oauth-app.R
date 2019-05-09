#' OAuth app for demonstration purposes
#'
#' Returns an OAuth app that we default to in [credentials_user_oauth2()]. This
#' makes it easy to test drive gargle before obtaining your own client ID and
#' secret. Once your use of gargle is more than casual, you should create a
#' similar function, but populated with your own credentials, like so:
#'   * Create a [Cloud Platform Project](https://support.google.com/cloud/answer/6158853)
#'     in the [Google Developers Console](https://console.developers.google.com).
#'   * Create a function, e.g., `my_app()`, that calls [httr::oauth_app()]
#'     with a meaningful nickname and your app's client ID and secret.
#'
#' @return An OAuth consumer application, produced by [httr::oauth_app()].
#' @export
#' @examples
#' gargle_app()
gargle_app <- function() {
  httr::oauth_app(
    appname = "gargle-demo",
    key = paste0(
      "603366585132-o",
      # ivOTVztW3df3
      "rjlfqlnkvnkeb1",
      # TVTky4EBCsJJ
      "menfdhss2oej4i",
      # OL0X6AEwwNf4
      "2d5.apps.googl",
      # zK46rIOYGLwS
      "eusercontent.com"
    ),
    secret = paste0(
      "Rg-wypvL",
      # pExSN8k6
      "9HPaYatz",
      # nkQemRzq
      "yjXDwVfV"
    )
  )
}

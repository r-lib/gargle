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
    key = "603366585132-orjlfqlnkvnkeb1menfdhss2oej4i2d5.apps.googleusercontent.com",
    secret = "Rg-wypvL9HPaYatzyjXDwVfV"
  )
}

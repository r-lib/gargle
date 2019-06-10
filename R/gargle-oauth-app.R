#' OAuth app for demonstration purposes
#'
#' @description Invisibly returns an OAuth app that can be used to test drive
#'   gargle before obtaining your own client ID and secret. This OAuth app may
#'   be deleted or rotated at any time. There are no guarantees about which APIs
#'   are enabled. DO NOT USE THIS IN A PACKAGE or for anything other than
#'   interactive, small-scale experimentation.
#'
#'   To get your own OAuth app, without these limitations, set up a new Google
#'   [Cloud Platform Project](https://support.google.com/cloud/answer/6158853)
#'   in [Google Developers Console](https://console.developers.google.com) and
#'   complete the
#'   [Prerequisites](https://developers.google.com/identity/protocols/OAuth2InstalledApp#prerequisites)
#'    for OAuth 2.0 for Mobile & Desktop Apps. Use [httr::oauth_app()] to create
#'   an object of type `oauth_app`, suitable for use with the gargle and httr
#'   packages.
#'
#' @return An OAuth consumer application, produced by [httr::oauth_app()],
#'   invisibly.
#' @export
#' @examples
#' \dontrun{
#' gargle_app()
#' }
gargle_app <- function() {
  goa()
}

#' @export
#' @keywords internal
#' @rdname internal-assets
tidyverse_app <- function() {
  check_permitted_package(parent.frame())
  toa()
}

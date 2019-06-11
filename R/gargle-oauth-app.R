#' OAuth app for demonstration purposes
#'
#' @description Invisibly returns an OAuth app that can be used to test drive
#'   gargle before obtaining your own client ID and secret. This OAuth app may
#'   be deleted or rotated at any time. There are no guarantees about which APIs
#'   are enabled. DO NOT USE THIS IN A PACKAGE or for anything other than
#'   interactive, small-scale experimentation.
#'
#'   You can get your own OAuth app (client ID and secret), without these
#'   limitations. See the [How to get your own API
#'   credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
#'   vignette for more details.
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

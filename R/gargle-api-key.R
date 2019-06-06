#' API key for demonstration purposes
#'
#' @description Some APIs accept requests for public resources, in which case
#'   the request must be sent with an API key in lieu of a token. This function
#'   provides an API key for limited use in prototyping and for testing and
#'   documentation of gargle itself. This key may be deleted or rotated at any
#'   time. There are no guarantees about which APIs are enabled. DO NOT USE THIS
#'   IN A PACKAGE or for anything other than interactive, small-scale
#'   experimentation.
#'
#'   To get your own API key, without these limitations, set up a new Google
#'   Cloud Platform project in [Google Developers
#'   Console](https://console.developers.google.com), enable the APIs of
#'   interest, and follow the instructions in [Setting up API
#'   keys](https://support.google.com/googleapi/answer/6158862).
#'
#' @export
#' @keywords internal
#' @examples
#' gargle_api_key()
gargle_api_key <- function() {
  gak()
}

#' Assets for internal use
#'
#' @name internal-assets
NULL

#' @export
#' @keywords internal
#' @rdname internal-assets
tidyverse_api_key <- function() {
  check_permitted_package(parent.frame())
  tak()
}

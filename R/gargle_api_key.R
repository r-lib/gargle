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
#'   You can get your own API key, without these limitations. See the [How to
#'   get your own API
#'   credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
#'   vignette for more details.
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
#' Assets for use inside specific packages maintained by the tidyverse team.
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

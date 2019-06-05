#' API key for demonstration purposes
#'
#' @description
#'
#' Some APIs accept unauthorized requests for public resources, in which case
#' the request must be sent with an API key in lieu of a token. This function
#' returns an API key for limited use in prototyping and for testing and
#' documentation of gargle itself.  This function is not exported and will only
#' work inside other gargle functions, such as [request_build()].
#'
#' To get your own API key, setup a new Google Cloud Platform project in [Google
#' Developers Console](https://console.developers.google.com), enable the APIs
#' of interest, and follow the instructions in [Setting up API
#' keys](https://support.google.com/googleapi/answer/6158862).
#'
#' @return A Google API key
#' @export
#' @examples
#' \dontrun{
#' # use the key with the Places API (explicitly enabled for this key)
#' # gets restaurants close to a location in Vancouver, BC
#' req <- request_build(
#'   method = "GET",
#'   path = "maps/api/place/nearbysearch/json",
#'   params = list(
#'     location = "49.268682,-123.167117",
#'     radius = 100,
#'     type = "restaurant"
#'   ),
#'   key = gargle_api_key(),
#'   base_url = "https://maps.googleapis.com"
#' )
#' resp <- request_make(req)
#' out <- response_process(resp)
#' vapply(out$results, function(x) x$name, character(1))
#' }
gargle_api_key <- function() {
  check_permitted_package(parent.frame(), allowed = "gargle")
  gak()
}

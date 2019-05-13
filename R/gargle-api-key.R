#' API key for demonstration purposes
#'
#' Returns an API key for use when test driving gargle. Some API requests for
#' public resources do not require authorization, in which case the request can
#' be sent with an API key in lieu of a token. If you want to get your own API
#' key, setup a new project in [Google Developers
#' Console](https://console.developers.google.com), enable the APIs of interest,
#' and follow the instructions in [Setting up API
#' keys](https://support.google.com/googleapi/answer/6158862).
#'
#' @return A Google API key
#' @export
#' @examples
#' \dontrun{
#' ## see the key
#' gargle_api_key()
#'
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
  paste0(
    "AIzaSyDXic",
    # pgnTLHYCI
    "V6oK4vR948",
    # HCWveSQkJ
    "PUAvlyr7Qh",
    # ddS4QrEge
    "kNwCoQ0cA"
  )
}

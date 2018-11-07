#' OAuth endpoint for Google APIs
#'
#' Inlined from httr in case it changes. Internal function to centralize the
#' info.
#'
#' @return An OAuth endpoint, produced by [httr::oauth_endpoint()].
#' @keywords internal
#' @noRd
#' @examples
#' gargle_oauth_endpoint()
gargle_outh_endpoint <- function() {
  httr::oauth_endpoint(
    base_url = "https://accounts.google.com/o/oauth2",
    authorize = "auth",
    access = "token",
    validate = "https://www.googleapis.com/oauth2/v1/tokeninfo",
    revoke = "revoke"
  )
}

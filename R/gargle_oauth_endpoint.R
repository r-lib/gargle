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
gargle_oauth_endpoint <- function() {
  out <- httr::oauth_endpoint(
    base_url = "https://oauth2.googleapis.com",
    authorize = "",
    access = "token",
    validate = "tokeninfo",
    revoke = "revoke"
  )
  out$authorize <- "https://accounts.google.com/o/oauth2/v2/auth"
  out
}

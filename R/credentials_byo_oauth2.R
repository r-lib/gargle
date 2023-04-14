#' Load a user-provided token
#'
#' @description
#' This function does very little when called directly with a token:
#'   * If input has class `request`, i.e. it is a token that has been prepared
#'     with [httr::config()], the `auth_token` component is extracted. For
#'     example, such input could be produced by `googledrive::drive_token()`
#'     or `bigrquery::bq_token()`.
#'   * If token is an instance of `Gargle2.0` (a gargle-obtained user token),
#'     checks that it appears to be a Google OAuth token, based on its embedded
#'     `oauth_endpoint`. Refreshes the token, if it's refreshable.
#'   * Returns the token.
#'
#' There is no point providing `scopes`. They are ignored because the `scopes`
#' associated with the token have already been baked in to the token itself and
#' gargle does not support incremental authorization. The main point of
#' `credentials_byo_oauth2()` is to allow `token_fetch()` (and packages that
#' wrap it) to accommodate a "bring your own token" workflow.
#'
#' This also makes it possible to obtain a token with one package and then
#' register it for use with another package. For example, the default scope
#' requested by googledrive is also sufficient for operations available in
#' googlesheets4. You could use a shared token like so:
#' ```
#' library(googledrive)
#' library(googlesheets4)
#' drive_auth(email = "jane_doe@example.com")
#' gs4_auth(token = drive_token())
#' # work with both packages freely now
#' ```
#'
#' @inheritParams token_fetch
#' @inheritParams token-info
#'
#' @return An [Token2.0][httr::Token-class].
#' @family credential functions
#' @export
#' @examples
#' \dontrun{
#' # assume `my_token` is a Token2.0 object returned by a function such as
#' # httr::oauth2.0_token() or gargle::gargle2.0_token()
#' credentials_byo_oauth2(token = my_token)
#' }
credentials_byo_oauth2 <- function(scopes = NULL, token, ...) {
  gargle_debug("Trying {.fun credentials_byo_oauth} ...")
  if (inherits(token, "request")) {
    token <- token$auth_token
  }
  stopifnot(inherits(token, "Token2.0"))

  if (!is.null(scopes)) {
    gargle_debug(c(
      "!" = "The {.arg scopes} cannot be specified when user brings their own \\
             OAuth token.",
      "i" = "The {.arg scopes} are already implicit in the token.",
      "i" = "Requested {.arg scopes} are effectively ignored."
    ))

    declared_scopes <- normalize_scopes(token$params$scope)
    requested_scopes <- normalize_scopes(scopes)

    if (!setequal(requested_scopes, declared_scopes)) {
      gargle_debug(c(
        "!" = "Token's declared scopes are not the same as the requested \\
               scopes.",
        "i" = "Scopes declared in token: {commapse(base_scope(declared_scopes))}",
        "i" = "Requested scopes: {commapse(base_scope(requested_scopes))}"
      ))
    }
  }

  if (inherits(token, "Gargle2.0")) {
    check_endpoint(token$endpoint)
    if (token$can_refresh()) {
      token$refresh()
    }
  }

  token
}

check_endpoint <- function(endpoint, call = caller_env()) {
  stopifnot(inherits(endpoint, "oauth_endpoint"))
  urls <- endpoint[c("authorize", "access", "validate", "revoke")]
  urls_ok <- all(grepl("google", urls))
  if (!urls_ok) {
    gargle_abort("Token doesn't use Google's OAuth endpoint.", call = call)
  }
  endpoint
}

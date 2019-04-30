# Good 3rd party overview re: learning about your Google user / token:
# https://www.oauth.com/oauth2-servers/signing-in-with-google/verifying-the-user-info/
#
# It suggests perhaps we could recover, e.g., the email during token initiation?
# But I'm not sure and it might require a change in httr, in any case.
#
# Therefore, I focus on the two post hoc methods for retrieving info based on
# the token you've already got:
#   * userinfo endpoint
#   * tokeninfo endpoint
# Both require an additional HTTP request, so are "not recommended for
# production applications".
#
# I had working code to access both the userinfo and tokeninfo endpoints before
# I read this and there are a few differences between what I do and what they
# say to do. The discrepancies are around which token to send (ID? access? etc.)
# and where/how to send it. I conclude that there must be a few variations that
# work.
#
# Google's docs re: how to get user info:
# https://developers.google.com/identity/protocols/OpenIDConnect#obtaininguserprofileinformation
# "Add your access token to the authorization header and make an HTTPS GET
# request to the userinfo endpoint, which you should retrieve from the Discovery
# document using the key userinfo_endpoint."
#
# Here's the OpenID Connect discovery document:
# https://accounts.google.com/.well-known/openid-configuration
#
# Here's the URL for userinfo_endpoint, at the time of writing:
# https://openidconnect.googleapis.com/v1/userinfo


#' Get info on current user
#'
#' The userinfo endpoint can potentially return the user's entire profile, if
#' the token has the necessary scope. But, by default, gargle-mediated tokens
#' only include the `userinfo.email` scope, so don't expect to get much beyond
#' the email, unless you've explicitly scoped for more. `get_userinfo()` can
#' exploit built-in token refresh, although at the time of writing, the
#' motivating use case is to get and store the email for a freshly-obtained
#' token.
#'
#' @param token A gargle token
#'
#' @return User info or user's email
#' @keywords internal
#' @examples
#' \dontrun{
#' # with service account token
#' t <- token_fetch(
#'   scopes = "https://www.googleapis.com/auth/drive",
#'   path   = "path/to/service/account/token/blah-blah-blah.json"
#' )
#' # or with an OAuth token
#' t <- token_fetch(
#'   scopes = "https://www.googleapis.com/auth/drive",
#'   email  = "janedoe@example.com"
#' )
#' get_userinfo(t)
#' get_email(t)
#' get_tokeninfo(t)
#' }
get_userinfo <- function(token) {
  stopifnot(inherits(token, "Token2.0"))

  req <- gargle::request_build(
    method = "GET",
    path = "v1/userinfo",
    token = token,
    base_url = "https://openidconnect.googleapis.com"
  )
  raw_resp <- gargle::request_make(req)
  ## TODO(jennybc) use process_response() once it's available in same pkg
  httr::stop_for_status(raw_resp)
  res <- httr::content(raw_resp, as = "parsed", type = "application/json")
  res
}

#' @rdname get_userinfo
# Assumes the token was obtained with userinfo.email scope.
# This is true of all gargle-mediated tokens, by definition.
get_email <- function(token) {
  get_userinfo(token)$email
}


# WARNING: does not trigger token refresh!
# A token that needs to be refreshed can result in "Bad Request (HTTP 400)."
# Use when you expect the token to be valid for external reasons, e.g. it is
# known to be fresh.
get_tokeninfo <- function(token) {
  stopifnot(inherits(token, "Token2.0"))

  # https://www.googleapis.com/oauth2/v3/tokeninfo
  req <- gargle::request_build(
    method = "GET",
    path = "oauth2/v3/tokeninfo",
    # also works
    # params = list(access_token = token$credentials$access_token),
    token = token,
    base_url = "https://www.googleapis.com"
  )
  raw_resp <- gargle::request_make(req)
  ## TODO(jennybc) use process_response() once it's available in same pkg
  httr::stop_for_status(raw_resp)
  res <- httr::content(raw_resp, as = "parsed", type = "application/json")
  res
}

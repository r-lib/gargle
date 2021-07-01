# See notes about the userinfo and tokeninfo endpoints below.

#' Get info from a token
#'
#' These functions send the `token` to Google endpoints that return info about a
#' token or a user.
#'
#' @param token A token with class [Token2.0][httr::Token-class] or an object of
#'   httr's class `request`, i.e. a token that has been prepared with
#'   [httr::config()] and has a [Token2.0][httr::Token-class] in the
#'   `auth_token` component.
#' @name token-info
#'
#' @return A list containing:
#'   * `token_userinfo()`: user info
#'   * `token_email()`: user's email (obtained from a call to `token_userinfo()`)
#'   * `token_tokeninfo()`: token info
#'
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
#' token_userinfo(t)
#' token_email(t)
#' tokens_tokeninfo(t)
#' }
NULL

#' @rdname token-info
#' @export
#'
#' @details
#' It's hard to say exactly what info will be returned by the "userinfo"
#' endpoint targetted by `token_userinfo()`. It depends on the token's scopes.
#' OAuth2 tokens obtained via the gargle package include the
#' `https://www.googleapis.com/auth/userinfo.email` scope, which guarantees we
#' can learn the email associated with the token. If the token has the
#' `https://www.googleapis.com/auth/userinfo.profile` scope, there will be even
#' more information available. But for a token with unknown or arbitrary scopes,
#' we can't make any promises about what information will be returned.
token_userinfo <- function(token) {
  if (inherits(token, "request")) {
    token <- token$auth_token
  }
  stopifnot(inherits(token, "Token2.0"))

  req <- request_build(
    method = "GET",
    path = "v1/userinfo",
    token = token,
    base_url = "https://openidconnect.googleapis.com"
  )
  resp <- request_make(req)
  response_process(resp)
}

#' @rdname token-info
#' @export
token_email <- function(token) {
  # Assumes the token was obtained with userinfo.email scope.
  # This is true of all gargle-mediated tokens, by definition.
  token_userinfo(token)$email
}

#' @rdname token-info
#' @export
token_tokeninfo <- function(token) {
  if (inherits(token, "request")) {
    token <- token$auth_token
  }
  stopifnot(inherits(token, "Token2.0"))
  # I only want to refresh a user token, which I identify in this rather
  # back-ass-wards way, i.e. by a process of elimination
  if (!inherits(token, c("TokenServiceAccount", "WifToken", "GceToken"))) {
    # A stale token does not fail in a way that leads to auto refresh.
    # It results in: "Bad Request (HTTP 400)."
    # Hence, the explicit refresh here.
    token$refresh()
  }

  # https://www.googleapis.com/oauth2/v3/tokeninfo
  req <- request_build(
    method = "GET",
    path = "oauth2/v3/tokeninfo",
    # also works
    # params = list(access_token = token$credentials$access_token),
    token = token,
    base_url = "https://www.googleapis.com"
  )
  resp <- request_make(req)
  response_process(resp)
}

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

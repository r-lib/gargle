# Good overview re: learning about your Google user / token:
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
# Google's docs re: how to get user info:
# https://developers.google.com/identity/protocols/OpenIDConnect#obtaininguserprofileinformation
# "Add your access token to the authorization header and make an HTTPS GET
# request to the userinfo endpoint, which you should retrieve from the Discovery
# document using the key userinfo_endpoint."

# Here's the OpenID Connect discovery document:
# https://accounts.google.com/.well-known/openid-configuration
#
# Here's the URL for userinfo_endpoint, at the time of writing:
# https://openidconnect.googleapis.com/v1/userinfo
#
# I had working code to access both of these endpoints before I read this and
# there are a few differences between what I do and what they say to do. The
# discrepancies are around which token to send (ID? access? etc.) and where/how
# to send it. I conclude that there must be a few variations that work.


# Note that gargle only includes the userinfo.email scope, as a global default,
# so we don't expect to get back general profile info.
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
  #res$email
  res
}

# WARNING: does not validate or refresh token!
# Use when you expect the token to be valid for external reasons.
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

# Assumes the token was obtained with userinfo.email scope.
# This will be true of all gargle-mediated tokens, by definition.
get_email <- function(token) {
  get_tokeninfo(token)$email
}

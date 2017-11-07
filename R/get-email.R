## takes a Token2.0, extracts access token, retrieves user's email
## does not (cannot, really) refresh said token
## use it when you expect the token to be valid for external reasons
## also, assumes the token was obtained with "email" scope
## this will be true of all gargle-mediated tokens, by definition
get_email <- function(token) {
  stopifnot(inherits(token, "Token2.0"))

  url <- httr::parse_url("https://www.googleapis.com/oauth2/v3/tokeninfo")
  url$query$access_token <- token$credentials$access_token
  url <- httr::build_url(url)

  res <- httr::GET(url)
  ## TODO(jennybc) use process_response() once it's available in same pkg
  httr::stop_for_status(res)
  res <- httr::content(res, as = "parsed", type = "application/json")
  res$email
}

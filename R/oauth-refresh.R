# this file has its origins in oauth-refresh.R and oauth-error.R in httr
# I want to introduce behaviour to error informatively for a deleted OAuth app

# Refresh an OAuth 2.0 credential.
#
# Refreshes the given token, and returns a new credential with a
# valid access_token. Based on:
# https://developers.google.com/accounts/docs/OAuth2InstalledApp#refresh
refresh_oauth2.0 <- function(endpoint, app, credentials, user_params = NULL,
                             use_basic_auth = FALSE) {
  if (is.null(credentials$refresh_token)) {
    stop("Refresh token not available", call. = FALSE)
  }

  refresh_url <- endpoint$access
  req_params <- list(
    refresh_token = credentials$refresh_token,
    client_id = app$key,
    grant_type = "refresh_token"
  )

  if (!is.null(user_params)) {
    req_params <- utils::modifyList(user_params, req_params)
  }

  if (isTRUE(use_basic_auth)) {
    response <- httr::POST(refresh_url,
      body = req_params, encode = "form",
      httr::authenticate(app$key, app$secret, type = "basic")
    )
  } else {
    req_params$client_secret <- app$secret
    response <- httr::POST(refresh_url, body = req_params, encode = "form")
  }

  err <- find_oauth2.0_error(response)
  if (!is.null(err)) {
    lines <- c(
      paste0("Unable to refresh token: ", err$error),
      err$error_description,
      err$error_uri
    )
    warning(paste(lines, collapse = "\n"), call. = FALSE)
    return(NULL)
  }

  httr::stop_for_status(response)
  refresh_data <- httr::content(response)
  utils::modifyList(credentials, refresh_data)
}

oauth2.0_error_codes <- c(
  400,
  401
)

oauth2.0_errors <- c(
  "invalid_request",
  "invalid_client",
  "invalid_grant",
  "unauthorized_client",
  "unsupported_grant_type",
  "invalid_scope"
)

# This implements error checking according to the OAuth2.0
# specification: https://tools.ietf.org/html/rfc6749#section-5.2
find_oauth2.0_error <- function(response) {
  if (!httr::status_code(response) %in% oauth2.0_error_codes) {
    return(NULL)
  }

  content <- httr::content(response)
  if (!content$error %in% oauth2.0_errors) {
    return(NULL)
  }

  list(
    error = content$error,
    error_description = content$error_description,
    error_uri = content$error_uri
  )
}

# this file has its origins in oauth-refresh.R and oauth-error.R in httr
# I want to introduce behaviour to error informatively for a deleted OAuth app

# Refresh an OAuth 2.0 credential.
#
# Refreshes the given token, and returns a new credential with a
# valid access_token. Based on:
# https://developers.google.com/identity/protocols/oauth2/native-app#offline
refresh_oauth2.0 <- function(endpoint, app, credentials, package = NULL) {
  if (is.null(credentials$refresh_token)) {
    gargle_abort("Refresh token not available.")
  }

  refresh_url <- endpoint$access
  req_params <- list(
    refresh_token = credentials$refresh_token,
    client_id = app$key,
    client_secret = app$secret,
    grant_type = "refresh_token"
  )

  response <- httr::POST(refresh_url, body = req_params, encode = "form")

  err <- find_oauth2.0_error(response)
  if (!is.null(err)) {
    gargle_refresh_failure(err, app, package)
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

# This implements error checking according to the OAuth2.0
# specification: https://tools.ietf.org/html/rfc6749#section-5.2
find_oauth2.0_error <- function(response) {
  if (!httr::status_code(response) %in% oauth2.0_error_codes) {
    return(NULL)
  }

  content <- httr::content(response)
  if (is.null(content$error)) {
    return(NULL)
  }

  list(
    error = content$error,
    error_description = content$error_description,
    error_uri = content$error_uri
  )
}

gargle_refresh_failure <- function(err, app, package = NULL) {
  if (!identical(err$error, "deleted_client")) {
    # this is basically what httr does, except we don't have an explicit
    # whitelist of acceptable values of err$error, because we know Google does
    # not limit itself to these
    gargle_warn(c(
      "Unable to refresh token: {err$error}",
      "*" = err$error_description,
      "*" = err$error_uri
    ))
    return(invisible())
  }

  # special handling for 'deleted_client'
  app_name <- app$appname %||% ""
  is_legacy_app <- grepl(gargle_legacy_app_pattern(), app_name)

  # app looks like one of "ours"
  if (is_legacy_app) {
    main_pkg <- package %||% "gargle"
    all_pkgs <- if (main_pkg == "gargle") "gargle" else c(main_pkg, "gargle")
    gargle_warn(c(
      "Unable to refresh token, because the associated OAuth app \\
       has been deleted.",
      "i" = "You appear to be relying on the default app used by the \\
             {.pkg {main_pkg}} package.",
      " " = "Consider re-installing {.pkg {all_pkgs}}, \\
             in case the default app has been updated."
    ))
    return(invisible())
  }

  # deleted app doesn't seem to be one of "ours"
  gargle_warn(c(
    "Unable to refresh token, because the associated OAuth app \\
     has been deleted.",
    "*" = if (nzchar(app_name)) "App name: {.field {app_name}}",
    if (!is.null(package)) {
      c(
        "i" = "If you did not configure this OAuth app, it may be built into \\
               the {.pkg {package}} package.",
        " " = "If so, consider re-installing {.pkg {package}} to get an updated \\
               app."
      )
    }
  ))
  invisible()
}

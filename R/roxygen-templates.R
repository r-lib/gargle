# nocov start

## FIXME(jennybc): find a place for this
#' @section API console:
#' To manage your google projects, use the API console:
#' \url{https://console.cloud.google.com/}

# example of data client package needs to provide -----------------------------

# a client package should define a list like this and pass it to the functions
# below, to provide data to populate the templates

# see googledrive/R/drive_auth.R for an example
# this is an exhaustive list of the pieces of data required by the templates

# gargle_lookup_table <- list(
#   PACKAGE     = "googledrive",
#   YOUR_STUFF  = "your Drive files",
#   PRODUCT     = "Google Drive",
#   API         = "Drive API",
#   PREFIX      = "drive",
#   # Only packages maintained by the tidyverse teams can use this app.
#   # If you ship an app with your package, use an appropriate name here.
#   AUTH_CONFIG_SOURCE = "tidyverse"
# )

# PREFIX_auth() ----------------------------------------------------------

PREFIX_auth_description <- function(.data = list(
  PACKAGE    = "PACKAGE",
  YOUR_STUFF = "YOUR STUFF",
  PRODUCT    = "A GOOGLE PRODUCT"
)) {
  glue_data_lines(c(
    "@description",
    "Authorize {PACKAGE} to view and manage {YOUR_STUFF}. This function is a",
    "wrapper around [gargle::token_fetch()].",
    "",
    "By default, you are directed to a web browser, asked to sign in to your",
    "Google account, and to grant {PACKAGE} permission to operate on your",
    "behalf with {PRODUCT}. By default, these user credentials are cached in a",
    "folder below your home directory, `~/.R/gargle/gargle-oauth`, from where",
    "they can be automatically refreshed, as necessary. Storage at the user",
    "level means the same token can be used across multiple projects and",
    "tokens are less likely to be synced to the cloud by accident."
  ), .data = .data)
}

PREFIX_auth_details <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
)) {
  glue_data_lines(c(
    "@details",
    "Most users, most of the time, do not need to call `{PREFIX}_auth()`",
    "explicitly -- it is triggered by the first action that requires",
    "authorization. Even when called, the default arguments often suffice.",
    "However, when necessary, this function allows the user to explicitly:",
    "  * Declare which Google identity to use, via an email address. If there",
    "    are multiple cached tokens, this can clarify which one to use. It can",
    "    also force {PACKAGE} to switch from one identity to another. If",
    "    there's no cached token for the email, this triggers a return to the",
    "    browser to choose the identity and give consent.",
    "  * Use a service account token.",
    "  * Bring their own [Token2.0][httr::Token-class].",
    "  * Specify non-default behavior re: token caching and out-of-bound",
    "    authentication.",
    "",
    "For details on the many ways to find a token, see",
    "[gargle::token_fetch()]. For deeper control over auth, use",
    "[{PREFIX}_auth_configure()] to bring your own OAuth app or API key."
  ), .data = .data)
}

PREFIX_auth_params <- function() {c(
  "@inheritParams gargle::credentials_service_account",
  "@inheritParams gargle::credentials_app_default",
  "@inheritParams gargle::credentials_gce",
  "@inheritParams gargle::credentials_byo_oauth2",
  "@inheritParams gargle::credentials_user_oauth2",
  "@inheritParams gargle::gargle2.0_token"
)}

# PREFIX_deauth() ----------------------------------------------------------

PREFIX_deauth_description <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
), .fallback_api_key = TRUE) {
  lines <- c(
    "@description",
    "Put {PACKAGE} into a de-authorized state. Instead of sending a token,",
    "{PACKAGE} will send an API key. This can be used to access public",
    "resources for which no Google sign-in is required. This is handy for using",
    "{PACKAGE} in a non-interactive setting to make requests that do not",
    "require a token. It will prevent the attempt to obtain a token",
    "interactively in the browser. The user can configure their own API key",
    "via [{PREFIX}_auth_configure()] and retrieve that key via",
    "[{PREFIX}_api_key()]."
  )
  if (.fallback_api_key) {
    lines <- append(lines,
    "In the absence of a user-configured key, an built-in default key is used."
    )
  }
  glue_data_lines(lines, .data = .data)
}

# PREFIX_token() ----------------------------------------------------------

PREFIX_token_description <- function(.data = list(
  API    = "GOOGLE API",
  PREFIX = "PREFIX"
), .deauth_possible = TRUE) {
  lines <- c(
    "@description",
    "For internal use or for those programming around the {API}.",
    "Returns a token pre-processed with [httr::config()]. Most users",
    "do not need to handle tokens \"by hand\" or, even if they need some",
    "control, [{PREFIX}_auth()] is what they need. If there is no current",
    "token, [{PREFIX}_auth()] is called to either load from cache or",
    "initiate OAuth2.0 flow."
  )
  if (.deauth_possible) {
    lines <- append(lines, c(
    "If auth has been deactivated via [{PREFIX}_deauth()], `{PREFIX}_token()`",
    "returns `NULL`."
    ))
  }
  glue_data_lines(lines, .data = .data)
}

PREFIX_token_return <- function() {
  "@return A `request` object (an S3 class provided by [httr][httr::httr])."
}

# PREFIX_auth_config() -------------------------------------------------------

PREFIX_auth_config_description <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
), .deauth_possible = TRUE) {
  lines <- c(
    "@description",
    "These functions give the user more control over auth than what is",
    "possible with [{PREFIX}_auth()]. `{PREFIX}_auth_config()` gives control",
    "of:",
    "   * The OAuth app, which is used when obtaining a user token."
  )
  if (.deauth_possible) {
    lines <- append(lines, c(
    "   * The API key. If {PACKAGE} is deauthorized via [{PREFIX}_deauth()],",
    "     all requests will be sent with an API key in lieu of a token."
    ))
  }
  lines <- append(lines, c(
    "",
    "See the vignette [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)",
    "for more."
  ))
  if (.deauth_possible) {
    lines <- append(lines, c(
    "",
    "`{PREFIX}_api_key()` and `{PREFIX}_oauth_app()` retrieve the",
    " currently configured API key and OAuth app, respectively."
    ))
  } else {
    lines <- append(lines, c(
    "",
    "`{PREFIX}_oauth_app()` retrieves the currently configured OAuth app."
    ))
  }
  glue_data_lines(lines, .data = .data)
}

PREFIX_auth_config_params_except_key <- function(.data = list(
  PACKAGE = "AUTH_CONFIG_SOURCE"
)) {
  glue_data_lines(c(
    "@param app OAuth app. Defaults to a {AUTH_CONFIG_SOURCE} app.",
    "@inheritParams gargle::oauth_app_from_json"
  ), .data = .data)
}

PREFIX_auth_config_params_key <- function(.data = list(
  PACKAGE = "AUTH_CONFIG_SOURCE"
)) {
  glue_data_lines(c(
    "@param api_key API key. Defaults to a {AUTH_CONFIG_SOURCE} key. Necessary in",
    "  order to make unauthorized \"token-free\" requests for public resources."
  ), .data = .data)
}

PREFIX_auth_config_return_with_key <- function(.data = list(
  PREFIX = "PREFIX"
)) {
  glue_data_lines(c(
    "@return `{PREFIX}_auth_config()`: An object of R6 class `AuthState`,",
    "which is defined in the gargle package. `{PREFIX}_api_key()`: the",
    "current API key. `{PREFIX}_oauth_app()`: the current",
    "[httr::oauth_app()]."
  ), .data = .data)
}

PREFIX_auth_config_return_without_key <- function(.data = list(
  PREFIX = "PREFIX"
)) {
  glue_data_lines(c(
    "@return `{PREFIX}_auth_config()`: An object of R6 class `AuthState`,",
    "which is defined in the gargle package. `{PREFIX}_oauth_app()`: the ",
    "current [httr::oauth_app()]."
  ), .data = .data)
} # nocov end

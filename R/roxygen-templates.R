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
    "[{PREFIX}_auth_config()] to bring your own OAuth app or API key."
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
)) {
  glue_data_lines(c(
    "@description",
    "Put {PACKAGE} into a de-authorized state. Instead of sending a token,",
    "{PACKAGE} will send an API key. This can be used to access public",
    "resources for which no Google sign-in is required. This is handy for using",
    "{PACKAGE} in a non-interactive setting to make requests that do not",
    "require a token. It will prevent the attempt to obtain a token",
    "interactively in the browser. A built-in API key is used by default or",
    "the user can configure their own via [{PREFIX}_auth_config()]."
  ), .data = .data)
}

# PREFIX_token() ----------------------------------------------------------

PREFIX_token_description <- function(.data = list(
  API    = "GOOGLE API",
  PREFIX = "PREFIX"
)) {
  glue_data_lines(c(
    "@description",
    "For internal use or for those programming around the {API}.",
    "Returns a token pre-processed with [httr::config()]. Most users",
    "do not need to handle tokens \"by hand\" or, even if they need some",
    "control, [{PREFIX}_auth()] is what they need. If there is no current",
    "token, [{PREFIX}_auth()] is called to either load from cache or",
    "initiate OAuth2.0 flow. If auth has been deactivated via",
    "[{PREFIX}_auth_config()], `{PREFIX}_token()` returns `NULL`."
  ), .data = .data)
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
    "possible with [{PREFIX}_auth()]. Learn more in Google's documentation:",
    "[Credentials, access, security, and",
    "identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279)",
    "and [Using OAuth 2.0 for Installed Applications](https://developers.google.com/identity/protocols/OAuth2InstalledApp).",
    "`{PREFIX}_auth_config()` gives control of:",
    "   * The OAuth app. If you want to use your own app, setup a new project",
    "     in [Google Developers Console](https://console.developers.google.com).",
    "     Follow the instructions in [OAuth 2.0 for Mobile & Desktop",
    "     Apps](https://developers.google.com/identity/protocols/OAuth2InstalledApp)",
    "     to obtain your own client ID and secret. Either make an app from",
    "     your client ID and secret via [httr::oauth_app()] or provide a path",
    "     to the JSON file containing same, which you can download from",
    "     [Google Developers Console](https://console.developers.google.com)."
  )
  if (.deauth_possible) {
    lines <- append(lines, c(
    "   * The API key. If {PACKAGE} is deauthorized via",
    "     [{PREFIX}_deauth()], all requests will be sent with an API key in",
    "     lieu of a token. If you want to provide your own API key, setup a",
    "     project as described above and follow the instructions in",
    "     [Setting up API keys](https://support.google.com/googleapi/answer/6158862).",
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

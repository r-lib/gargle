render_lines <- function(..., .data) { # nocov start
  vapply(
    X = c(...),
    FUN = function(line) glue_data(.x = .data, line, .open = "<<", .close = ">>"),
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
}

# PREFIX_auth() ----------------------------------------------------------

PREFIX_auth_description <- function(.data = list(
  PACKAGE    = "PACKAGE",
  YOUR_STUFF = "YOUR STUFF",
  PRODUCT    = "A GOOGLE PRODUCT"
)) {
  render_lines(
    "@description",
    "Authorize <<PACKAGE>> to view and manage <<YOUR_STUFF>>. By default,",
    "you are directed to a web browser, asked to sign in to your Google",
    "account, and to grant <<PACKAGE>> permission to operate on your behalf",
    "with <<PRODUCT>>. By default, these user credentials are cached in a",
    "file below your home directory, `~/.R/gargle/gargle-oauth`, from where",
    "they can be automatically refreshed, as necessary. Storage at the user",
    "level means the same token can be used across multiple projects and",
    "tokens are less likely to be synced to the cloud by accident.",
    .data = .data
  )
}

PREFIX_auth_details <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
)) {
  render_lines(
    "@details",
    "Most users, most of the time, do not need to call `<<PREFIX>>_auth()`",
    "explicitly -- it is triggered by the first action that requires",
    "authorization. Even when called, the default arguments often suffice.",
    "However, when necessary, this function allows the user to explicitly:",
    "  * Declare which Google identity to use, via an email address. If there",
    "    are multiple cached tokens, this can clarify which one to use. It can",
    "    also force <<PACKAGE>> to switch from one identity to another. If",
    "    there's no cached token for the email, this triggers a return to the",
    "    browser to choose the identity and give consent.",
    "  * Load a service account token (as opposed to OAuth).",
    "  * Specify non-default behavior re: token caching and out-of-bound",
    "    authentication.",
    "",
    "For even deeper control over auth, use [<<PREFIX>>_auth_config()] to use",
    "your own OAuth app or API key.",
    .data = .data
  )
}

PREFIX_auth_params_email <- function() {
  "@param email Optional; email address associated with the desired Google user."
}
PREFIX_auth_params_path <- function() {
  "@param path Optional; path to the downloaded JSON file for a service token."
}
PREFIX_auth_params_scopes <- function(.data = list(
  SCOPES_LINK = "https://developers.google.com/identity/protocols/googlescopes"
)) {
  render_lines(
    "@param scopes Optional; scope(s) to use. See your choices at",
    "[OAuth 2.0 Scopes for Google APIs](<<SCOPES_LINK>>).",
    .data = .data
  )
}
PREFIX_auth_params_cache_use_oob <- function() {
  "@inheritParams gargle::gargle2.0_token"
}

# PREFIX_deauth() ----------------------------------------------------------

PREFIX_deauth_description <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
)) {
  render_lines(
    "@description",
    "Put <<PACKAGE>> into a de-authorized state. Instead of sending a token,",
    "<<PACKAGE>> will send its API key. This can be used to access public",
    "files for which no Google sign-in is required. This is handy for using",
    "<<PACKAGE>> in a non-interactive setting to make requests that do not",
    "require a token. It will prevent the attempt to obtain a token",
    "interactively in the browser. A built-in API key is used by default or",
    "the user can configure their own via [<<PREFIX>>_auth_config()].",
    .data = .data
  )
}

# PREFIX_token() ----------------------------------------------------------

PREFIX_token_description <- function(.data = list(
  API    = "GOOGLE API",
  PREFIX = "PREFIX"
)) {
  render_lines(
    "@description",
    "For internal use or for those programming around the <<API>>.",
    "Returns a token pre-processed with [httr::config()]. Most users",
    "do not need to handle tokens \"by hand\" or, even if they need some",
    "control, [<<PREFIX>>_auth()] is what they need. If there is no current",
    "token, [<<PREFIX>>_auth()] is called to either load from cache or",
    "initiate OAuth2.0 flow. If auth has been deactivated via",
    "[<<PREFIX>>_auth_config()], `<<PREFIX>>_token()` returns `NULL`.",
    .data = .data
  )
}

PREFIX_token_return <- function() {
  "@return A `request` object (an S3 class provided by [httr][httr::httr])."
}

# PREFIX_auth_config() -------------------------------------------------------

PREFIX_auth_config_description <- function(.data = list(
  PACKAGE = "PACKAGE",
  PREFIX  = "PREFIX"
)) {
  render_lines(
    "@description",
    "These functions give the user more control over auth than what is",
    "possible with [<<PREFIX>>_auth()]. Learn more in Google's documentation:",
    "[Credentials, access, security, and",
    "identity](https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279)",
    "and [Using OAuth 2.0 for Installed Applications](https://developers.google.com/identity/protocols/OAuth2InstalledApp).",
    "`<<PREFIX>>_auth_config()` gives control of:",
    "   * The OAuth app. If you want to use your own app, setup a new project",
    "     in [Google Developers Console](https://console.developers.google.com).",
    "     Follow the instructions in [OAuth 2.0 for Mobile & Desktop",
    "     Apps](https://developers.google.com/identity/protocols/OAuth2InstalledApp)",
    "     to obtain your own client ID and secret. Either make an app from",
    "     your client ID and secret via [httr::oauth_app()] or provide a path",
    "     to the JSON file containing same, which you can download from",
    "     [Google Developers Console](https://console.developers.google.com).",
    "   * The API key. If <<PACKAGE>> is deauthorized via",
    "     [<<PREFIX>>_deauth()], all requests will be sent with an API key in",
    "     lieu of a token. If you want to provide your own API key, setup a",
    "     project as described above and follow the instructions in",
    "     [Setting up API keys](https://support.google.com/googleapi/answer/6158862).",
    "",
    "`<<PREFIX>>_api_key()` and `<<PREFIX>>_oauth_app()` retrieve the",
    " currently configured API key and OAuth app, respectively.",
    .data = .data
  )
}

PREFIX_auth_config_params <- function() {
  c(
    "@param app OAuth app. Defaults to a tidyverse app.",
    "@param api_key API key. Defaults to a tidyverse key. Necessary in order",
    "  to make unauthorized \"token-free\" requests for public resources.",
    "@inheritParams gargle::oauth_app_from_json"
  )
}

PREFIX_auth_config_return <- function(.data = list(
  PREFIX = "PREFIX"
)) {
  render_lines(
    "@return `<<PREFIX>>_auth_config()`: An object of R6 class `AuthState`,",
    "which is defined in the gargle package. `<<PREFIX>>_api_key()`: the",
    "current API key. `<<PREFIX>>_oauth_app()`: the current",
    "[httr::oauth_app()].",
    .data = .data
  )
} # nocov end

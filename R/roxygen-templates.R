# nocov start

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
# )

# 2023-03 developments related to the 'app' -> 'client' transition:
# - `PREFIX_auth_configure_description()` crosslinks to
#   `PREFIX_oauth_client()` now, not `PREFIX_oauth_app()`
# - `PREFIX_auth_configure_params()` gains `client` argument
# - `PREFIX_auth_configure_params()` deprecates the `app` argument and uses a
#   lifecycle badge
# - `PREFIX_auth_configure_params() crosslinks to
#   `gargle::gargle_oauth_client_from_json()` which requires gargle (>= 1.3.0)

glue_data_lines <- function(.data, lines, ..., .envir = caller_env()) {
  # work around name collision of `.x` of map_chr() vs. of glue_data()
  # and confusion re: `...` of glue_data_lines() vs. `...` of map_chr()
  # plus: I've only got compat-purrr here, so I have to write a function
  gd <- function(line) glue_data(.x = .data, line, ..., .envir = .envir)
  map_chr(lines, gd)
}

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
    "behalf with {PRODUCT}. By default, with your permission, these user",
    "credentials are cached in a folder below your home directory, from where",
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
    "",
    "However, when necessary, `{PREFIX}_auth()` allows the user to explicitly:",
    "  * Declare which Google identity to use, via an `email` specification.",
    "  * Use a service account token or workload identity federation via",
    "    `path`.",
    "  * Bring your own `token`.",
    "  * Customize `scopes`.",
    "  * Use a non-default `cache` folder or turn caching off.",
    "  * Explicitly request out-of-bound auth via `use_oob`.",
    "",
    "If you are interacting with R within a browser (applies to RStudio",
    "Server, Posit Workbench, Posit Cloud, and Google Colaboratory), you need",
    "oob auth or the pseudo-oob variant. If this does not happen",
    "automatically, you can request it explicitly with `use_oob = TRUE` or,",
    "more persistently, by setting an option via",
    "`options(gargle_oob_default = TRUE)`.",
    "",
    "The choice between conventional oob or pseudo-oob auth is determined",
    "by the type of OAuth client. If the client is of the \"installed\" type,",
    "`use_oob = TRUE` results in conventional oob auth. If the client is of",
    "the \"web\" type, `use_oob = TRUE` results in pseudo-oob auth. Packages",
    "that provide a built-in OAuth client can usually detect which type of",
    "client to use. But if you need to set this explicitly, use the",
    "`\"gargle_oauth_client_type\"` option:",
    "```r",
    "options(gargle_oauth_client_type = \"web\")       # pseudo-oob",
    "# or, alternatively",
    "options(gargle_oauth_client_type = \"installed\") # conventional oob",
    "```",
    "",
    "For details on the many ways to find a token, see",
    "[gargle::token_fetch()]. For deeper control over auth, use",
    "[{PREFIX}_auth_configure()] to bring your own OAuth client or API key.",
    "Read more about gargle options, see [gargle::gargle_options]."
  ), .data = .data)
}

PREFIX_auth_params <- function() {
  c(
    "@inheritParams gargle::credentials_service_account",
    "@inheritParams gargle::credentials_external_account",
    "@inheritParams gargle::credentials_app_default",
    "@inheritParams gargle::credentials_gce",
    "@inheritParams gargle::credentials_byo_oauth2",
    "@inheritParams gargle::credentials_user_oauth2",
    "@inheritParams gargle::gargle2.0_token"
  )
}

# PREFIX_deauth() ----------------------------------------------------------

PREFIX_deauth_description_with_api_key <- function(.data = list(
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
    "[{PREFIX}_api_key()].",
    if (.fallback_api_key) {
      "In the absence of a user-configured key, a built-in default key is used."
    }
  )
  glue_data_lines(lines, .data = .data)
}

PREFIX_deauth_description_no_api_key <- function(.data = list(
                                                   PACKAGE = "PACKAGE",
                                                   PREFIX  = "PREFIX"
                                                 ), .fallback_api_key = TRUE) {
  lines <- c(
    "@description",
    "Clears any currently stored token. The next time {PACKAGE} needs a token,",
    "the token acquisition process starts over, with a fresh call to",
    "[{PREFIX}_auth()] and, therefore, internally, a call to",
    "[gargle::token_fetch()]. Unlike some other packages that use gargle,",
    "{PACKAGE} is not usable in a de-authorized state. Therefore, calling",
    "`{PREFIX}_deauth()` only clears the token, i.e. it does NOT imply that",
    "subsequent requests are made with an API key in lieu of a token."
  )
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
    "initiate OAuth2.0 flow.",
    if (.deauth_possible) {
      c(
        "If auth has been deactivated via [{PREFIX}_deauth()], `{PREFIX}_token()`",
        "returns `NULL`."
      )
    }
  )
  glue_data_lines(lines, .data = .data)
}

PREFIX_token_return <- function() {
  "@return A `request` object (an S3 class provided by [httr][httr::httr])."
}

# PREFIX_has_token() ----------------------------------------------------------

PREFIX_has_token_description <- function(.data = list(PACKAGE = "PACKAGE")) {
  glue_data_lines(c(
    "@description",
    "Reports whether {PACKAGE} has stored a token, ready for use in downstream",
    "requests."
  ), .data = .data)
}

PREFIX_has_token_return <- function() {
  "@return Logical."
}

# PREFIX_auth_configure() -------------------------------------------------------

PREFIX_auth_configure_description <- function(.data = list(
                                                PACKAGE = "PACKAGE",
                                                PREFIX  = "PREFIX"
                                              ), .has_api_key = TRUE, .fallbacks = TRUE) {
  lines <- c(
    "@description",
    "These functions give more control over and visibility into the auth",
    "configuration than [{PREFIX}_auth()] does. `{PREFIX}_auth_configure()`",
    "lets the user specify their own:",
    "  * OAuth client, which is used when obtaining a user token.",
    if (.has_api_key) {
      c(
        "  * API key. If {PACKAGE} is de-authorized via [{PREFIX}_deauth()], all",
        "    requests are sent with an API key in lieu of a token."
      )
    },
    "",
    'See the `vignette("get-api-credentials", package = "gargle")`',
    "for more.",
    if (.fallbacks) {
      c(
        "If the user does not configure these settings, internal defaults",
        "are used."
      )
    },
    "",
    if (.has_api_key) {
      c(
        "`{PREFIX}_oauth_client()` and `{PREFIX}_api_key()` retrieve the",
        "currently configured OAuth client and API key, respectively."
      )
    } else {
      "`{PREFIX}_oauth_client()` retrieves the currently configured OAuth client."
    }
  )
  glue_data_lines(lines, .data = .data)
}

PREFIX_auth_configure_params <- function(.has_api_key = TRUE) {
  c(
    "@param client A Google OAuth client, presumably constructed via",
    "[gargle::gargle_oauth_client_from_json()]. Note, however, that it is",
      "preferred to specify the client with JSON, using the `path` argument.",
    "@inheritParams gargle::gargle_oauth_client_from_json",
    if (.has_api_key) {
      "@param api_key API key."
    },
    "@param app `r lifecycle::badge('deprecated')` Replaced by the `client`",
    "argument."
  )
}

PREFIX_auth_configure_return <- function(.data = list(
                                           PREFIX = "PREFIX"
                                         ), .has_api_key = TRUE) {
  lines <- c(
    "@return",
    "  * `{PREFIX}_auth_configure()`: An object of R6 class",
    "    [gargle::AuthState], invisibly.",
    "  * `{PREFIX}_oauth_client()`: the current user-configured OAuth client.",
    if (.has_api_key) {
      "  * `{PREFIX}_api_key()`: the current user-configured API key."
    }
  )
  glue_data_lines(lines, .data = .data)
}

# PREFIX_user() ----------------------------------------------------------

PREFIX_user_description <- function() {
  c(
    "@description",
    "Reveals the email address of the user associated with the current token.",
    "If no token has been loaded yet, this function does not initiate auth."
  )
}

PREFIX_user_seealso <- function() {
  c(
    "@seealso [gargle::token_userinfo()], [gargle::token_email()],",
    "[gargle::token_tokeninfo()]"
  )
}

PREFIX_user_return <- function() {
  "@return An email address or, if no token has been loaded, `NULL`."
}

# nocov end

# This file has its origins in oauth-init.R in httr.
# Motivated by the need to support the pseudo-OOB flow.
#
# Affected functions:
# - Modified: init_oauth2.0(). This function is the workhorse for the
#   $init_credentials() method of the Token2.0/Gargle2.0 class. Previously,
#   Gargle2.0 ultimately delegated to the Token2.0 method, but now the method is
#   fully implemented for Gargle2.0.
# - Modified: oauth_authorize(). This function gains the ability to do code
#   exchange *with state*, by calling the new function
#   oauth_exchanger_with_state().
# - Added: oauth_exchanger_with_state()
# - Added: csrf_token(). Used to create the `state` token (example of a
#   cross-site request forgery token). Switched one existing use of
#   httr:::nonce() to this, now that I can.
# - The internal helper check_scope() got inlined (it was a mix of a checker
#   and a processor).
# - The internal helper check_oob() got modified to use gargle conventions.

#' Retrieve OAuth 2.0 access token, but specific to gargle
#'
#' @param endpoint An OAuth endpoint, presumably the one returned by
#'   `gargle_oauth_endpoint()`. The fact that this is even an argument is
#'   because this function is based on `httr::init_oauth2.0()`.
#' @param app An OAuth client, preferably an instance of `gargle_oauth_client`.
#' @param scope a character vector of scopes to request.
#' @param use_oob Whether to use out-of-band auth. Results in conventional OOB
#'   if the `app` is of type `"installed"` (or if type is unknown) and
#'   pseudo-OOB if the `app` is of type `"web"`.
#' @param oob_value if provided, specifies the value to use for the redirect_uri
#'   parameter when retrieving an authorization URL. For conventional OOB, this
#'   defaults to "urn:ietf:wg:oauth:2.0:oob". For pseudo-OOB, this should be the
#'   (or a) redirect URI configured for the OAuth client. Consulted only when
#'   `use_oob = TRUE`.
#' @param query_authorize_extra Named list of query parameters to include in the
#'   initial request to the authorization server.
#' @noRd
init_oauth2.0 <- function(endpoint = gargle_oauth_endpoint(),
                          app = gargle_client(),
                          scope = NULL,
                          use_oob = gargle_oob_default(),
                          oob_value = NULL,
                          is_interactive = interactive(),
                          query_authorize_extra = list()) {
  check_character(scope, allow_null = TRUE)
  scope <- glue_collapse(scope, sep = " ")

  use_oob <- check_oob(use_oob, oob_value)

  client_type <- if (inherits(app, "gargle_oauth_client")) app$type else NA

  if (use_oob) {
    redirect_uri <- oob_value %||% "urn:ietf:wg:oauth:2.0:oob"

    if (identical(client_type, "web")) { # pseudo-oob flow
      # https://developers.google.com/identity/protocols/oauth2/web-server#creatingclient

      # We need so-called "offline" access, so the access token can be
      # refreshed without re-prompting the user for permission.
      # Specifically, this is necessary (though not sufficient!) to make the
      # authorization server return a **refresh token** in addition to an
      # access token.
      # Offline access is the default for installed applications, but it is NOT
      # the default for web apps, so we must explicitly request it.
      query_authorize_extra[["access_type"]] <- "offline"

      # https://stackoverflow.com/questions/10827920/not-receiving-google-oauth-refresh-token
      # https://developers.google.com/identity/protocols/oauth2/openid-connect#re-consent

      # By default, for a web app, the user is only prompted for consent once
      # per project. And this is necessary in order to get a refresh token.
      # So we must explicitly ask for re-consent.
      query_authorize_extra[["prompt"]] <- "consent"

      state <- csrf_token()
    } else { # conventional oob
      state <- NULL
    }
  } else {
    redirect_uri <- httr::oauth_callback()
    state <- csrf_token()
  }

  authorize_url <- httr::oauth2.0_authorize_url(
    endpoint,
    app,
    scope = scope,
    redirect_uri = redirect_uri,
    state = state,
    query_extra = query_authorize_extra
  )
  code <- oauth_authorize(
    authorize_url,
    oob = use_oob,
    client_type = client_type,
    state = state
  )

  # Use authorisation code to get (temporary) access token
  httr::oauth2.0_access_token(
    endpoint,
    app,
    code = code,
    redirect_uri = redirect_uri
  )
}

# https://developers.google.com/identity/protocols/oauth2/openid-connect#createxsrftoken
# "These tokens are often referred to as cross-site request forgery (CSRF)
# tokens.
#
# One good choice for a state token is a string of 30 or so characters
# constructed using a high-quality random-number generator."
csrf_token <- function(n_bytes = 16) {
  paste0(as.character(openssl::rand_bytes(n_bytes)), collapse = "")
}

oauth_authorize <- function(url, oob = FALSE, client_type = NA, state = NULL) {
  if (oob) {
    if (identical(client_type, "web")) { # pseudo oob
      oauth_exchanger_with_state(url, state)$code
    } else {
      httr::oauth_exchanger(url)$code
    }
  } else {
    httr::oauth_listener(url)$code
  }
}

oauth_exchanger_with_state <- function(request_url, state) {
  httr::BROWSE(request_url)

  info_enc <- trimws(readline("Enter authorization code: "))
  info <- jsonlite::fromJSON(rawToChar(openssl::base64_decode(info_enc)))
  if (!identical(info$state, state)) {
    stop("state did not match")
  }
  list(code = info$code)
}

check_oob <- function(use_oob, oob_value = NULL) {
  check_bool(use_oob)

  if (!use_oob && !is_installed("httpuv")) {
    gargle_info(
      "The {.pkg httpuv} package is not installed; using out-of-band auth.")
    use_oob <- TRUE
  }

  if (use_oob && !is_interactive()) {
    gargle_abort("Out-of-band auth only works in an interactive session.")
  }

  if (!is.null(oob_value) && !use_oob) {
    gargle_abort("
      The {.arg oob_value} argument can only be used when {.code use_oob = TRUE}.")
  }

  if (use_oob && !is.null(oob_value)) {
    check_string(oob_value)
  }

  use_oob
}

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
# - The internal helpers check_scope() and check_oob() came along for the ride,
#   to support init_oauth2.0(). These got modified to use gargle conventions,
#   e.g. gargle_abort() instead of stop().

#' Retrieve OAuth 2.0 access token, but specific to gargle
#'
#' @param endpoint An OAuth endpoint, presumably the one returned by
#'   `gargle_oauth_endpoint()`. The fact that this is even an argument is
#'   because this function is based on `httr::init_oauth2.0()`.
#' @param app An OAuth consumer application
#' @param scope a character vector of scopes to request.
#' @param use_oob if FALSE, use a local webserver for the OAuth dance.
#'   Otherwise, provide a URL to the user and prompt for a validation code.
#'   Defaults to the of the `"httr_oob_default"` default, or `TRUE` if `httpuv`
#'   is not installed.
#' @param oob_value if provided, specifies the value to use for the redirect_uri
#'   parameter when retrieving an authorization URL. Defaults to
#'   "urn:ietf:wg:oauth:2.0:oob". Requires `use_oob = TRUE`.
#' @param query_authorize_extra Default to `list()`. Set to named list holding
#'   query parameters to append to initial auth page query. Useful for some
#'   APIs.
#' @noRd
init_oauth2.0 <- function(endpoint = gargle_oauth_endpoint(),
                          app = gargle_app(),
                          scope = NULL,
                          use_oob = gargle_oob_default(),
                          oob_value = NULL,
                          is_interactive = interactive(),
                          query_authorize_extra = list()) {
  scope <- check_scope(scope)
  use_oob <- check_oob(use_oob, oob_value)
  client_type <- if (inherits(app, "gargle_oauth_client")) app$type else NA
  if (use_oob) {
    redirect_uri <- oob_value %||% "urn:ietf:wg:oauth:2.0:oob"
    query_authorize_extra[["ack_oob_shutdown"]] <- "2022-10-03"
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
    redirect_uri <- app$redirect_uri
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
csrf_token <- function(n_bytes = 15) {
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

# Parameter checking ------------------------------------------------------

check_scope <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  if (!is.character(x)) {
    stop("`scope` must be a character vector", call. = FALSE)
  }
  paste(x, collapse = " ")
}

# Wrap base::interactive in a non-primitive function so that the call can be mocked for testing
is_interactive <- function() interactive()

check_oob <- function(use_oob, oob_value = NULL) {
  if (!is.logical(use_oob) || length(use_oob) != 1) {
    stop("`use_oob` must be a length-1 logical vector", call. = FALSE)
  }

  if (!use_oob && !is_installed("httpuv")) {
    message("httpuv not installed, defaulting to out-of-band authentication")
    use_oob <- TRUE
  }

  if (use_oob) {
    if (!is_interactive()) {
      stop(
        "Can only use oob authentication in an interactive session",
        call. = FALSE
      )
    }
  }

  if (!is.null(oob_value)) {
    if (!use_oob) {
      stop(
        "Can only use custom oob value if use_oob is enabled",
        call. = FALSE
      )
    }
  }

  use_oob
}

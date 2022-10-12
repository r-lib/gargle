#' Retrieve OAuth 2.0 access token.
#'
#' See demos for use.
#'
#' @inheritParams init_oauth1.0
#' @param scope a character vector of scopes to request.
#' @param user_params Named list holding endpoint specific parameters to pass to
#'   the server when posting the request for obtaining or refreshing the
#'   access token.
#' @param type content type used to override incorrect server response
#' @param use_oob if FALSE, use a local webserver for the OAuth dance.
#'   Otherwise, provide a URL to the user and prompt for a validation
#'   code. Defaults to the of the `"httr_oob_default"` default,
#'   or `TRUE` if `httpuv` is not installed.
#' @param oob_value if provided, specifies the value to use for the redirect_uri
#'   parameter when retrieving an authorization URL. Defaults to "urn:ietf:wg:oauth:2.0:oob".
#'   Requires `use_oob = TRUE`.
#' @param use_basic_auth if `TRUE` use http basic authentication to
#'   retrieve the token. Some authorization servers require this.
#'   If `FALSE`, the default, retrieve the token by including the
#'   app key and secret in the request body.
#' @param config_init Additional configuration settings sent to
#'   [POST()], e.g. [user_agent()].
#' @param client_credentials Default to `FALSE`. Set to `TRUE` to use
#'   *Client Credentials Grant* instead of *Authorization
#'   Code Grant*. See <https://tools.ietf.org/html/rfc6749#section-4.4>.
#' @param query_authorize_extra Default to `list()`. Set to named list
#'   holding query parameters to append to initial auth page query. Useful for
#'   some APIs.
#' @export
#' @keywords internal
init_oauth2.0 <- function(endpoint, app, scope = NULL,
                          user_params = NULL,
                          type = NULL,
                          use_oob = getOption("httr_oob_default"),
                          oob_value = NULL,
                          is_interactive = interactive(),
                          use_basic_auth = FALSE,
                          config_init = list(),
                          client_credentials = FALSE,
                          query_authorize_extra = list()) {
  scope <- check_scope(scope)
  use_oob <- check_oob(use_oob, oob_value)
  if (use_oob) {
    redirect_uri <- if (!is.null(oob_value)) oob_value else "urn:ietf:wg:oauth:2.0:oob"
    state <- NULL
  } else {
    redirect_uri <- app$redirect_uri
    state <- nonce()
  }

  # Some Oauth2 grant type not required an authorization request and code
  # (see https://tools.ietf.org/html/rfc6749#section-4.4)
  if (client_credentials) {
    code <- NULL
  } else {
    authorize_url <- oauth2.0_authorize_url(
      endpoint,
      app,
      scope = scope,
      redirect_uri = redirect_uri,
      state = state,
      query_extra = query_authorize_extra
    )
    code <- oauth_authorize(authorize_url, use_oob)
  }

  # Use authorisation code to get (temporary) access token
  oauth2.0_access_token(
    endpoint,
    app,
    code = code,
    user_params = user_params,
    type = type,
    redirect_uri = redirect_uri,
    client_credentials = client_credentials,
    use_basic_auth = use_basic_auth,
    config = config_init
  )
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


oauth_authorize <- function(url, oob = FALSE) {
  if (oob) {
    oauth_exchanger(url)$code
  } else {
    oauth_listener(url)$code
  }
}

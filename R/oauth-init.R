#' Retrieve OAuth 2.0 access token, but specific to gargle
#'
#' @param endpoint An OAuth endpoint, presumably the one returned by
#'   `gargle_oauth_endpoint()`
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
init_oauth2.0 <- function(endpoint,
                          app,
                          scope = NULL,
                          use_oob = getOption("httr_oob_default"),
                          oob_value = NULL,
                          is_interactive = interactive(),
                          query_authorize_extra = list()) {
  scope <- check_scope(scope)
  use_oob <- check_oob(use_oob, oob_value)
  if (use_oob) {
    redirect_uri <- if (!is.null(oob_value)) oob_value else "urn:ietf:wg:oauth:2.0:oob"
    state <- NULL
  } else {
    redirect_uri <- app$redirect_uri
    # TODO: should we use openssl::rand_bytes() here too?
    state <- nonce()
  }

  authorize_url <- httr::oauth2.0_authorize_url(
    endpoint,
    app,
    scope = scope,
    redirect_uri = redirect_uri,
    state = state,
    query_extra = query_authorize_extra
  )
  code <- oauth_authorize(authorize_url, use_oob)

  # Use authorisation code to get (temporary) access token
  httr::oauth2.0_access_token(
    endpoint,
    app,
    code = code,
    redirect_uri = redirect_uri
  )
}

# need this temporarily
nonce <- function(length = 10) {
  paste(sample(c(letters, LETTERS, 0:9), length, replace = TRUE),
    collapse = ""
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
    httr::oauth_exchanger(url)$code
  } else {
    httr::oauth_listener(url)$code
  }
}

#' Generate a gargle token
#'
#' Constructor function for objects of class [Gargle2.0].
#'
#' @param email Optional. Allows user to target a specific Google identity. If
#'   specified, this is used for token lookup, i.e. to determine if a suitable
#'   token is already available in the cache. If no such token is found, `email`
#'   is used to pre-select the targetted Google identity in the OAuth chooser.
#'   Note, however, that the email associated with a token when it's cached is
#'   always determined from the token itself, never from this argument. Use `NA`
#'   or `FALSE` to match nothing and force the OAuth dance in the browser. Use
#'   `TRUE` to allow email auto-discovery, if exactly one matching token is
#'   found in the cache. Specify just the domain with a glob pattern, e.g.
#'   `"*@example.com"`, to create code that "just works" for both
#'   `alice@example.com` and `bob@example.com`. Defaults to the option named
#'   "gargle_oauth_email", retrieved by [gargle::gargle_oauth_email()].
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @param package Name of the package requesting a token. Used in messages.
#' @param scope A character vector of scopes to request.
#' @param use_oob Whether to prefer "out of band" authentication. Defaults to
#'   the option named "gargle_oob_default", retrieved via
#'   [gargle::gargle_oob_default()].
#' @param cache Specifies the OAuth token cache. Defaults to the option named
#'   "gargle_oauth_cache", retrieved via [gargle::gargle_oauth_cache()].
#' @inheritParams httr::oauth2.0_token
#' @param ... Absorbs arguments intended for use by other credential functions.
#'   Not used.
#' @return An object of class [Gargle2.0], either new or loaded from the cache.
#' @export
#' @examples
#' \dontrun{
#' gargle2.0_token()
#' }
gargle2.0_token <- function(email = gargle_oauth_email(),
                            app = gargle_app(),
                            package = "gargle",
                            ## params start
                            scope = NULL,
                            user_params = NULL,
                            type = NULL,
                            use_oob = gargle_oob_default(),
                            ## params end
                            credentials = NULL,
                            cache = if (is.null(credentials)) gargle_oauth_cache() else FALSE, ...) {
  params <- list(
    scope = scope,
    user_params = user_params,
    type = type,
    use_oob = use_oob,
    as_header = TRUE,
    use_basic_auth = FALSE,
    config_init = list(),
    client_credentials = FALSE
  )

  # pseudo-oob flow
  client_type <- if (inherits(app, "gargle_oauth_client")) app$type else NA
  if (use_oob && identical(client_type, "web")) {
    # we need a better mechanism for picking 1 if there are multiple URIs
    params$oob_value <- app$redirect_uris[[1]]
  }

  # adapt the new gargle_oauth_client to httr
  app <- httr::oauth_app(
    appname = app$appname,
    key = app$key,
    secret = app$secret
  )

  Gargle2.0$new(
    email = email,
    app = app,
    package = package,
    params = params,
    credentials = credentials,
    cache_path = cache
  )
}

#' OAuth2 token objects specific to Google APIs
#'
#' @description
#' `Gargle2.0` is based on the [`Token2.0`][httr::Token-class] class provided in
#' httr. The preferred way to create a `Gargle2.0` token is through the
#' constructor function [gargle2.0_token()]. Key differences with `Token2.0`:
#' * The key for a cached `Token2.0` comes from hashing the endpoint, app, and
#' scopes. For the `Gargle2.0` subclass, the identifier or key is expanded to
#' include the email address associated with the token. This makes it easier to
#' work with Google APIs with multiple identities.
#' * `Gargle2.0` tokens are cached, by default, below
#' `"~/.R/gargle/gargle-oauth"`, i.e. at the user level. In contrast, the
#' default location for `Token2.0` is `./.httr-oauth`, i.e. in current working
#' directory. `Gargle2.0` behaviour makes it easier to reuse tokens across
#' projects and makes it less likely that tokens are accidentally synced to a
#' remote location like GitHub or DropBox.
#' * Each `Gargle2.0` token is cached in its own file. The token cache is a
#' directory of such files. In contrast, `Token2.0` tokens are cached as
#' components of a list, which is typically serialized to `./.httr-oauth`.
#'
#' @param email Optional email address. See [gargle2.0_token()] for full details.
#' @param package Name of the package requesting a token. Used in messages.
#'
#' @keywords internal
#' @export
#' @name Gargle-class
Gargle2.0 <- R6::R6Class("Gargle2.0", inherit = httr::Token2.0, list(
  #' @field email Email associated with the token.
  email = NULL,
  #' @field package Name of the package requesting a token. Used in messages.
  package = NULL,
  #' @description Create a Gargle2.0 token
  #' @param app An OAuth consumer application.
  #' @param credentials Exists largely for testing purposes.
  #' @param params A list of parameters for [httr::init_oauth2.0()]. Some we
  #'   actively use in gargle: `scope`, `use_oob`. Most we do not:
  #'   `user_params`, `type`, `as_header`, `use_basic_auth`, `config_init`,
  #'   `client_credentials`.
  #' @param cache_path Specifies the OAuth token cache. Read more in
  #'   [gargle::gargle_oauth_cache()].
  #' @return A Gargle2.0 token.
  initialize = function(email = gargle_oauth_email(),
                        app = gargle_app(),
                        package = "gargle",
                        credentials = NULL,
                        params = list(),
                        cache_path = gargle_oauth_cache()) {
    gargle_debug("Gargle2.0 initialize")
    stopifnot(
      is.null(email) || is_scalar_character(email) ||
        isTRUE(email) || isFALSE(email) || is_na(email),
      is.oauth_app(app),
      is_string(package),
      is.list(params)
    )
    if (identical(email, "")) {
      gargle_abort("
        {.arg email} must not be \"\" (the empty string).
        Do you intend to consult an env var, but it's unset?")
    }
    if (isTRUE(email)) {
      email <- "*"
    }
    if (isFALSE(email) || is_na(email)) {
      email <- NA_character_
    }
    # https://developers.google.com/identity/protocols/OpenIDConnect#login-hint
    # optional hint for the auth server to pre-fill the email box
    login_hint <- if (is_string(email) && !startsWith(email, "*")) email

    self$endpoint   <- gargle_oauth_endpoint()
    self$email      <- email
    self$app        <- app
    self$package    <- package
    params$scope    <- normalize_scopes(add_email_scope(params$scope))
    params$query_authorize_extra <- list(login_hint = login_hint)
    self$params     <- params
    self$cache_path <- cache_establish(cache_path)

    if (!is.null(credentials)) {
      # Use credentials created elsewhere - usually for tests
      gargle_debug("credentials provided directly")
      self$credentials <- credentials
      return(self$cache())
    }

    # Are credentials cached already?
    if (self$load_from_cache()) {
      self
    } else {
      gargle_debug("no matching token in the cache")
      self$init_credentials()
      self$email <- token_email(self) %||% NA_character_
      self$cache()
    }
  },
  #' @description Format a Gargle2.0 token
  #' @param ... Not used.
  format = function(...) {
    x <- list(
      oauth_endpoint = "google",
      app            = self$app$appname,
      email          = cli_this("{.email {self$email}}"),
      scopes         = commapse(base_scope(self$params$scope)),
      credentials    = commapse(names(self$credentials))
    )
    c(
      cli::cli_format_method(
        cli::cli_h1("<Token (via {.pkg gargle})>")
      ),
      glue("{fr(names(x))}: {fl(x)}")
    )
  },
  #' @description Print a Gargle2.0 token
  #' @param ... Not used.
  print = function(...) {
    # a format method is not sufficient for Gargle2.0 because the parent class
    # has a print method
    cli::cat_line(self$format())
  },
  #' @description Generate the email-augmented hash of a Gargle2.0 token
  hash = function() {
    paste(super$hash(), self$email, sep = "_")
  },
  #' @description Put a Gargle2.0 token into the cache
  cache = function() {
    token_into_cache(self)
    self
  },
  #' @description (Attempt to) get a Gargle2.0 token from the cache
  load_from_cache = function() {
    gargle_debug("loading token from the cache")
    if (is.null(self$cache_path) || is_na(self$email)) {
      return(FALSE)
    }

    cached <- token_from_cache(self)
    if (is.null(cached)) {
      return(FALSE)
    }

    gargle_debug("matching token found in the cache")
    self$endpoint    <- cached$endpoint
    self$email       <- cached$email
    self$app         <- cached$app
    self$credentials <- cached$credentials
    self$params      <- cached$params
    TRUE
  },
  #' @description (Attempt to) refresh a Gargle2.0 token
  refresh = function() {
    cred <- refresh_oauth2.0(
      self$endpoint, self$app, self$credentials,
      package = self$package
    )
    if (is.null(cred)) {
      token_remove_from_cache(self)
      # TODO: why do we return the current, invalid, unrefreshed token?
      # at the very least, let's clear the refresh_token, to prevent
      # future refresh attempts
      self$credentials$refresh_token <- NULL
    } else {
      self$credentials <- cred
      self$cache()
    }
    self
  },
  #' @description Initiate a new Gargle2.0 token
  init_credentials = function() {
    gargle_debug("initiating new token")
    if (is_interactive()) {
      if (!isTRUE(self$params$use_oob) && !is_rstudio_server()) {
        encourage_httpuv()
      }
      super$init_credentials()
    } else {
      # TODO: good candidate for an eventual sub-classed gargle error
      # would be useful in testing to know that this is exactly where we aborted
      gargle_abort("OAuth2 flow requires an interactive session.")
    }
  }
))

encourage_httpuv <- function() {
  if (!is_interactive() || isTRUE(is_installed("httpuv"))) {
    return(invisible())
  }
  local_gargle_verbosity("info")
  gargle_info(c(
    "The {.pkg httpuv} package enables a nicer Google auth experience, \\
     in many cases.",
    "It doesn't seem to be installed.",
    "Would you like to install it now?"
  ))
  if (utils::menu(c("Yes", "No")) == 1) {
    utils::install.packages("httpuv")
  }
  invisible()
}

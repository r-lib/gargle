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
#'   `TRUE` to allow email auto-discovery, if a suitable token is found in the
#'   cache. Define the option `gargle.oauth_email` to set a personal default.
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @param package Name of the package requesting a token. Used in messages.
#' @param scope A character vector of scopes to request. The `"email"` scope is
#'   always added if not already present. This is needed to retrieve the email
#'   address associated with the token. This is considered a low value scope and
#'   does not appear on the consent screen.
#' @param use_oob If `FALSE`, use a local webserver for the OAuth dance.
#'   Otherwise, provide a URL to the user and prompt for a validation code.
#'   Defaults to the option `gargle.oob_default` or `TRUE` if httpuv is not
#'   installed.
#' @param cache A logical value or a string. `TRUE` means to cache using the
#'   default user-level cache file, `~/.R/gargle/gargle-oauth`, `FALSE` means
#'   don't cache, and `NA` means to guess using some sensible heuristics. A
#'   string means use the specified path as the cache file.
#' @inheritParams httr::oauth2.0_token
#' @param ... Absorbs arguments intended for use by non-OAuth2 credential
#'   functions. Not used.
#' @return An object of class [Gargle2.0], either new or loaded from the cache.
#' @export
gargle2.0_token <- function(email = getOption("gargle.oauth_email"),
                            app = gargle_app(),
                            package = "gargle",
                            ## params start
                            scope = NULL,
                            user_params = NULL,
                            type = NULL,
                            use_oob = getOption("gargle.oob_default"),
                            ## params end
                            credentials = NULL,
                            cache = if (is.null(credentials)) getOption("gargle.oauth_cache") else FALSE, ...) {
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
#' This is based on the [Token2.0][httr::Token] class provided in httr. These
#' objects should be created through the constructor function
#' [gargle2.0_token()]. In the base Token2.0 class, tokens are cached based on
#' endpoint, app, and scopes. For the `Gargle2.0` subclass, the identifier or
#' key is expanded to include the email address associated with the token. This
#' makes it easier to work with Google APIs with multiple identities. The
#' default location for the token cache is also different: it's now
#' `"~/.R/gargle/gargle-oauth"` instead of `./.httr-oauth`.
#'
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @export
#' @name Gargle-class
Gargle2.0 <- R6::R6Class("Gargle2.0", inherit = httr::Token2.0, list(
  email = NULL,
  package = NULL,
  initialize = function(email = getOption("gargle.oauth_email"),
                        app = gargle_app(),
                        package = "gargle",
                        credentials = NULL,
                        params = list(),
                        cache_path = getOption("gargle.oauth_cache")) {
    "!DEBUG Gargle2.0 initialize"
    stopifnot(
      is.null(email) || is_string(email) ||
        isTRUE(email) || isFALSE(email) || is.na(email),
      is.oauth_app(app),
      is_string(package),
      is.list(params)
    )

    if (isTRUE(email)) {
      email <- "*"
    }
    if (isFALSE(email) || isNA(email)) {
      email <- NULL
    }
    ## https://developers.google.com/identity/protocols/OpenIDConnect#login-hint
    ## optional hint for the auth server to pre-fill the email box
    login_hint <- if (is_string(email) && email != "*") email

    self$endpoint   <- gargle_outh_endpoint()
    self$email      <- email
    self$app        <- app
    self$package    <- package
    params$scope    <- normalize_scopes(add_email_scope(params$scope))
    params$query_authorize_extra <- list(login_hint = login_hint)
    self$params     <- params
    self$cache_path <- cache_establish(cache_path)

    if (!is.null(credentials)) {
      # Use credentials created elsewhere - usually for tests
      "!DEBUG credentials provided directly"
      self$credentials <- credentials
      return(self$cache())
    }

    # Are credentials cached already?
    if (self$load_from_cache()) {
      self
    } else {
      "!DEBUG no matching token in the cache"
      self$init_credentials()
      self$email <- get_email(self) %||% NA_character_
      self$cache()
    }
  },
  print = function(...) {
    cat_line("<Token (via gargle)>")
    cat_line("  <oauth_endpoint> google")
    cat_line("             <app> ", self$app$appname)
    cat_line("           <email> ", self$email)
    cat_line("          <scopes> ", commapse(base_scope(self$params$scope)))
    cat_line("     <credentials> ", commapse(names(self$credentials)))
    cat_line("---")
  },
  hash = function() {
    paste(super$hash(), self$email, sep = "_")
  },
  cache = function() {
    "!DEBUG put token into cache"
    token_into_cache(self)
    self
  },
  load_from_cache = function() {
    "!DEBUG load token from cache"
    if (is.null(self$cache_path)) return(FALSE)

    cached <- token_from_cache(self)
    if (is.null(cached)) return(FALSE)

    "!DEBUG match found in the cache"
    self$endpoint    <- cached$endpoint
    self$email       <- cached$email
    self$app         <- cached$app
    self$credentials <- cached$credentials
    self$params      <- cached$params
    TRUE
  }
))

normalize_scopes <- function(x) {
  stats::setNames(sort(unique(x)), NULL)
}

add_email_scope <- function(scope = NULL) {
  scope <- union(scope %||% character(), "email")
}

#' Create an AuthState
#'
#' Constructor function for objects of class [AuthState].
#'
#' @param package Package name, an optional string. The associated package will
#'   generally by implied by the namespace within which the `AuthState` is
#'   defined. But it's possible to record the package name explicitly and seems
#'   like a good practice.
#' @param app Optional. An OAuth consumer application, as produced by
#'   [httr::oauth_app()].
#' @param api_key Optional. API key (a string). Some APIs accept unauthorized,
#'   "token-free" requests for public resources, but only if the request
#'   includes an API key.
#' @param auth_active Logical. `TRUE` means requests should include a token (and
#'   probably not an API key). `FALSE` means requests should include an API key
#'   (and probably not a token).
#' @param cred Credentials. Typically populated indirectly via [token_fetch()].
#'
#' @return An object of class [AuthState].
#' @export
#' @examples
#' my_app <- httr::oauth_app(
#'   appname = "my_package",
#'   key = "keykeykeykeykeykey",
#'   secret = "secretsecretsecret"
#' )
#'
#' init_AuthState(
#'   package = "my_package",
#'   app = my_app,
#'   api_key = "api_key_api_key_api_key",
#' )
init_AuthState <- function(package = NA_character_,
                           app = NULL,
                           api_key = NULL,
                           auth_active = TRUE,
                           cred = NULL) {
  AuthState$new(
    package     = package,
    app         = app,
    api_key     = api_key,
    auth_active = auth_active,
    cred        = cred
  )
}

#' Authorization state
#'
#' @description
#' An `AuthState` object manages an authorization state, typically on behalf of
#' a client package that makes requests to a Google API.
#'
#' The [How to use gargle for auth in a client
#' package](https://gargle.r-lib.org/articles/gargle-auth-in-client-package.html)
#' vignette describes a design for wrapper packages that relies on an `AuthState`
#' object. This state can then be incorporated into the package's requests for
#' tokens and can control the inclusion of tokens in requests to the target API.
#'
#'   * `api_key` is the simplest way to associate a request with a specific
#'     Google Cloud Platform [project](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy#projects).
#'     A few calls to certain APIs, e.g. reading a public Sheet, can succeed
#'     with an API key, but this is the exception.
#'   * `app` is an OAuth app associated with a specific Google Cloud Platform
#'     [project](https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy#projects).
#'     This is used in the OAuth flow, in which an authenticated user authorizes
#'     the app to access or manipulate data on their behalf.
#'   * `auth_active` reflects whether outgoing requests will be authorized by an
#'     authenticated user or are unauthorized requests for public resources.
#'     These two states correspond to sending a request with a token versus an
#'     API key, respectively.
#'   * `cred` is where the current token is cached within a session, once one
#'     has been fetched. It is generally assumed to be an instance of
#'     [`httr::TokenServiceAccount`][httr::Token-class] or
#'     [`httr::Token2.0`][httr::Token-class] (or a subclass thereof), probably
#'     obtained via [token_fetch()] (or one of its constituent credential
#'     fetching functions).
#'
#' An `AuthState` should be created through the constructor function
#' [init_AuthState()], which has more details on the arguments.
#'
#' @param package Package name.
#' @param app An OAuth consumer application.
#' @param api_key An API key.
#' @param auth_active Logical, indicating whether auth is active.
#' @param cred Credentials.
#'
#' @export
#' @name AuthState-class
AuthState <- R6::R6Class("AuthState", list(
  #' @field package Package name.
  package = NULL,
  #' @field app An OAuth consumer application.
  app = NULL,
  #' @field api_key An API key.
  api_key = NULL,
  #' @field auth_active Logical, indicating whether auth is active.
  auth_active = NULL,
  #' @field cred Credentials.
  cred = NULL,
  #' @description Create a new AuthState
  #' @details For more details on the parameters, see [init_AuthState()]
  initialize = function(package = NA_character_,
                        app = NULL,
                        api_key = NULL,
                        auth_active = TRUE,
                        cred = NULL) {
    gargle_debug("initializing AuthState")
    stopifnot(
      is_scalar_character(package),
      is.null(app) || is.oauth_app(app),
      is.null(api_key) || is_string(api_key),
      is_bool(auth_active),
      is.null(cred) || inherits(cred, "Token2.0")
    )
    self$package     <- package
    self$app         <- app
    self$api_key     <- api_key
    self$auth_active <- auth_active
    self$cred        <- cred
    self
  },
  #' @description Format an AuthState
  #' @param ... Not used.
  format = function(...) {
    x <- list(
      package     = cli_this("{.pkg {self$package}}"),
      app         = self$app$appname,
      api_key     = obfuscate(self$api_key),
      auth_active = self$auth_active,
      # TODO: implement .class angle brackets
      credentials = glue("<{class(self$cred)[[1]]}>")
    )
    c(
      cli::cli_format_method(
        cli::cli_h1("<AuthState (via {.pkg gargle})>")
      ),
      glue("{fr(names(x))}: {fl(x)}")
    )
  },
  #' @description Set the OAuth app
  set_app = function(app) {
    stopifnot(is.null(app) || is.oauth_app(app))
    self$app <- app
    invisible(self)
  },
  #' @description Set the API key
  #' @param value An API key.
  set_api_key = function(value) {
    stopifnot(is.null(value) || is_string(value))
    self$api_key <- value
    invisible(self)
  },
  #' @description Set whether auth is (in)active
  #' @param value Logical, indicating whether to send requests authorized with
  #'   user credentials.
  set_auth_active = function(value) {
    stopifnot(isTRUE(value) || isFALSE(value))
    self$auth_active <- value
    invisible(self)
  },
  #' @description Set credentials
  #' @param cred User credentials.
  set_cred = function(cred) {
    self$cred <- cred
    invisible(self)
  },
  #' @description Clear credentials
  clear_cred = function() {
    self$set_cred(NULL)
  },
  #' @description Get credentials
  get_cred = function() {
    self$cred
  },
  #' @description Report if we have credentials
  has_cred = function() {
    ## FIXME(jennybc): how should this interact with auth_active? should it?
    !is.null(self$cred)
  }
))

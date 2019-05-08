#' Create an AuthState
#'
#' Constructor function for objects of class [AuthState].
#'
#' @param package Package name, an optional string. The associated package will
#'   generally by implied by the namespace within which the `AuthState` is
#'   defined. But it's possible to record the package name explicitly and
#'   seems like a good practice.
#' @param app An OAuth consumer application, as produced by [httr::oauth_app()].
#' @param api_key API key (a string). Necessary in order to make unauthorized
#'   "token-free" requests for public resources. Can be `NULL` if all requests
#'   will be authorized, i.e. they will include a token.
#' @param auth_active Logical. `TRUE` means requests should include a token (and
#'   probably not an API key). `FALSE` means requests should include an API key
#'   (and probably not a token).
#'
#' @return An object of class [AuthState].
#' @export
## FIXME(jennybc): Analogous functions for the Gargle2.0 class default to the
## gargle oauth app. Should we do same in both places? If so, which way?
## Default to gargle app or have no default?
init_AuthState <- function(package = NA_character_,
                           app,
                           api_key,
                           auth_active) {
  AuthState$new(
    package = package,
    app = app,
    api_key,
    auth_active = auth_active
  )
}

#' Authorization state
#'
#' An `AuthState` object manages an authorization state, typically on behalf of
#' a client package that makes requests to a Google API. This state is
#' incorporated into the package's requests for tokens and controls the
#' inclusion of tokens in requests to the target API:
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
#' An `AuthState` should be created through the constructor function
#' [init_AuthState()].
#'
#' @docType class
#' @format An R6 class object.
#' @export
#' @name AuthState-class
AuthState <- R6::R6Class("AuthState", list(
  package = NULL,
  app = NULL,
  api_key = NULL,
  auth_active = NULL,
  cred = NULL,
  initialize = function(package = NA_character_,
                        app,
                        api_key,
                        auth_active,
                        cred = NULL) {
    cat_line("initializing AuthState")
    stopifnot(
      is_string(package),
      is.oauth_app(app),
      is.null(api_key) || is_string(api_key),
      isTRUE(auth_active) || isFALSE(auth_active)
    )
    self$package     <- package
    self$app         <- app
    self$api_key     <- api_key
    self$auth_active <- auth_active
    self$cred        <- cred
    self
  },
  print = function(...) {
    cat_line("<AuthState (via gargle)>")
    cat_line("         <package> ", self$package)
    cat_line("             <app> ", self$app$appname)
    cat_line("         <api_key> ", obfuscate(self$api_key))
    cat_line("     <auth_active> ", self$auth_active)
    cat_line("     <credentials> ", class(self$cred)[[1]])
    cat_line("---")
  },
  set_app = function(app) {
    stopifnot(is.oauth_app(app))
    self$app <- app
    invisible(self)
  },
  set_api_key = function(value) {
    stopifnot(is_string(value))
    self$api_key <- value
    invisible(self)
  },
  set_auth_active = function(value) {
    stopifnot(isTRUE(value) || isFALSE(value))
    self$auth_active <- value
    invisible(self)
  },
  set_cred = function(cred) {
    self$cred <- cred
    invisible(self)
  },
  clear_cred = function() {
    self$set_cred(NULL)
  },
  get_cred = function() {
    self$cred
  },
  has_cred = function() {
    ## FIXME(jennybc): how should this interact with auth_active? should it?
    !is.null(self$cred)
  }
))

#' Authorization state
#'
#' An `AuthState` object manages an authorization state, presumably on behalf of
#' a client package that makes requests to a Google API. This state is
#' incorporated into the package's requests for tokens and controls the
#' inclusion of tokens in requests to the target API:
#'   * `app` and `api_key` identify the package to Google APIs as an
#'     "application".
#'   * `auth_active` reflects whether requests are authorized by an
#'     authenticated user or are unauthorized requests for public resources.
#'   * `cred` is a configured token, ready to send in requests. If
#'     `auth_active = FALSE`, this should be `NULL`.
#'
#' @param app An OAuth consumer application, created by [httr::oauth_app()].
#' @param api_key API key. Necessary in order to make unauthorized "token-free"
#'   requests for public resources. Can be set to `NULL` if all requests will be
#'   authorized, i.e. they will include a token.
#' @param auth_active Logical. `TRUE` means requests should include a token (and
#'   not an API key). `FALSE` means requests should include an API key (and not
#'   a token).
#' @param cred A configured token.
#'
#' @docType class
#' @keywords internal
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
    "!DEBUG AuthState initialize"
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
  }
))

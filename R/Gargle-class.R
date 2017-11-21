#' Generate a Gargle token
#'
#' Constructor function for objects of class [Gargle2.0]. The `"email"` scope
#' is always added if not already present. This is needed to retrieve the email
#' address associated with the token. This is considered a "low value" scope and
#' does not appear on the consent screen.
#'
#' @param email Optional. Allows user to target a specific Google identity. If
#'   specified, this is used only for token lookup, i.e. to determine if a
#'   suitable token is already available in the cache. The email associated with
#'   a token when it's cached is determined from the token itself, not from this
#'   argument.
#' @inheritParams httr::oauth2.0_token
#' @param ... Absorbs arguments intended for use by non-OAuth2 credential
#'   functions. Not used.
#' @return An object of class [Gargle2.0], either new or loaded from the
#'   cache.
#' @export
gargle2.0_token <- function(email = NULL,
                            app = gargle_app(),
                            ## params start
                            scope = NULL,
                            user_params = NULL,
                            type = NULL,
                            use_oob = getOption("gargle.oob_default"),
                            ## params end
                            credentials = NULL,
                            cache = getOption("gargle.oauth_cache"), ...) {
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
    params = params,
    credentials = credentials,
    cache_path = if (is.null(credentials)) cache else FALSE
  )
}

#' OAuth2 token objects specific to Google APIs
#'
#' This is based on the [Token2.0][httr::Token] class provided in httr. These
#' objects should be created through the constructor function
#' [gargle2.0_token()]. In the base Token2.0 class, tokens are cached based on
#' endpoint, app, and scopes. For this subclass, the identifier or key is
#' expanded to include the email address associated with the token. This makes
#' it easier to work with Google APIs using multiple accounts.
#'
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @export
#' @name Gargle-class
Gargle2.0 <- R6::R6Class("Gargle2.0", inherit = httr::Token2.0, list(
  email = NA_character_,
  initialize = function(email = NULL,
                        app = gargle_app(),
                        credentials = NULL,
                        params = list(),
                        cache_path = getOption("gargle.oauth_cache")) {
    "!DEBUG Gargle2.0 initialize"
    stopifnot(is.oauth_app(app), is.list(params))

    self$email <- email
    self$app <- app
    self$endpoint <- httr::oauth_endpoints("google")
    params$scope <- add_email_scope(params$scope)
    self$params <- params
    self$cache_path <- use_cache(cache_path)

    if (!is.null(credentials)) {
      # Use credentials created elsewhere - usually for tests
      self$credentials <- credentials
      return(self)
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
    cat("<Token (via gargle)>\n", sep = "")
    # print(self$endpoint) ## this is TMI IMO
    # also, it's boring --> always google for us
    cat("  <oauth_endpoint> google\n", sep = "")
    # print(self$app) ## this is TMI IMO
    cat("       <oauth_app> ", self$app$appname, "\n", sep = "")
    cat("           <email> ", self$email, "\n", sep = "")
    ## TODO(jennybc) turn this into a helper or sg
    scopes <- gsub("/$", "", gsub("(.*)/(.+$)", "...\\2", self$params$scope))
    cat(
      "          <scopes> ",
      paste0(scopes, collapse = ", "),
      "\n", sep = ""
    )
    cat(
      "     <credentials> ",
      paste0(names(self$credentials), collapse = ", "),
      "\n", sep = ""
    )
    cat(
      "                   (expires in ",
      ceiling(self$credentials$expires_in / 60),
      " mins)", "\n", sep = ""
    )
    cat("---\n")
  },
  hash = function() {
    # endpoint = which site = always google for us
    # app = client identification = often tidyverse (or gargle) app
    # params = scope <- this truly varies across client packages
    msg <- serialize(list(
      self$endpoint,
      self$app,
      normalize_scopes(self$params$scope)
    ), NULL)

    # for compatibility with digest::digest()
    msg <- paste(openssl::md5(msg[-(1:14)]), collapse = "")

    # append the email
    paste(msg, self$email, sep = "-")
  },
  cache = function(path = self$cache_path) {
    "!DEBUG cache a token"
    cache_token(self, path)
    self
  },
  load_from_cache = function() {
    if (is.null(self$cache_path)) return(FALSE)

    if (is.null(self$email)) {
      "!DEBUG searching cache for matches on endpoint + app + scopes"
      "!DEBUG cache_path is `sQuote(self$cache_path)`"
      cached <- fetch_matching_tokens(self$hash(), self$cache_path)
    } else {
      "!DEBUG searching cache for matches on endpoint + app + scopes + email: `sQuote(self$email)`"
      cached <- fetch_cached_token(self$hash(), self$cache_path)
    }

    if (is.null(cached)) return(FALSE)

    self$endpoint <- cached$endpoint
    self$app <- cached$app
    self$email <- cached$email
    self$credentials <- cached$credentials
    self$params <- cached$params
    TRUE
  }))

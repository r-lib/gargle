#' Generate a Gargle token
#'
#' @param email Email address
#' @inheritParams httr::oauth2.0_token
#' @param ... Arguments intended for use by non-OAuth2 credential functions. Not
#'   used.
#' @return A Gargle token
#' @export
gargle2.0_token <- function(email = NULL,
                            app = gargle_app(),
                            ## params start
                            scope = NULL,
                            user_params = NULL,
                            type = NULL,
                            use_oob = getOption("httr_oob_default"),
                            ## params end
                            credentials = NULL,
                            cache = getOption("httr_oauth_cache"), ...) {
  params <- list(
    scope = scope,
    user_params = user_params,
    type = type,
    use_oob = use_oob,
    as_header = TRUE,                           # hard-wired, ok?
    use_basic_auth = FALSE,                     # hard-wired, ok?
    config_init = list(),
    client_credentials = FALSE                  # hard-wired, ok?
  )
  Gargle2.0$new(
    email = email,
    endpoint = httr::oauth_endpoints("google"), # hard-wired, ok?
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
#' it easier to work with Google APIs using multiple accounts
#'
#' @section Scopes: The `"email"` scope is added if not already present. This is
#'   needed to retrieve the email address associated with the token. This is
#'   considered a "low value" scope and does not appear on the consent screen.
#'
#' @docType class
#' @keywords internal
#' @format An R6 class object.
#' @export
#' @name Gargle-class
Gargle2.0 <- R6::R6Class("Gargle2.0", inherit = httr::Token2.0, list(
  email = NA_character_,
  initialize = function(email = NULL,
                        endpoint =  httr::oauth_endpoints("google"),
                        app = gargle_app(),
                        credentials = NULL,
                        params = list(),
                        cache_path = getOption("httr_oauth_cache")) {
    "!DEBUG Gargle2.0 initialize"
    stopifnot(
      httr:::is.oauth_endpoint(endpoint) || !is.null(credentials),
      httr:::is.oauth_app(app),
      is.list(params)
    )

    self$email <- email
    self$app <- app
    self$endpoint <- endpoint
    params$scope <- add_email_scope(params$scope)
    self$params <- params
    self$cache_path <- httr:::use_cache(cache_path)

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
      self$credentials$expires_in / 60,
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
  load_from_cache = function() {
    if (is.null(self$cache_path)) return(FALSE)

    if (is.null(self$email)) {
      "!DEBUG searching cache for matches on endpoint + app + scopes"
      cached <- fetch_matching_tokens(self$hash(), self$cache_path)
    } else {
      "!DEBUG searching cache for matches on endpoint + app + scopes + email: `sQuote(self$email)`"
      cached <- httr:::fetch_cached_token(self$hash(), self$cache_path)
    }

    if (is.null(cached)) return(FALSE)

    self$endpoint <- cached$endpoint
    self$app <- cached$app
    self$email <- cached$email
    self$credentials <- cached$credentials
    self$params <- cached$params
    TRUE
  }))

fetch_matching_tokens <- function(hash, cache_path) {
  if (is.null(cache_path)) return(NULL)

  tokens <- httr:::load_cache(cache_path)
  matches <- mask_email(names(tokens)) == mask_email(hash)

  if (!any(matches)) return(NULL)

  tokens <- tokens[matches]

  if (length(tokens) == 1) {
    "!DEBUG Using a token cached for `extract_email(names(tokens))`"
    return(tokens[[1]])
  }

  ## TODO(jennybc) if not interactive? just use first match? now I just give up
  if (!interactive()) {
    message("Multiple cached tokens exist. Unclear which to use.")
    return(NULL)
  }

  emails <- extract_email(names(tokens))
  cat("Multiple cached tokens exist. Pick the one you want to use.\n")
  cat("Or enter '0' to obtain a new token.")
  this_one <- utils::menu(emails)

  if (this_one == 0) return(NULL)

  tokens[[this_one]]
}

## for this token hash:
## 2a46e6750476326f7085ebdab4ad103d-jenny@rstudio.com
## ^ mask_email() returns this ^    ^ extract_email() returns this ^
mask_email <- function(x) sub("^([^-]*).*", "\\1", x)
extract_email <- function(x) sub(".*-([^-]*)$", "\\1", x)

add_email_scope <- function(scope = NULL) {
  scope <- scope %||% character()
  if (any(scope == "email")) {
    scope
  } else {
    c(scope, "email")
  }
}

normalize_scopes <- function(x) {
  stats::setNames(sort(unique(x)), NULL)
}

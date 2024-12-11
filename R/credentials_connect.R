#' Get a token on Posit Connect
#'
#' @description
#'
#' `r lifecycle::badge('experimental')`
#'
#' Shiny apps running on Posit Connect [can retrieve Google credentials for each
#' individual viewer](https://docs.posit.co/connect/user/oauth-integrations/).
#'
#' Requires the \pkg{connectcreds} package.
#'
#' @inheritParams token_fetch
#' @returns A [httr::Token2.0()] or `NULL`.
#' @family credential functions
#' @examples
#' credentials_connect()
#' @export
credentials_connect <- function(scopes = NULL, ...) {
  gargle_debug("trying {.fun credentials_connect}")
  if (!identical(Sys.getenv("RSTUDIO_PRODUCT"), "CONNECT")) {
    gargle_debug(c("x" = "We don't seem to be on Posit Connect."))
    return(NULL)
  }
  session <- current_shiny_session()
  if (is.null(session)) {
    gargle_debug(c("x" = "Viewer-based credentials only work in Shiny."))
    return(NULL)
  }
  if (!is_installed("connectcreds")) {
    gargle_debug(c(
      "x" = "Viewer-based credentials require the {.pkg connectcreds} package,\
             but it is not installed.",
      "i" = "Redeploy with {.pkg connectcreds} as a dependency if you wish to \
             use viewer-based credentials. The most common way to do this is \
             to add {.code library(connectcreds)} to your {.file app.R} file."
    ))
    return(NULL)
  }
  token <- ConnectToken$new(session, scopes = normalize_scopes(scopes))
  gargle_debug("Connect token: {.val {token$id}}")
  token
}

current_shiny_session <- function() {
  if (!isNamespaceLoaded("shiny")) {
    return(NULL)
  }
  # Avoid taking a Suggests dependency on Shiny, which is otherwise irrelevant
  # to gargle.
  f <- get("getDefaultReactiveDomain", envir = asNamespace("shiny"))
  f()
}

connect_session_id <- function(session = current_shiny_session()) {
  if (is.null(session)) {
    return(NULL)
  }
  session$request$HTTP_POSIT_CONNECT_USER_SESSION_TOKEN
}

#' @noRd
ConnectToken <- R6::R6Class("ConnectToken", inherit = httr::Token2.0, list(
  #' @field id The session identifier associated with this token.
  id = NULL,

  #' @description Get a token on Posit Connect.
  #' @param session A Shiny session.
  #' @param scopes A list of scopes to request for the token.
  #' @return A ConnectToken.
  initialize = function(session, scopes = NULL) {
    gargle_debug("ConnectToken initialize")
    self$id <- connect_session_id(session)
    self$params <- list(scopes = scopes)
    private$session <- session
    self$init_credentials()
  },

  #' @description Enact the actual token exchange with Posit Connect.
  init_credentials = function() {
    gargle_debug("ConnectToken init_credentials")
    scope <- NULL
    if (!is.null(self$params$scopes)) {
      scope <- paste(self$params$scopes, collapse = " ")
    }
    self$credentials <- connectcreds::connect_viewer_token(
      private$session,
      scope = scope
    )
    self
  },

  #' @description Refreshes the token, which means re-doing the entire token
  #'   flow in this case.
  refresh = function() {
    gargle_debug("ConnectToken refresh")
    # This is a slight misuse of httr's notion of "refreshing" a token, but it
    # works in most cases.
    self$init_credentials()
  },

  #' @description Format a [ConnectToken()].
  #' @param ... Not used.
  format = function(...) {
    x <- list(
      id = self$id,
      scopes = self$params$scopes,
      credentials = commapse(names(self$credentials))
    )
    c(
      cli::cli_format_method(
        cli::cli_h1("<ConnectToken (via {.pkg gargle})>")
      ),
      glue("{fr(names(x))}: {fl(x)}")
    )
  },

  #' @description Print a [ConnectToken()].
  #' @param ... Not used.
  print = function(...) cli::cat_line(self$format()),

  #' @description Returns `TRUE` if the token can be refreshed.
  can_refresh = function() TRUE,

  #' @description Placeholder implementation of required method. Returns self.
  cache = function() self,

  #' @description Placeholder implementation of required method. Returns self.
  load_from_cache = function() self,

  #' @description Placeholder implementation of required method. Not used.
  validate = function() {},

  #' @description Placeholder implementation of required method. Not used.
  revoke = function() {}
), private = list(session = NULL))

#' Require OAuth login for Shiny app
#'
#' @description
#' Use this function to enforce Google Auth login for all visitors to a Shiny
#' app. Once logged in, a [token][Gargle-class] will be stored on the Shiny
#' session object and automatically used for any Google API operations that go
#' through gargle.
#'
#' @param app The return value from [shiny::shinyApp()]. For readability,
#'   consider using a pipe operator, i.e. `shinyApp() %>% require_oauth(...)`.
#' @param oauth_app An [httr::oauth_app()] object that provides the OAuth client
#'   ID and secret. See the [How to get your own API
#'   credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
#'   vignette and [oauth_app_from_json()].
#' @inheritParams token_fetch
#' @param welcome_ui A function that provides the UI to be displayed when a user
#'   tries to visit the app without being logged in. See the "Welcome UI"
#'   section below.
#' @param cookie_opts `require_oauth` uses an HTTP cookie to remember login
#'   credentials between visits. Use this parameter to control aspects of the
#'   cookie, such as maximum age (defaults to the duration of the browser
#'   process).
#'
#' @section Welcome UI:
#'
#'   You can use the `welcome_ui` parameter to customize the page that greets
#'   users before they log in. With the default value of `NULL`, users will not
#'   see a welcome message, but instead be immediately directed to a Google
#'   sign-in page.
#'
#'   If you want to welcome the user with some instructions, or at least an
#'   indication of what app they're logging into, the simplest way is to use the
#'   [basic_welcome_ui()] function. This will create a [shiny::fluidPage()] and
#'   put whatever UI you pass it into a centered div; and below that, a Google
#'   sign-in button.
#'
#'   Here's an example with a simple headline and one-line welcome message:
#'
#'   ```r
#'   welcome <- basic_welcome_ui(
#'     h2("Welcome!"),
#'     p("To use this app, please sign in with a Google account.")
#'   )
#'   shinyApp(ui, server) %>% require_oauth(oauth_app, scopes, welcome_ui = welcome)
#'   ```
#'
#'   ![](basic_welcome_ui.png "Basic welcome UI")
#'
#'   You can also provide a completely custom welcome page. To do so, pass a
#'   function that takes two parameters: `req` and `login_url`. The `req`
#'   parameter will be a [Rook](https://github.com/jeffreyhorner/Rook)
#'   environment, and can generally be ignored. The `login_url` parameter is the
#'   URL the user should be directed to when they're ready to log in; this
#'   should be turned into a link or button (see [google_signin_button()]).
#'
#'   ```r
#'   welcome <- function(req, login_url) {
#'     fluidPage(theme = shinythemes::shinytheme("darkly"),
#'       div(style = "padding: 3rem;",
#'         h3("Sign in to continue"),
#'         google_signin_button(login_url, theme = "dark")
#'       )
#'     )
#'   }
#'   shinyApp(ui, server) %>% require_oauth(oauth_app, scopes, welcome_ui = welcome)
#'   ```
#'
#'   ![](custom_welcome_ui.png "Custom welcome UI")
#'
#' @export
require_oauth <- function(app, oauth_app, scopes, welcome_ui = NULL,
  cookie_opts = cookie_options(http_only = TRUE)) {

  # This function takes the app object and transforms/decorates it to create a
  # new app object. The new app object will wrap the original ui/server with
  # authentication logic, so that the original ui/server is not invoked unless
  # and until the user has a valid Google token.
  #
  # It also modifies the gargle environment so that if gargle-derived packages
  # look for tokens from their internal .auth (AuthState), they are given the
  # token that Shiny knows about.

  # Force and normalize arguments
  force(app)
  force(oauth_app)
  scopes <- normalize_scopes(add_email_scope(scopes))
  force(welcome_ui)
  force(cookie_opts)

  # Override the HTTP handler, which is the "front door" through which a browser
  # comes to the Shiny app.
  httpHandler <- app$httpHandler
  app$httpHandler <- function(req) {
    # Each handle_* function will decide if it can handle the request, based on
    # the URL path, request method, presence/absence/validity of cookies, etc.
    # The return value will be NULL if the `handle` function couldn't handle the
    # request, and either HTML tag objects or a shiny::httpResponse if it
    # decided to handle it.
    resp <-
      # The /logout path revokes the token and deletes cookies
      handle_logout(req, oauth_app, cookie_opts) %||%
      # Handles callback redirect from Google (after user logs in successfully)
      # and sets gargle cookies
      handle_oauth_callback(req, oauth_app, cookie_opts) %||%
      # Handles requests that have good gargle cookies; shows the actual app
      handle_logged_in(req, oauth_app, httpHandler) %||%
      # If we get here, the user isn't logged in; show them welcome_ui if
      # non-NULL, or else send them straight to Google
      handle_welcome(req, welcome_ui, oauth_app, scopes, cookie_opts)
    resp
  }

  # Only invoke the provided server logic if the user is logged in; and make the
  # token automatically available within the server logic
  serverFuncSource <- app$serverFuncSource
  app$serverFuncSource <- function() {
    wrappedServer <- serverFuncSource()
    function(input, output, session) {
      token <- read_creds_from_cookies(session$request, oauth_app)
      if (is.null(token)) {
        stop("No valid OAuth token was found on the websocket connection")
      } else {
        session$userData$gargle_token <- token
        wrappedServer(input, output, session)
      }
    }
  }

  onStart <- app$onStart
  app$onStart <- function() {

    install_shiny_authstate_interceptor()
    suppress_token_fetch()

    # Call original onStart, if any
    if (is.function(onStart)) {
      onStart()
    }
  }

  app
}


infer_app_url <- function(req) {

  url <-
    # Connect
    req[["HTTP_X_RSC_REQUEST"]] %||%
    req[["HTTP_RSTUDIO_CONNECT_APP_BASE_URL"]] %||%
    # ShinyApps.io
    if (!is.null(req[["HTTP_X_REDX_FRONTEND_NAME"]])) { paste0("https://", req[["HTTP_X_REDX_FRONTEND_NAME"]]) }

  if (is.null(url)) {
    forwarded_host <- req[["HTTP_X_FORWARDED_HOST"]]
    forwarded_port <- req[["HTTP_X_FORWARDED_PORT"]]

    host <- if (!is.null(forwarded_host) && !is.null(forwarded_port)) {
      paste0(forwarded_host, ":", forwarded_port)
    } else {
      req[["HTTP_HOST"]] %||% paste0(req[["SERVER_NAME"]], ":", req[["SERVER_PORT"]])
    }

    proto <- req[["HTTP_X_FORWARDED_PROTO"]] %||% req[["rook.url_scheme"]]

    if (tolower(proto) == "http") {
      host <- sub(":80$", "", host)
    } else if (tolower(proto) == "https") {
      host <- sub(":443$", "", host)
    }

    url <- paste0(
      proto,
      "://",
      host,
      req[["SCRIPT_NAME"]],
      req[["PATH_INFO"]]
    )
  }

  # Strip existing querystring, if any
  url <- sub("\\?.*", "", url)

  url
}

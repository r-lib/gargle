handle_logout <- function(req, oauth_app, cookie_opts) {
  if (!isTRUE(req$PATH_INFO == "/logout")) {
    return(NULL)
  }

  token <- read_creds_from_cookies(req, oauth_app)
  if (!is.null(token)) {
    tryCatch(
      {
        token$revoke()
        ui_line("Token successfully revoked")
      },
      error = function(e) {
        message("Error while revoking token for logout: ", conditionMessage(e))
      }
    )
  } else {
    ui_line("Logout called but no (valid) credential cookie detected")
  }

  shiny::httpResponse(
    status = 307L,
    content_type = NULL,
    content = "",
    headers = rlang::list2(
      Location = "./",
      "Cache-Control" = "no-store",
      !!!delete_cookie_header("gargle_auth_state", cookie_opts),
      !!!delete_cookie_header("gargle_token", cookie_opts)
    )
  )
}

handle_oauth_callback <- function(req, oauth_app, cookie_opts) {
  qs <- shiny::parseQueryString(req[["QUERY_STRING"]])
  has_code_param <- "code" %in% names(qs)

  if (has_code_param) {
    # User just completed login; verify, set cookie, and redirect
    cookies <- parse_cookies(req)
    gargle_auth_state <- cookies[["gargle_auth_state"]]
    if (is.null(gargle_auth_state)) {
      return(NULL)
    }

    code <- qs[["code"]]
    state <- qs[["state"]]

    if (!identical(state, gargle_auth_state)) {
      ui_line("state parameter mismatch")
      return(NULL)
    }

    # TODO: Would be nice if this could be async
    cred <- httr::oauth2.0_access_token(
      gargle_outh_endpoint(),
      app = oauth_app,
      code = code,
      redirect_uri = infer_app_url(req)
    )

    return(shiny::httpResponse(
      status = 307L,
      content_type = NULL,
      content = "",
      headers = rlang::list2(
        Location = infer_app_url(req),
        "Cache-Control" = "no-store",
        !!!delete_cookie_header("gargle_auth_state", cookie_opts),
        !!!set_cookie_header("gargle_token", wrap_creds(cred, oauth_app),
          cookie_opts)
      )
    ))
  }
}

handle_logged_in <- function(req, oauth_app, httpHandler) {
  token <- read_creds_from_cookies(req, oauth_app)
  if (!is.null(token)) {
    # TODO: If token is expired, refresh and rewrite the cookie

    # User is already logged in, proceed
    with_shiny_token(token, {
      httpHandler(req)
    })
  }
}

handle_welcome <- function(req, welcome_ui, oauth_app, scopes, cookie_opts) {
  # TODO: Really wish this could use uiPattern
  if (!isTRUE(req$PATH_INFO == "/") && !isTRUE(grepl("^/[^/]+\\.Rmd$", req$PATH_INFO, ignore.case = TRUE))) {
    return(NULL)
  }

  redirect_uri <- infer_app_url(req)
  state <- sodium::bin2hex(sodium::random(32))
  query_extra <- list(
    access_type = "offline"
  )

  auth_url <- httr::oauth2.0_authorize_url(
    endpoint = gargle_outh_endpoint(),
    oauth_app,
    scope = paste(scopes, collapse = " "),
    redirect_uri = redirect_uri,
    state = state,
    query_extra = query_extra)

  if (is.null(welcome_ui)) {
    shiny::httpResponse(
      status = 307L,
      content_type = NULL,
      content = "",
      headers = rlang::list2(
        Location = auth_url,
        "Cache-Control" = "no-store",
        !!!set_cookie_header("gargle_auth_state", state, cookie_opts)
      )
    )
  } else {
    ui <- welcome_ui(req = req, login_url = auth_url)
    if (inherits(ui, "httpResponse")) {
      ui
    } else {
      lang <- attr(ui, "lang", exact = TRUE) %||% "en"
      if (!(inherits(ui, "shiny.tag") && ui$name == "body")) {
        ui <- tags$body(ui)
      }
      doc <- htmltools::htmlTemplate(
        system.file("shiny", "default.html", package = "gargle"),
        lang = lang,
        body = ui,
        document_ = TRUE
      )
      html <- htmltools::renderDocument(doc, processDep = shiny::createWebDependency)
      shiny::httpResponse(
        status = 403L,
        content = html,
        headers = rlang::list2(
          "Cache-Control" = "no-store",
          !!!set_cookie_header("gargle_auth_state", state, cookie_opts)
        )
      )
    }
  }
}

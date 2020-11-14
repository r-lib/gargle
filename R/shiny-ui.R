#' Helper function for creating a basic welcome screen
#'
#' Call this function with a bit of content (say, the title of your app and a
#' couple of sentences describing why login is required) and a `welcome_ui`
#' function will be returned, suitable for passing to [require_oauth()]. (See
#' the Details section of [require_oauth()] to see an example of
#' `basic_welcome_ui`.)
#'
#' @param ... _Unnamed_ arguments should be Shiny UI objects (i.e. HTML tags), and
#'   will become the page's main contents; they will immediately be followed by
#'   a Google signin button.
#'
#'   _Named_ arguments become attributes on the innermost
#'   `<div>` element that wraps both the given content, and the sign-in button.
#'
#' @export
basic_welcome_ui <- function(...) {
  function(req, login_url) {
    htmltools::tagList(
      jquerylib::jquery_core(),
      shiny::fluidPage(
        shiny::fluidRow(
          shiny::column(6, offset = 3, class = "text-center",
            ...,
            htmltools::p(google_signin_button(login_url))
          )
        )
      )
    )
  }
}

#' @export
google_signin_button <- function(login_url, ..., theme = c("light", "dark"),
  aria_label = "Sign in with Google") {

  stopifnot(is.character(login_url) && length(login_url) == 1)
  theme <- match.arg(theme)

  dep <- htmltools::htmlDependency(
    "google-sign-in-button-styles",
    "1.0",
    src = "branding",
    package = "gargle",
    all_files = TRUE,
    stylesheet = "signin.css"
  )
  htmltools::tagList(
    dep,
    htmltools::tags$a(href = login_url, class = paste0("google-signin-button-", theme),
      "aria-label" = aria_label,
      ...
    )
  )
}

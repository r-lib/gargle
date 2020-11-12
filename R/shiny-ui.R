#' @export
basic_welcome_ui <- function(...) {
  function(req, login_url) {
    tagList(
      jquerylib::jquery_core(),
      shiny::fluidPage(
        shiny::fluidRow(
          shiny::column(6, offset = 3, class = "text-center",
            ...,
            p(google_signin_button(login_url))
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
    tags$a(href = login_url, class = paste0("google-signin-button-", theme),
      "aria-label" = aria_label,
      ...
    )
  )
}

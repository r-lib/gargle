library(shiny)
library(googledrive)
library(gargle)
library(magrittr)

oauth_scopes = c(
  "https://www.googleapis.com/auth/spreadsheets",
  "https://www.googleapis.com/auth/drive.readonly"
)

oauth_app <- gargle_app()

# What people will see before they log in
welcome <- basic_welcome_ui(
  h2("Welcome!"),
  p("To use this app, please sign in with a Google account.")
)

# UI to be displayed after login. You can call Google APIs from here.
ui <- function(req) {
  fluidPage(
    gargle::token_email(googledrive::drive_token()),
    verbatimTextOutput("foo")
  )
}

# Server logic to be loaded after login. You can call Google APIs from here.
server <- function(input, output, session) {
  output$foo <- renderText({
    listing <- googledrive::drive_find(n_max = 100)
    paste(collapse = "\n", capture.output(print(listing)))
  })
}

# shinyApp object is piped to require_oauth
shinyApp(ui, server) %>% require_oauth(oauth_app, oauth_scopes, welcome_ui = welcome)

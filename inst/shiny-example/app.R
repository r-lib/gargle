library(shiny)
library(googledrive)
library(gargle)
library(magrittr)

oauth_scopes = c(
  "https://www.googleapis.com/auth/spreadsheets",
  "https://www.googleapis.com/auth/drive.readonly"
)

oauth_app <- gargle_app()

ui <- function(req) {
  fluidPage(
    gargle::token_email(googledrive::drive_token()),
    verbatimTextOutput("foo")
  )
}

server <- function(input, output, session) {
  output$foo <- renderText({
    listing <- googledrive::drive_find(n_max = 100)
    paste(collapse = "\n", capture.output(print(listing)))
  })
}

shinyApp(ui, server) %>% require_oauth(oauth_app, oauth_scopes, NULL)

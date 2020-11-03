library(shiny)
library(gargle)
library(magrittr)

oauth_scopes = c(
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/userinfo.profile",
  "https://www.googleapis.com/auth/spreadsheets",
  "https://www.googleapis.com/auth/drive.readonly"
)

oauth_app <- gargle_app()

ui <- fluidPage(
  textOutput("foo")
)

server <- function(input, output, session) {
  output$foo <- renderText({ "hello, world" })
}

shinyApp(ui, server) %>% require_oauth(oauth_app, oauth_scopes, NULL)

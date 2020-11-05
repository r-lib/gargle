library(shiny)
library(googledrive)
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
  verbatimTextOutput("foo")
)

server <- function(input, output, session) {
  output$foo <- renderText({
    # This is just temporary, we need to make this automatic. Written this way,
    # it's too easy to get wrong, and also won't work properly with promises
    drive_auth(token = session$userData$gargle_token)
    on.exit(drive_deauth())

    listing <- googledrive::drive_find(n_max = 100)
    paste(collapse = "\n", capture.output(print(listing)))
  })
}

shinyApp(ui, server) %>% require_oauth(oauth_app, oauth_scopes, NULL)

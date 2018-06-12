

navbarPage(
  "Toll Based Route Choice",
  id = "nav",
  
  tabPanel(
    "Map",
    div(
      class = "outer",
      
      tags$head(# Include our custom CSS
        includeCSS("styles.css")),
      
      leafletOutput("rampmap", width = "100%", height = "100%")
    ),
    absolutePanel(
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"),
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = FALSE,
      top = 60,
      left = "auto",
      right = 20,
      bottom = "auto",
      width = 330,
      height = "auto",
      h2("Enter Address"),
      #selectInput("variable", "Variable:",c("All",sgmdt$objectid))
      textInput("origin", "Origin:",placeholder = 'Enter Origin Address'),
      textInput("destination", "Destination:",placeholder = 'Enter Destination Address'),
      submitButton("GO"),
      hr(),
      tableOutput('results')
    )
  ),
  conditionalPanel("false", icon("crosshair"))
)
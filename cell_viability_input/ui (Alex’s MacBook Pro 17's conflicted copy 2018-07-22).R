library(shiny)
library(rhandsontable)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Cell Viability Input"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Levels of Viability"),
      p("Press the corresponding key for each level:"),
      verbatimTextOutput("levels"),
      h4("Legend"),
      verbatimTextOutput("legend"),
      hr(),
      h3("Key pressed"),
      verbatimTextOutput("keypressed"),
      tags$script('

if(($("#table").children(":focus").length == 0)) {
  console.log("YES")
  
$(document).on("keypress", function (e) {
  console.log($("#table").children(":focus").length)
  // Not focused on table
  if($("#table").children(":focus").length == 0) {
    Shiny.onInputChange("keypress", e.which);
  }
});



}
                  
                  ')
    ),
    mainPanel(
      rHandsontableOutput('table')
    )
  )
))

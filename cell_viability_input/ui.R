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
                  $("*").not("#table, #table *")
                    // set key value
                    .on("keypress", function (e) {
                      if(!$("#table, #table *").is(":focus")) {
                        Shiny.onInputChange("keypress", e.which);
                        console.log("keypressed")
                      } else {console.log("in table");}
                    })
                    // reset key value
                    .on("keyup", function (e) {
                      Shiny.onInputChange("keypress", null);
                      console.log("keyup")
                    });
                  ')
    ),
    mainPanel(
      rHandsontableOutput('table')
    )
  )
))

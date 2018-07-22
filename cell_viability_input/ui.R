library(shiny)
library(shinyWidgets)
library(rhandsontable)

shinyUI(fluidPage(
  
  # styles and scripts
  tags$head(tags$style('
  
#rangeInput input {
  padding: 3px 5px;
}
#rangeInput * {
  display: inline;
}
#rangeInput #alpha {
  width: 1.6em
}
#rangeInput #num {
  width: 3em
}
                       ')),
  tags$script('

function gotoBottom(id){
   var element = document.getElementsByClassName(id);
   element.scrollTop = element.scrollHeight - element.clientHeight;
}

$("*").not("#table, #table *")
  // set key value
  .on("keypress", function (e) {
    if(!$("#table, #table *").is(":focus")) {
      Shiny.onInputChange("keypress", e.which);
      console.log("keypressed")
      gotoBottom("table")
    } else {console.log("in table");}
  })
  // reset key value
  .on("keyup", function (e) {
    Shiny.onInputChange("keypress", null);
    console.log("keyup")
  });
              '),
  
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
      verbatimTextOutput("keypressed")
    ),
    mainPanel(
      fluidRow(
        column(12, wellPanel(
          h3("Experimental Parameters"),
          div(id="rangeInput", 
              p("I'm looking at a plate with dimensions A to ", 
                textInput("alpha", label = NULL, value = "H"),
                " by 1 to ",
                numericInput("num", label = NULL, value = 12)))
        )),
        
        column(12, rHandsontableOutput('table'))
      )
    )
  )
))

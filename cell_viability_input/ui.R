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

$("*")
  // set key value
  .on("keypress", function (e) {
    if(!$("#table, #table *, input, input *").is(":focus")) {
      Shiny.onInputChange("keypress", e.which);
      console.log("keypressed")
    } else {console.log("in table");}
  })
  // reset key value
  .on("keyup", function (e) {
    Shiny.onInputChange("keypress", null);
    console.log("keyup")
  });
              '),
  
  # Application title
  titlePanel("EZ Cell Viability Input"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Instructions"),
      p("Press the corresponding key for each level of cell viability."),
      h4("Levels of Viability"),
      verbatimTextOutput("levels"),
      h4("Legend"),
      verbatimTextOutput("legend"),
      hr(),
      h3("Key pressed"),
      verbatimTextOutput("keypressed")
    ),
    mainPanel(
      fluidRow(
        column(12, align = "center", 
               wellPanel(
          h3("Experimental Parameters"),
          column(12,
                 column(6,
                        dateInput("timestamp", label = "Timestamp", value = Sys.Date()),
                        textInput("pert_map", label = "Perturbation Map", value = "DBI31"),
                        textInput("alpha", label = "Last Row", value = "H")
                 ),
                 column(6,
                        textInput("day", label = "Day", value = "D12"),
                        textInput("replicate", label = "Replicate", value = "R1"),
                        numericInput("num", label = "Last Column", value = 12)
                 )
          ),
          # div(id="rangeInput", 
          #     p("I'm looking at a plate with dimensions A to ", 
          #       textInput("alpha", label = NULL, value = "H"),
          #       " by 1 to ",
          #       numericInput("num", label = NULL, value = 12))),
          br(),
          verbatimTextOutput("filename"),
          downloadButton('downloadCSV', 'Export table to .tsv')
        )),
        
        column(12, rHandsontableOutput('table'))
      )
    )
  )
))

library(shiny)
library(rhandsontable)
library(data.table)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  alpha <- LETTERS[1:8]
  numer <- sprintf("%02d", c(1:12))
  
  permute_alpha_numer <- expand.grid(numer, alpha)
  cvs <- c("NC", "NC-VL", "VL", "VL-L", "L", "L-M", "M", "M-G", "G", "G-VG", "VG")
  cvs_key <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "-")
  cvs_list <- as.list(setNames(cvs, cvs_key))
  
  
  values <- reactiveValues(
    data = data.table(Row=numeric(0), 
                      Column=numeric(0), 
                      Cell_Viability=numeric(0)),
    key = NULL,
    row_i = 1,
    shouldadd = T
  )
  
  # input by keystrokes
  
  observeEvent(input$keypress, {
    values$key <- input$keypress - 48
    
    if(!is.null(values$data)) {
      if (values$key >= 1 && values$key <= 9) {
        cv_temp <- cvs_list[[values$key]]
      } else if (values$key == 0) {
        cv_temp <- "G-VG"
      } else if (values$key == -3) {
        cv_temp <- "VG"
      } else {
        cv_temp <- NULL
      }
      
      # put into table
      if(!is.null(cv_temp)) {
        
        insert_this <- list(toString(permute_alpha_numer[values$row_i, 2]), 
                         toString(permute_alpha_numer[values$row_i, 1]),
                         cv_temp)
        
        values$data <- rbind(values$data, insert_this)
        
        values$row_i <- values$row_i + 1
      }
    }
  })
  
  # input by editing table
  observe({
    if(!is.null(input$table))
      values$data <- hot_to_r(input$table)
  })
  
  output$table <- renderRHandsontable({
    if(is.null(values$data)) {
      return(NULL)
    }
    rhandsontable(values$data)
  })
   
  output$keypressed <- renderText({

    if(is.null(values$key)) {
      return(NULL)
    }

    t <- "Key pressed: "
    if (values$key >= 1 && values$key <= 9) {
      t <- paste0(t, values$key,"\n")
      t <- paste0(t, "Corresponding cell viability: ", cvs_list[[values$key]])
    } else if (values$key == 0) {
      t <- paste0(t, values$key,"\n")
      t <- paste0(t, "Corresponding cell viability: G-VG")
    } else if (values$key == -3) {
      t <- paste0(t, "-\n")
      t <- paste0(t, "Corresponding cell viability: VG")
    } else {
      return("Invalid key was pressed")
    }
    return(t)
    
  })
  
  output$legend <- renderText({
    t <- paste0(
      "NC\tNo Count\n",
      "VL\tVery Low\n",
      "L\tLow\n",
      "M\tMedium\n",
      "G\tGood\n",
      "VG\tVery Good"
    )
    
    t
  })
  
  output$levels <- renderText({
    t <- paste0(
      "1\tNC\n",
      "2\tNC-VL\n",
      "3\tVL\n",
      "4\tVL-L\n",
      "5\tL\n",
      "6\tL-M\n",
      "7\tM\n",
      "8\tM-G\n",
      "9\tG\n",
      "0\tG-VG\n",
      "-\tVG\n"
    )

    t
  })
  
})

library(shiny)
library(rhandsontable)
library(data.table)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  alpha <- LETTERS[1:8]
  numer <- c(1:12)
  
  permute_alpha_numer <- expand.grid(numer, alpha)
  cvs <- c("NC", "NC-VL", "VL", "VL-L", "L", "L-M", "M", "M-G", "G", "G-VG", "VG")
  cvs_key <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "-")
  cvs_list <- as.list(setNames(cvs, cvs_key))
  
  
  values <- reactiveValues(
    data = data.table(Row=character(0), 
                      Column=numeric(0), 
                      Cell_Viability=character(0)),
    key = NULL,
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
        pointer <- nrow(values$data) + 1
        
        insert_this <- list(toString(permute_alpha_numer[pointer, 2]), 
                            toString(permute_alpha_numer[pointer, 1]),
                            cv_temp)
        
        values$data <- rbind(values$data, insert_this)
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
    rhandsontable(values$data, height = 400, stretchH = "all") %>% 
      hot_context_menu(allowRowEdit = TRUE, allowColEdit = FALSE) %>%
      hot_validate_character(cols = "Row", choices = alpha) %>%
      hot_validate_numeric(cols = "Column", choices = numer)
#       hot_cols(renderer = "
# 
# function (instance, td, row, col, prop, value, cellProperties) {
#   Handsontable.renderers.TextRenderer.apply(this, arguments);
#     if (instance.getData()[row][3] == 'NC') {
#       td.style.background = rgb(255, 99, 71);
#     } else if (instance.getData()[row][3] == 'NC-VL') {
#       td.style.background = rgb(254, 138, 79);
#     } else if (instance.getData()[row][3] == 'VL') {
#       td.style.background = rgb(254, 174, 87);
#     } else if (instance.getData()[row][3] == 'VL-L') {
#       td.style.background = rgb(253, 207, 95);
#     } else if (instance.getData()[row][3] == 'L') {
#       td.style.background = rgb(253, 237, 103);
#     } else if (instance.getData()[row][3] == 'L-M') {
#       td.style.background = rgb(242, 253, 111);
#     } else if (instance.getData()[row][3] == 'M') {
#       td.style.background = rgb(217, 252, 119);
#     } else if (instance.getData()[row][3] == 'M-G') {
#       td.style.background = rgb(196, 252, 127);
#     } else if (instance.getData()[row][3] == 'G') {
#       td.style.background = rgb(178, 251, 136);
#     } else if (instance.getData()[row][3] == 'G-VG') {
#       td.style.background = rgb(163, 251, 144);
#     } else if (instance.getData()[row][3] == 'VG') {
#       td.style.background = rgb(152, 250, 152);
#     }
#   }
#                ")
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
  
  output$downloadCSV <- downloadHandler(

    filename = function() {
		  f <- paste(input$timestamp, input$pert_map, input$day, input$replicate, "cellqual", sep = "_")
	    f <- paste(f, "tsv", sep=".")  
	    f
		},

    content = function(file) {

      write.table(values$data, file, sep = "\t", quote = F,
        row.names = FALSE)
    }
  )
  
})

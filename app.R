library(shiny)
library(magrittr)

ui <- fluidPage(
  titlePanel("POSSIBLE FINANCE APPLICATION VERIFICATION"),
  textInput("input1", "Enter the dropbox URL:"),
  actionButton("btn", "Submit"),
  textOutput("outputText"),
  textOutput("outputText1"),
  uiOutput("downloadUI")
)

server <- function(input, output, session) {
  storedText <- reactiveVal(NULL)
  fileReady <- reactiveVal(FALSE)
  
  observeEvent(input$btn, {
    storedText(input$input1)
    source("Milestone7.R", local = TRUE, chdir = TRUE)
    fileReady(TRUE)
  })
  
  output$outputText <- renderText({
    paste("URL:", storedText(),"\n\n\n")
  })
  
  output$outputText1 = renderText({
    if (fileReady()) {
      paste0("Your file is ready for download")
    }
  })
  
  output$downloadUI <- renderUI({
    if (fileReady()) {
      downloadButton("downloadCSV", "Download CSV")
    } else {
      div() 
    }
  })
  
  output$downloadCSV <- downloadHandler(
    filename = function() {
      req(storedText())  
      testFileURL <- storedText()
      outputFileName = sub(".*/", "", testFileURL)  
      outputFileName = sub("\\?.*", "", outputFileName)  
      outputFileName = sub("\\..*", "", outputFileName)
      outputFileName = paste0(outputFileName, ".csv")
      
      outputFileName
    },
    content = function(file) {
      req(storedText())  
      testFileURL <- storedText()
      outputFileName = sub(".*/", "", testFileURL)  
      outputFileName = sub("\\?.*", "", outputFileName) 
      outputFileName = sub("\\..*", "", outputFileName)
      outputFileName = paste0(outputFileName, ".csv")
      
      file.copy(file.path(outputFileName), file)
    }
  )
}

shinyApp(ui, server)

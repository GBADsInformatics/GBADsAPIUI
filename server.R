
# Server ------------------------------------------------------------------
server <- function(input, output, session) {

# Help Text ---------------------------------------------------------------
  observeEvent(input$help, {
    showModal(modalDialog(
      title = "How to use the GBADs Data Portal",
      HTML("We developed this portal as an alternative method to of accessing the GBADs knowledge engine. All of the data available in this portal can also be accessed via our API. This tool allows for users unfamiliar with API programming to specify the data they require and download it as a .csv file, which can then be opened in various spreadsheet and data management software. To get started downloading global animal health data, simply follow these steps:",
           "<br><p><b>1.</b> Select the dataset you wish to access from the drop-down menu on the left-hand side of your screen.",
           "<br><p><b>2.</b> Toggle on or off the various column headers existing in the dataset you selected. By default all values are selected.",
           "<br><p><b>3.</b> Click 'Submit'",
           "<br><p><b>4.</b> You can filter the data by any of the columns in the dataset by clicking on the dropdown menus above the table. Filter by one or many columns.",
           "<br><p><b>5.</b> A preview of your data will be displayed below the filters. Once you are happy with the data preview, click 'Download' to download the data to your computer."),
      easyClose = T
    )
    )
  })

# Gather Data Tables Names ------------------------------------------------
  table <- reactive({
    url <- paste('http://gbadske.org/api/GBADsTable/public?table_name=',input$table,'&format=text', sep="")
    res <- GET(url = url)
    test <- content(res)
    test <- unlist(strsplit(test,",")
    )
  })

# Create Radio Buttons for Fields -----------------------------------------
  output$colsel <- renderUI({
    awesomeCheckboxGroup(
      inputId = "colsel",
      label = "Values included:", 
      choices = c(table()),
      selected = c(table()),
      status = "warning"
    )
  })
  
# Clear UI on Submit ------------------------------------------------------
# 
#   observeEvent(input$submitbtn, {
#     update (session, 'select1', selected = character(0))
#     rv('')
#   })
  


# Fetch Data from API -----------------------------------------------------
  selected_dataset <-  eventReactive(input$submitbtn, {
    fields <- gsub(" ", "", toString(input$colsel))
    url_data <- paste('http://gbadske.org/api/GBADsPublicQuery/',input$table,'?fields=',fields,'&query=&format=text', sep = "")
    res <- GET(url = url_data)
    data <- content(res)
  })
  
# Data Filtering Options --------------------------------------------------
  vars_r <- reactive({
    input$vars
  })
  
  output$panelProxy <- renderUI({
    available_vars <- names(selected_dataset())
    conditionalPanel(
      condition = "input.closebutton",
      panel(
        awesomeCheckboxGroup(
          inputId = "vars",
          label = "Variables to Filter:", 
          choices = available_vars,
          selected = head(available_vars,3),
          inline = TRUE,
          status = "warning"
        ),
        selectizeGroupUI(
          id = "my-filters",
          params = filterParams(available_vars)
        ),
        status = "primary",
        tags$style(".panel {background-color:#FFFFFF; border-color: white;  box-shadow: 3px 3px 3px 3px #F3F3F3;}")
      )
    )
  })
 
  res_mod <- callModule(
    module = selectizeGroupServer,
    id = "my-filters",
    data = selected_dataset,
    vars = vars_r
  )

# Data Table Preview ------------------------------------------------------
  output$table <- DT::renderDataTable({
    req(res_mod())
    datatable(res_mod(), rownames = FALSE, options = list(scrollX = TRUE))
  })
  
  output$datatablewell <- renderUI({
    req(res_mod())
    panel(dataTableOutput("table"), tags$style(".panel {background-color:white;border-color: white; box-shadow: 3px 3px 3px 3px #F3F3F3;}"))
  })
  
# Download Options --------------------------------------------------------
  output$download <- renderUI({
    req(res_mod())
    fields <- gsub(" ", "", toString(input$colsel))
    url <- paste('http://gbadske.org/api/GBADsPublicQuery/',input$table,'?fields=',fields,'&query=&format=text', sep = "")
    list(
      CopyButton(
        "copybtn",
        label = "Copy URL to clipboard",
        icon = icon("copy"),
        text = url
      ),
      downloadButton("downloadData", label = "Download .csv", class = NULL, style = "box-shadow: 3px 3px 3px 3px #F3F3F3; display: inline-block:", icon = icon("download")))
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$table, Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(res_mod(), con)
    }
  )
}
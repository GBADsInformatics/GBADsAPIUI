#Libraries-----------------------------------------------------
library(shiny)
library(httr)
library(stringr)
library(DT)
library(tidyverse)
library(fresh)
library(shinyWidgets)
library(tools)

#--------------------------------------------------------------
url <- "http://gbadske.org:9000/GBADsTables/public?format=text"
res <- GET(url = url)
tables <- content(res)
sets <- as.data.frame(strsplit(tables, ","))
names(sets) <- "Data Available"

filterParams <- function(vars){
  setNames(lapply(vars, function(x){
    list(inputId = x, title = paste0(tools::toTitleCase(x), ":"), placeholder = "...")
  }), vars)
}
#User Interface------------------------------------------------
ui <- fluidPage(
  use_googlefont("Raleway"),
  use_theme(create_theme(bs_vars_font(family_sans_serif = "'Raleway'"))),
  setBackgroundColor(
    color = c("#FFFFFF", "#F3F3F3"),
    gradient = "linear",
    direction = "bottom"
  ),
  
  # Application title
  headerPanel(img(src ="GBADsLogo.png", height = "40px"), windowTitle = "GBADs Data Portal"),
  h2("Data Portal", style = "padding-left: 16px; color: #333333"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("table","Select Dataset:",sets),
      uiOutput("colsel"),
      actionBttn("submitbtn","Submit", color = "warning", size = "s"),
      actionBttn(inputId = "help",label = "Help" , color = "primary",size = "s"),
      tags$style(".well {background-color:white;border-color: white; box-shadow: 3px 3px 3px 3px #F3F3F3;}")
    ),
    mainPanel(
      uiOutput("panelProxy"),
      panel(dataTableOutput("table"), tags$style(".panel {background-color:white;border-color: white; box-shadow: 3px 3px 3px 3px #F3F3F3;}")),
      downloadButton("downloadData", label = "Download", class = NULL, style = "box-shadow: 3px 3px 3px 3px #F3F3F3;")
    )
  ),
  hr(),
  uiOutput("url")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  observeEvent(input$help, {
    showModal(modalDialog(
      title = "How to use the GBADs Data Portal",
      HTML("We developed this portal as an alternative method to of accessing the GBADs knowledge engine. All of the data available in this portal can also be accessed via our API. This tool allows for users unfamiliar with API programming to specifiy the data they require and download it as a .csv file, which can then be opened in various spreadsheet and data management software. To get started downloading global animal health data, simply follow these steps:",
           "<br><p><b>1.</b> Select the dataset you wish to access from the drop down menu on the left-hand side of your screen.",
           "<br><p><b>2.</b> Toggle on or off the various column headers existing in the dataset you selected. By default all values are selected.",
           "<br><p><b>3.</b> Click 'Submit'",
           "<br><p><b>4.</b> You can filter the data by any of the columns in the dataset by clicking on the dropdown menus above the table. Filter by one or many columns.",
           "<br><p><b>5.</b> A preview of your data will be displayed below the filters. Once you are happy with the data preview, click 'Download' to download the data to your computer."),
      easyClose = T
    ))
  })
  
  table <- reactive({
    url <- paste('http://gbadske.org:9000/GBADsTable/public?table_name=',input$table,'&format=text', sep="")
    res <- GET(url = url)
    test <- content(res)
    test <- unlist(strsplit(test,","))
  })
  
  output$colsel <- renderUI({
    awesomeCheckboxGroup(
      inputId = "colsel",
      label = "Values to include:", 
      choices = c(table()),
      selected = c(table()),
      status = "warning"
    )
  })
  
  selected_dataset <-  eventReactive(input$submitbtn, {
    fields <- gsub(" ", "", toString(input$colsel))
    url_data <- paste('http://gbadske.org:9000/GBADsPublicQuery/',input$table,'?fields=',fields,'&query=&format=text', sep = "")
    res <- GET(url = url_data)
    data <- content(res)
  })
  
  output$url <- renderUI({
    fields <- gsub(" ", "", toString(input$colsel))
    str1 <- h6("URL:", style = "color: #333333")
    str2 <- a(paste('http://gbadske.org:9000/GBADsPublicQuery/',input$table,'?fields=',fields,'&query=&format=text', sep = ""), href = paste('http://gbadske.org:9000/GBADsPublicQuery/',input$table,'?fields=',fields,'&query=&format=text', sep = ""))
    HTML(paste(str1, str2))
  })
  
  vars_r <- reactive({
    input$vars
  })
  
  res_mod <- callModule(
    module = selectizeGroupServer,
    id = "my-filters",
    data = selected_dataset,
    vars = vars_r
  )
  
  output$table <- DT::renderDataTable({
    req(res_mod())
    res_mod()
  })
  
  output$panelProxy <- renderUI({
    available_vars <- names(selected_dataset())
    panel(
      awesomeCheckboxGroup(
        inputId = "vars",
        label = "Variables to Filter:", 
        choices = available_vars,
        selected = available_vars,
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

# Run the application 
shinyApp(ui = ui, server = server)
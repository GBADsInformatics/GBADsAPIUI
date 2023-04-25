
# UI ----------------------------------------------------------------------
ui <- fluidPage(

  use_copy(),
# Theming -----------------------------------------------------------------
  use_googlefont("Raleway"),
  use_theme(create_theme(bs_vars_font(family_sans_serif = "'Raleway'"))),
  setBackgroundColor(
    color = c("#F7F7F7", "#F7F7F7"),
    gradient = "linear",
    direction = "bottom"
  ),
  windowTitle = "GBADs Data Portal",

# Header ------------------------------------------------------------------
  fluidRow(style = "background-color: #fff",
           column(12,
                  img(src ="GBADsLogo.png", height = "70px", style = "padding-left: 12px; padding-top:15px; padding-bottom: 0px")),
           column(12,
                  h2("Data Portal", style = "padding-left: 16px; margin-top:0px; color: #333333;")),
  ),
  fluidRow(column(12,style='padding-bottom:1px; background-color:#F0F0F0;box-shadow: 3px 3px 3px 3px #F3F3F3;')),
  br(),

# Sidebar -----------------------------------------------------------------
  sidebarPanel(
    selectizeInput("table","Select Dataset:",sets),
    uiOutput("colsel"),
    actionBttn("submitbtn","Preview Data", color = "warning", size = "s"),
    actionBttn(inputId = "help",label = "Help" , color = "primary",size = "s"),
    br(),br(),
    materialSwitch(
      inputId = "closebutton",
      label = "Show Data Filters", 
      value = TRUE,
      status = "warning"
    ),
    tags$style(".well {background-color:white;border-color: white; box-shadow: 3px 3px 3px 3px #F3F3F3;}")
  ),


# Main Panel --------------------------------------------------------------
  mainPanel(
    withSpinner(
      uiOutput("panelProxy"),
      type = getOption("spinner.type", default = 6),
      color = getOption("spinner.color", default = "#F7931D"),
      size = getOption("spinner.size", 0.8)),
    uiOutput("datatablewell"),
    uiOutput("download")),
  hr(),
  br(),br()
)
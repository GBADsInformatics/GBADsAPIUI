
# Load Packages -----------------------------------------------------------
library(shiny)
library(httr)
library(stringr)
library(DT)
library(tidyverse)
library(fresh)
library(shinyWidgets)
library(tools)
library(shinycssloaders)
library(shinyjs)
library(shinyCopy2clipboard)

# Misc. Preparation -------------------------------------------------------
url <- "http://gbadske.org/api/GBADsTables/public?format=text"
res <- GET(url = url)
tables <- content(res)
sets <- as.data.frame(strsplit(tables, ","))
names(sets) <- "Data Available"

filterParams <- function(vars){
  setNames(lapply(vars, function(x){
    list(inputId = x, title = paste0(tools::toTitleCase(x), ":"), placeholder = "...")
  }), vars)
}
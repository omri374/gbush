library(shiny)
library(DT)
library(ggplot2)
library(shinythemes)
library(shinydashboard)
library(dplyr)

options(shiny.reactlog = TRUE)
Sys.setlocale(category = "LC_ALL", locale = "Hebrew_Israel.1255")

source("R/utils.R", encoding = 'WINDOWS-1255')
source("R/statistical_tests.R", encoding = 'WINDOWS-1255')

TRAITS <- c("PhysicalSkills","TeamSkills","PressureSkills","MotivationSkills","CognitiveSkills","CommanderSkills","UnitSuitability")


header <- dashboardHeader(title = 'Nahal Gibush Assessment - per estimator')

sidebar <- dashboardSidebar(
  
  sidebarMenu(
    uiOutput("megabesh"),
    checkboxInput("exclude_medical", "Exclude medical", value = TRUE),
    radioButtons("liba_filter", label = "Filter Liba/Non liba?",choices = list("Liba","NonLiba","Both"),selected = "Both"),
    radioButtons("month_filter", label = "Filter specific months?",choices = list("Aug","Mar","Nov","All"),selected = "All"),
    sliderInput("threshold","Score threshold for hit/miss",1,7,0.2,value = 4)
    
  )
)


body <- dashboardBody(
  tabsetPanel(
    tabPanel("General",
             textOutput("header"),
             h3("Gibushim"),
             verbatimTextOutput("numOfGibushim"),
             h3("Mitgabshim"),
             verbatimTextOutput("generalStats")
             
    ),
    tabPanel("HitMiss",
             tableOutput("hitMiss"),
             plotOutput("hitMissPlot")
             ),
    tabPanel("Traits",
             selectInput("trait",label = "Trait",choices = TRAITS,selected = "UnitSuitability"),
             checkboxInput("sliceByFinished","Slice by finishers/non finishers",value = FALSE),
             
             tabsetPanel(
                tabPanel("Traits distribution",
                h3("Traits distribution"),
                plotOutput("traitPlot")),
                tabPanel("Correlations",
             plotOutput("correlationToUnitSuitability")),
             tabPanel("Traits distribution vs. others",
             plotOutput("traitPlotComparison"))
             )
    ),
    
    tabPanel("Gibushim",DT::dataTableOutput("gibushim")),
    
    tabPanel("Raw",
             
             DT::dataTableOutput("raw_data")
    )
  )
)

dashboardPage(header, sidebar, body)

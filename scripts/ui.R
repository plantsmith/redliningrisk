library(shiny)
library(tidyverse)
library(palmerpenguins)

ui <- navbarPage(
  title="Sample App",
  tabPanel(
    title = "Intro",
    includeText('intro_text.txt'),
    includeMarkdown('intro_text.md')
  ),

  tabPanel(
    title="Tab 1",
           sidebarLayout(
             sidebarPanel(

               h3('Sidebar text'),

               radioButtons(
                 inputID = "species",
                 label = "which p species?",
                 choices = c("A","C","G"),
                 selected = "A"),

               checkboxGroupInput(
                 inputID = "island",
                 label = "which islands?",
                 choices = c("biscoe","dream","torg"),
                 selected = "Biscoe")

             ), ### end sidebar panel
             mainPanel(

               h2("Main Panel"),

               plotOutput(outputID = "peng_plot")

        ) ### end MainPanel
      ) #### end sidebar layout
    ) ### end tab panel
  ) #end





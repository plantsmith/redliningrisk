### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)


####### REDLINING DATA STUFF ####
redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
   janitor::clean_names() %>%
   filter(city == "Los Angeles") %>%
   drop_na()


  ### Create the user interface:
  ui <- fluidPage(
    theme=bs_theme(bootswatch = 'minty'),
    titlePanel("Risky biz"),
    sidebarLayout(
      sidebarPanel("put my widgets here",
                   checkboxGroupInput(
                     inputId = "grades",
                     label = "Choose Area Category",
                     choices = c("Best" = "A",
                               "Still Desirable" = "B",
                               "Definitely Declining" = "C" ,
                               "Hazardous" = "D"),
                     selected = 1)
                 ), ### end sidebarPanel

      mainPanel("put my graph here",

                plotOutput(outputId = "grade_plot"))

    ), ### end sidebarLayout

) ### end sidebar layout

### REACTIVE GRAPH ###

     server <- function(input, output) {
       bs_themer()
      grade_select <- reactive({
      redline_grade <- redlining_sf %>%
          filter(grade %in% input$grades)


        return(redline_grade)
      }) ### end penguin_select

      output$grade_plot <- renderPlot({
        ggplot() +
          geom_sf(data = grade_select(), aes(fill = grade)) +
          theme_void()
      }) ### end penguin_plot

    } ### end server

     ### Combine them into an app:
     shinyApp(ui = ui, server = server)

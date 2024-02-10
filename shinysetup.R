### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)


####### REDLINING DATA STUFF ####
# redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
#   janitor::clean_names() %>%
#   filter(city == "Los Angeles")

ggplot()+geom_sf(data=redlining_sf)

### Combine them into an app:
shinyApp(ui = ui, server = server)

  ### Create the user interface:
  ui <- fluidPage(
    titlePanel("Risky biz"),
    sidebarLayout(sidebarPanel("put my widgets here"),
                   checkboxGroupInput(inputId = "grade",
                   label = "Choose Area Category",
                   choices = c("Best" = "A",
                               "Still Desirable" = "B",
                               "Definitely Declining" = "C" ,
                               "Hazardous" = "D")
                 )

    ), ### end sidebarLayout

    mainPanel("put my graph here",

              plotOutput(outputId = "grade_plot"))

) ### end sidebar layout

### REACTIVE GRAPH ###

     server <- function(input, output) {
      grade_select <- reactive({
       redline_grade <- redlining_sf %>%
          filter(grade == input$grade)

        return(redline_grade)
      }) ### end penguin_select

      output$grade_plot <- renderPlot({
        ggplot(data = grade_select()) +
          geom_sf(data=redlining_sf)
      }) ### end penguin_plot

    } ### end server








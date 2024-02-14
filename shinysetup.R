### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)

###NAT'S ZONE - STAY OUT###
# Load in new datasets

# Tree Canopy Cover (2016):
canopy_coverage <- read_csv(here('data/tree_canopy_cover2016.csv')) %>%
  janitor::clean_names()

# City Tree - LA Parks n Rec:
city_trees <- read_sf(here('data',
                           'city_trees_rec_and_park',
                           'city_trees_rec_and_park.shp')) %>%
  janitor::clean_names()

# CA Enviroscreen Data Dictionary:
enviroscreen <- readxl::read_xlsx(here('data',
                                       'calenviroscreen_data_dictionary',
                                       'calenviroscreen_data_dictionary_2021.xlsx')) %>%
  janitor::clean_names()

# Heat.Gov Surface Models:

la_heat <-



####### REDLINING DATA STUFF ####
redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
   janitor::clean_names() %>%
   filter(city == "Los Angeles") %>%
   drop_na()


  ### Create the user interface:
  ui <- fluidPage(
    theme=bs_theme(bootswatch = 'yeti'),
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

       #bs_themer()

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

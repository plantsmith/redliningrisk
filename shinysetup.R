### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)
library(maps)

### basemap
la_county <- map_data("county", "california") %>% filter(subregion == "los angeles")



####### REDLINING DATA STUFF ####
redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
   janitor::clean_names() %>%
   filter(city == "Los Angeles") %>%
   drop_na()


  ### Create the user interface:
  ui <- fluidPage(

    theme=bs_theme(bootswatch = 'yeti'),

    titlePanel("Risky biz"),

    tabsetPanel(
      tabPanel(
        title = 'Home',
        p('This will be our first page, with info and pictures about the project')
        ), ### end tab 1

      tabPanel(
        title = 'Map',
        p('This is our first data tab, containing our map & summary stats table'),
        sidebarLayout(
          sidebarPanel("",
                       checkboxGroupInput(
                         inputId = "grades",
                         label = "Choose Area Category",
                         choices = c("Best" = "A",
                                     "Still Desirable" = "B",
                                     "Definitely Declining" = "C" ,
                                     "Hazardous" = "D"),
                         selected = 1)
          ), ### end sidebarPanel

          mainPanel("Output graph (will have basemap, redlining zones, green space/canopy cover, social indices). Below the graph will be our summary table, which will show mean values for green space/canopy cover and social indices as they're selected",

                    plotOutput(outputId = "grade_plot"))

        ), ### end sidebarLayout
        ), ### end tab 2

      tabPanel(
        title = 'Histograms',
        p('This is our second data tab, containing a histogram'),
        sidebarLayout(
          sidebarPanel("widget here: select one of our data variables"

          ),
          mainPanel("histogram here: show distribution of data values by census tract"

          )
        ) ### end sidebarLayout

        ), ### end tab 3

      tabPanel(
        title = 'Data & Resources',
        p('This tab will contain all our data citations, links to resources, and recommended readings for those interested in learning more')
        ) ### end tab 4

    ) ### end tabsetPanel

    #### sidebar layout


) ### end fluidPage

### REACTIVE GRAPH ###

     server <- function(input, output) {

       #bs_themer()

      grade_select <- reactive({
      redline_grade <- redlining_sf %>%
          filter(grade %in% input$grades)


        return(redline_grade)
      }) ### end grade_select

      output$grade_plot <- renderPlot({
        ggplot() +
          geom_polygon(data = la_county, aes(x = long, y = lat, group = group), color = "black", fill = "lightgray") +
          geom_sf(data = grade_select(), aes(fill = grade)) +
          theme_void()
      }) ### end grade_plot

    } ### end server

### Combine them into an app:
shinyApp(ui = ui, server = server)



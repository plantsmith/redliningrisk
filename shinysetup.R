### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)

### Create the user interface:
ui <- fluidPage()

### Create the server function:
server <- function(input, output) {}

### Combine them into an app:
shinyApp(ui = ui, server = server)


redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
  janitor::clean_names() %>%
  filter(city == "Los Angeles")

ggplot() +
  geom_sf(data=redlining_sf, aes(fill = grade))

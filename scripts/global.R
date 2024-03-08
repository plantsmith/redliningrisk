### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)
library(maps)
library(kableExtra)
library(knitr)

###load data, prep for the app, define functions...

## get our data
enviroscreen_final <- read_sf(here('data', 'enviroscreen_final.gpkg'))
enviroscreen_trimmed <- enviroscreen_final %>%
  select(canopy_pct = existing_canopy_pct, pct_poverty = poverty, heat_ER_visits = zip_pct_64)

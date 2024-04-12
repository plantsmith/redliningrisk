### Attach packages
library(shiny)
library(ggplot2)
library(tidyverse)
library(sf)
library(here)
library(bslib)
library(maps)
library(kableExtra)
library(knitr)
library(ggfortify)
library(RColorBrewer)



###load data, prep for the app, define functions...

## get our data
enviroscreen_final <- read_sf('enviroscreen_final.gpkg')
enviroscreen_trimmed <- enviroscreen_final %>%
  select(canopy_pct = existing_canopy_pct, pct_poverty = poverty, heat_ER_visits = zip_pct_64)


#####PCA######

#pick data variables
clean_screen <- enviroscreen_final %>%
  st_drop_geometry() %>%
  select(pm2_5,diesel_pm,lead,drinking_water = drink_wat,asthma,education = educatn, poverty, unemployment = unempl,
         linguistic_isolation = ling_isol,traffic, heat_illness = zip_pct_64, canopy_pct = existing_canopy_pct,approx_loc, class1) %>%
  drop_na() %>%
  mutate(class1 = as.factor(class1),
         log_diesel_pm = log(diesel_pm),
         log_canopy_pct = log(canopy_pct),
         .keep = "unused")

# pick locations based on number of observations
enviroscreen_final %>%
  group_by(approx_loc) %>%
  summarize(n = n()) %>%
  arrange(desc(n))


la_sky<- here("misc","la-skyline.jpg")


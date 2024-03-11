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


###load data, prep for the app, define functions...

## get our data
enviroscreen_final <- read_sf(here('data', 'enviroscreen_final.gpkg'))
enviroscreen_trimmed <- enviroscreen_final %>%
  select(canopy_pct = existing_canopy_pct, pct_poverty = poverty, heat_ER_visits = zip_pct_64)


#####PCA######

#pick data variables
clean_screen <- enviroscreen_final %>%
  st_drop_geometry() %>%
  select(pm2_5,diesel_pm,lead,drink_wat,asthma,educatn, poverty,unempl,ling_isol,traffic,zip_pct_64, existing_canopy_pct,approx_loc) %>%
  drop_na()

#scale
pca_screen<- clean_screen %>%
  select(where(is.numeric))%>%
  prcomp(scale = TRUE)

pca_screen$rotation

#create loadings
loadings_df <- data.frame(pca_screen$rotation * 8) %>% ### 8x arrows
  mutate(axis = row.names(.))

new_pts_df <- data.frame(pca_screen$x)


la_sky<- here("misc","la-skyline.jpg")


library(tidyverse)
library(here)
library(sf)
library(tidycensus)



### working on combining datasets

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

enviroscreen_filter <- enviroscreen %>%
  filter(california_county == "Los Angeles")
####
enviroscreen_sf <- read_sf(here("data",
                                "calenviroscreen_shp",
                                "CES4 Final Shapefile.shp")) %>%
  janitor::clean_names() %>%
  filter(county == "Los Angeles") %>%
  filter(tract != 6037599100) %>% # islands
  filter(tract != 6037599000) %>% # islands
  filter(tract != 6037980003) # unincorporated

enviroscreen_sf %>%
ggplot() +
  geom_sf(fill = "lightgray", color = "black") +
  theme_void()



#Census data:
la_census <- tidycensus::get_acs(
  state = "CA",
  county = "Los Angeles",
  geography = "tract",
  variables = "B25004_001", ## Vacancy Status
  geometry = TRUE,
  year = 2022
)

la_census <- tidycensus::get_acs(
  state = "CA",
  county = "Los Angeles",
  geography = "tract",
  variables = "B07011_001", ## Median income????
  geometry = TRUE,
  year = 2022
)


v22 <- load_variables(2022, "acs1", cache = TRUE)
v20 <- load_variables(2020, "dhc", cache = TRUE)


#filter the data:

la_census_filter <- la_census %>%
  mutate(NAME = gsub(", Los Angeles County, California", # elements that you want to remove
                     "", # replace with blank
                     NAME)) %>%
  mutate(NAME = gsub("Census Tract ", # elements that you want to remove
                     "", # replace with blank
                     NAME)) %>%
  filter(GEOID != "06037599100") %>% # islands
  filter(GEOID != "06037599000") %>% # islands
  filter(GEOID != "06037980003") %>%
  filter(GEOID != "06037980004") %>%
  filter(!(NAME >= 9000 & NAME <= 9800))



# Heat.Gov Surface Models:
heat_island_effects<- read_sf(here('data',
                                   'heat_island_effects_la',
                                   'heat_island_effects_la.shp')) %>%
  janitor::clean_names()

# REDLINING
redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
  janitor::clean_names() %>%
  filter(city == "Los Angeles") %>%
  drop_na()

# North LA Heat Index
la_heat_index <- read_sf(here("data", "surface models_north los angeles_california", "af_t_f_ranger.tif"))
## not working???


### PLOTS
# 1. make basemap
ggplot() +
  geom_sf(data=la_census_filter, fill = "lightgray", color = "black") +
  theme_void()

ggplot() +
  geom_sf(data=la_census_filter, aes(fill = estimate, color = estimate)) +
  theme_void()


# 2. investigate
enviroscreen_sf %>%
  filter(poverty_p > 0) %>%
  ggplot() +
  geom_sf(aes(fill = poverty_p))

enviroscreen_sf %>%
  filter(white > 0) %>%
  ggplot() +
  geom_sf(aes(fill = white, color = white))



### JOINS

# check coordinate systems
st_crs(enviroscreen_sf)
st_crs(redlining_sf)
st_crs(la_census_filter)

la_census_tracts <- la_census_filter %>%
  mutate(geoid = as.numeric(GEOID)) %>%
  select(geoid)

enviroscreen_la <- st_transform(enviroscreen_sf, st_crs(la_census_tracts))

st_crs(la_census_tracts) == st_crs(enviroscreen_la)

unique(canopy_coverage$geoid20)
test <- inner_join(enviroscreen_la, canopy_coverage, by = join_by(tract == geoid20))
test %>%
  ggplot() +
  geom_sf(aes(fill = existing_canopy_pct))

enviroscreen_la %>%
  ggplot() +
  geom_sf() +
  geom_sf(data = test, aes(fill = existing_canopy_pct)) +
  geom_sf(data = redlining_sf, aes(color = grade), fill = NA) +
  theme_void()

enviroscreen_la %>%
  ggplot() +
  geom_sf(data = test, aes(fill = existing_canopy_pct, color = existing_canopy_pct)) +
  theme_void()

join_test <- st_filter(enviroscreen_la, la_census_tracts)

enviroscreen_final <- join_test %>%
  filter(tract != 6037930101) %>%
  filter(tract != 6037930301) %>%
  filter(tract != 6037930200) %>%
  filter(tract != 6037920303)


ggplot() +
  geom_sf(fill = "gray") +
  theme_void()


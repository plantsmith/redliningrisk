### This is our data wrangling

# libraries
library(tidyverse)
library(here)
library(sf)
library(tidycensus)

### Step 1: Census data filtered to Los Angeles
# all of LA county
la_census <- tidycensus::get_acs(
  state = "CA",
  county = "Los Angeles",
  geography = "tract",
  variables = "B25004_001", ## Vacancy Status
  geometry = TRUE,
  year = 2022
)

# filtered to exclude unincorporated areas and islands
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


### Step 2: Enviroscreen data filtered to Los Angeles
# read in and filter out areas we know we don't want
enviroscreen_sf <- read_sf(here("data",
                                "calenviroscreen_shp",
                                "CES4 Final Shapefile.shp")) %>%
  janitor::clean_names() %>%
  filter(county == "Los Angeles") %>%
  filter(tract != 6037599100) %>% # islands
  filter(tract != 6037599000) %>% # islands
  filter(tract != 6037980003) %>% # unincorporated
  filter(tract != 6037930101) %>% # forests, unincorporated areas, etc
  filter(tract != 6037930301) %>%
  filter(tract != 6037930200) %>%
  filter(tract != 6037920303) %>%
  mutate(across(c_iscore:other_mult, ~replace(., . < 0, NA)))

# set crs to be the same as la census tracts
enviroscreen_sf <- st_transform(enviroscreen_sf, st_crs(la_census_filter))

# filter out northern areas so we just have LA itself left
enviroscreen_clean <- st_filter(enviroscreen_sf, la_census_filter)


### Step 3: Canopy coverage data
# get data
canopy_coverage <- read_csv(here('data/tree_canopy_cover2016.csv')) %>%
  janitor::clean_names()

# left join with enviroscreen dataset
enviroscreen_canopy <- left_join(enviroscreen_clean, canopy_coverage, by = join_by("tract" == "geoid20"))


### Step 4: Redlining data
# get data
redlining_sf <- read_sf(here('data/mappinginequality.gpkg')) %>%
  janitor::clean_names() %>%
  filter(city == "Los Angeles") %>%
  drop_na()

# set crs to be the same as our enviroscreen dataset
redlining_sf <- st_transform(redlining_sf, st_crs(enviroscreen_clean))

# how could we join redlining with our other datasets if everything else is census tract, and this isn't??
# get data for redlining applied to modern day census tracts
updated_redlining <- read_csv(here('data', 'HOLC_2020_census_tracts', 'HOLC_2020_census_tracts.csv')) %>%
  janitor::clean_names() %>%
  mutate(geoid20 = as.numeric(geoid20))

# join with enviroscreen dataset
enviroscreen_redline <- left_join(enviroscreen_canopy, updated_redlining, by = join_by("tract" == "geoid20"))

### Step 5: Heat risk data
# get data
heatrisk_sf <- read_sf(here('data','HeatRisk_7.7.2022','ziplevel_heatmap_07072022.shp')) %>%
  janitor::clean_names()

# set crs to match enviroscreen dataset
heatrisk_zips <- st_transform(heatrisk_sf, st_crs(enviroscreen_clean)) %>%
  st_drop_geometry() %>%
  mutate(zip = as.numeric(zcta))

# join with enviroscreen dataset based on zip
enviroscreen_heat <- left_join(enviroscreen_redline, heatrisk_zips, by = join_by("zip" == "zip"))

### Step 6: Save final dataset
st_write(enviroscreen_heat, here('data', 'enviroscreen_final.gpkg'), append = FALSE)

### CHECK PLOT
enviroscreen_heat %>%
  ggplot() +
  geom_sf(aes(fill = zip_pct_64, color = class1)) +
  theme_void()

enviroscreen_heat %>%
  st_drop_geometry() %>%
  drop_na() %>%
  group_by(class1) %>%
  summarize(n = n(),
            mean_canopy = mean(existing_canopy_pct),
            mean_heat = mean(zip_pct_64),
            mean_white = mean(white),
            mean_poverty = mean(poverty_p),
            mean_asthma = mean(asthma_p))

enviroscreen_heat %>%
  st_drop_geometry() %>%
  select(poverty) %>%
  ggplot() +
  geom_histogram(aes(x = poverty))

enviroscreen_final %>%
  st_drop_geometry() %>%
  filter(class1 == "D") %>%
  select(class1, white, hispanic, african_am, aapi, native_am, other_mult) %>%
  pivot_longer(cols = white:other_mult, names_to = "race", values_to = "percent") %>%
  drop_na() %>%
  group_by(class1, race) %>%
  summarize(mean_percent = mean(percent)) %>%
  ggplot(aes(x = "", y = mean_percent, fill = race)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  theme_void()

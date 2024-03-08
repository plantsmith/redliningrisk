library(dplyr)
library(knitr)
library(kableExtra)

#Table from
means_table <- enviroscreen_final %>%
  st_drop_geometry() %>%
  drop_na() %>%
  group_by(class1) %>%
  summarize(n = n(),
            mean_canopy = mean(existing_canopy_pct),
            mean_heatER = mean(zip_pct_64),
            mean_poverty = mean(poverty))

# use kable to make it fancy
means_kable_table <- kable(means_table, format = "html", spacing = "m", align = "c",
                     col.names = c("Class", "Count", "Mean Canopy", "Mean Heat ER", "Mean Poverty")) %>%
  kable_styling(full_width = FALSE)


# Save
save_kable(means_kable_table, file = "plots/means_table.html")



enviroscreen_heat %>%
  ggplot() +
  geom_sf(aes(fill = zip_pct_64, color = class1)) +
  theme_void()

new <- enviroscreen_redline %>%
  st_drop_geometry() %>%
  drop_na() %>%
  group_by(class1) %>%
  summarize(mean_canopy = mean(existing_canopy_pct))

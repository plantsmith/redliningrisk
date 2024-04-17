### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)
library(maps)

## get our data
enviroscreen_final <- read_sf(here('data', 'enviroscreen_final.gpkg'))
enviroscreen_trimmed <- enviroscreen_final %>%
  select(canopy_pct = existing_canopy_pct, pct_poverty = poverty, heat_ER_visits = zip_pct_64)

  ### Create the user interface:
  ui <- fluidPage(

    theme=bs_theme(bootswatch = 'yeti'),

    titlePanel(h1("Mapping Heat Risk Inequality")),

    tabsetPanel(
      tabPanel(
        title = 'Home',
        p('This will be our first page, with info and pictures about the project')
        ), ### end tab 1

      tabPanel(
        title = 'Map',
        p(h3("Interactive Map of the City of Los Angeles")),
        sidebarLayout(
          sidebarPanel("",
                       width = 3,
                       checkboxGroupInput(
                         inputId = "class1",
                         label = strong("Choose Redlining Category"),
                         choices = c("Best" = "A",
                                     "Still Desirable" = "B",
                                     "Definitely Declining" = "C" ,
                                     "Hazardous" = "D"),
                         selected = "A"), # <- Closed checkboxGroupInput

                       # sliderInput(
                       #   inputId = "canopy",
                       #   label = "Canopy Coverage (%)",
                       #   min = 0,
                       #   max = 70,
                       #   value = 0
                       # ), # <- Closed sliderInput
                       #
                       # sliderInput(
                       #   inputId = "poverty",
                       #   label = "Poverty (%)",
                       #   min = 0,
                       #   max = 95,
                       #   value = 0
                       # ), # <- Closed sliderInput
                       #
                       # sliderInput(
                       #   inputId = "heat_num",
                       #   label = "Number of Excessive Heat-related ER Visits",
                       #   min = 0,
                       #   max = 33,
                       #   value = 0
                       # ), # <- Closed sliderInput

                       varSelectInput(inputId = "variable_name",
                                    label = strong("Choose Variable"),
                                    data = enviroscreen_trimmed %>% st_drop_geometry(),
                                    selected = "existing_canopy_pct",
                                    multiple = FALSE)
          ), ### end sidebarPanel

          mainPanel(width = 9,

                    "Select redlining categories to see which census tracts in the city were historically assigned that rating.",
                    "Toggle between variables in the data to visualize the areas of the city with higher or lower canopy coverage, percent of the population living in poverty, or number of excessive heat-related ER visits.",
                    plotOutput(outputId = "grade_plot",
                               width = "100%"),
                    h5("Average Canopy Cover, % Poverty, and Excessive Heat-Related ER Visits by Redlining Grade"),
                    tableOutput("summary_table")
        ), ### end mainPanel
        ), ### end sidebarLayout
        ), ### end tab 2

      tabPanel(
        title = 'Histograms',
        p(h3("Histograms of Environmental Health Indicators")),
        sidebarLayout(
          sidebarPanel("Select redlining categories to see the distribution of environmental health indicator values for all census tracts within that category.",
                       radioButtons(inputId = "grade",
                       label = strong("Choose Redlining Category"),
                       choices = c("Best" = "A",
                                   "Still Desirable" = "B",
                                   "Definitely Declining" = "C" ,
                                   "Hazardous" = "D"),
                       selected = "A")

          ),
          mainPanel(
                    h5("Percent of Census Tract Living in Poverty"),
                    plotOutput(outputId = "hist_poverty", height = "200"),
                    h5("Percent of Tree Canopy Coverage"),
                    plotOutput(outputId = "hist_canopy", height = "200"),
                    h5("Number of Excess Heat-related ER Visits"),
                    plotOutput(outputId = "hist_heatER", height = "200")

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

     server <-

      function(input, output) {

       grade_select <- reactive({
       redline_grade <- enviroscreen_final %>%
          filter(class1 %in% input$class1)
       return(redline_grade)

      }) ### end grade_select

       grade_select_hist <- reactive({
         redline_grade <- enviroscreen_final %>%
           filter(class1 %in% input$grade)
         return(redline_grade)

       }) ### end grade_select_hist

       canopy_select <- reactive({
         canopy_tracts <- enviroscreen_final %>%
           filter(existing_canopy_pct < input$canopy)
         return(canopy_tracts)
       }) ### end canopy_select

       poverty_select <- reactive({
         poverty_tracts <- enviroscreen_final %>%
           filter(poverty < input$poverty)
         return(poverty_tracts)
      }) ### end poverty_select

       heatER_select <- reactive({
         heat_tracts <- enviroscreen_final %>%
           filter(zip_pct_64 < input$heat_num)
         return(heat_tracts)
       }) ### end heatER_select

       # variable_select <- reactive({
       #   selected_tracts <- enviroscreen_final %>%
       #     select(input$variable_name)
       #   return(selected_tracts)
       # }) ### end heatER_select

      grade_colors <- c("A" = "green", "B" = "lightblue", "C" = "orange", "D" = "red")
      # canopy_colors <- ifelse(enviroscreen_final$existing_canopy_pct <30, "lightgreen", "darkgreen")

      output$grade_plot <- renderPlot({
        # Base plot with LA County boundaries
        base_plot <- ggplot() +
          geom_sf(data = enviroscreen_final, color = "black", fill = "white") +
          # geom_sf(data = city_trees, aes(), color = "darkgreen", size = 0.1) +
          theme_void()

        # Add grade polygons
        grade_plot <- base_plot +
          # geom_sf(data = canopy_select(), aes(fill = "canopy"), alpha = 0.3) +
          # geom_sf(data = poverty_select(), aes(fill = "poverty"), alpha = 0.3) +
          # geom_sf(data = heatER_select(), aes(fill = "heat"), alpha = 0.3) +
          geom_sf(data = enviroscreen_trimmed, aes(fill = !!input$variable_name)) +
          geom_sf(data = grade_select(), aes(color = class1), fill = NA, linewidth = 0.4) +
          # scale_fill_manual(values = c("canopy" = "green3", "poverty" = "purple", "heat" = "darkred")) +
          scale_fill_continuous(type = "viridis") +
          scale_color_manual(values = grade_colors) +
          labs(color = "Redlining Grade")

        grade_plot
      }) ### end grade_plot output

      output$summary_table <- renderTable(
        means_table <- enviroscreen_final %>%
          st_drop_geometry() %>%
          drop_na() %>%
          group_by(class1) %>%
          summarize(n = n(),
                    mean_canopy = mean(existing_canopy_pct),
                    mean_heatER = mean(zip_pct_64),
                    mean_poverty = mean(poverty)),
        spacing = 'm',
        width = '100%',
        align = 'c'
        ) ### end summary_table output

      output$hist_poverty <- renderPlot({
       ggplot() +
          geom_histogram(data = grade_select_hist(),
                         aes(x = poverty), fill = "purple") +
          theme_minimal()
      }) ### end hist_poverty output

      output$hist_canopy <- renderPlot({
        ggplot() +
          geom_histogram(data = grade_select_hist(),
                         aes(x = existing_canopy_pct), fill = "darkgreen") +
          theme_minimal()
      }) ### end hist_canopy output

      output$hist_heatER <- renderPlot({
        ggplot() +
          geom_histogram(data = grade_select_hist(),
                         aes(x = zip_pct_64), fill = "red4") +
          labs(x = "excess ER visits on hot days") +
          theme_minimal()
      }) ### end hist_heatER output

    } ### end server

### Combine them into an app:
shinyApp(ui = ui, server = server)




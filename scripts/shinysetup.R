### Attach necessary packages
library(shiny)
library(tidyverse)
library(sf)
library(here)
library(bslib)
library(maps)

## get our data
# enviroscreen_final <- read_sf(here('data', 'enviroscreen_final.shp'))
enviroscreen_final <- enviroscreen_heat


  ### Create the user interface:
  ui <- fluidPage(

    theme=bs_theme(bootswatch = 'yeti'),

    titlePanel("Mapping Heat Risk Inequality"),

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
                         inputId = "class1",
                         label = "Choose Area Category",
                         choices = c("Best" = "A",
                                     "Still Desirable" = "B",
                                     "Definitely Declining" = "C" ,
                                     "Hazardous" = "D"),
                         selected = 1), # <- Closed checkboxGroupInput

                       sliderInput(
                         inputId = "canopy",
                         label = "Canopy Coverage (%)",
                         min = 0,
                         max = 70,
                         value = 0
                       ), # <- Closed sliderInput

                       sliderInput(
                         inputId = "poverty",
                         label = "Poverty (%)",
                         min = 0,
                         max = 95,
                         value = 0
                       ) # <- Closed sliderInput
          ), ### end sidebarPanel

          mainPanel("Output graph. Below the graph is our summary table",

                    plotOutput(outputId = "grade_plot"),
                    tableOutput("summary_table"))

        ), ### end sidebarLayout
        ), ### end tab 2

      tabPanel(
        title = 'Histograms',
        p('This is our second data tab, containing a histogram'),
        sidebarLayout(
          sidebarPanel("",
                       radioButtons(inputId = "class1",
                       label = "Choose Area Category",
                       choices = c("Best" = "A",
                                   "Still Desirable" = "B",
                                   "Definitely Declining" = "C" ,
                                   "Hazardous" = "D"),
                       selected = 1)

          ),
          mainPanel("histogram here: show distribution of data values by census tract",

                    plotOutput(outputId = "hist_poverty"),
                    plotOutput(outputId = "hist_canopy"),
                    plotOutput(outputId = "hist_heatER")

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

      grade_colors <- c("A" = "green", "B" = "blue", "C" = "orange", "D" = "red")
      # canopy_colors <- ifelse(enviroscreen_final$existing_canopy_pct <30, "lightgreen", "darkgreen")

      output$grade_plot <- renderPlot({
        # Base plot with LA County boundaries
        base_plot <- ggplot() +
          geom_sf(data = enviroscreen_final, color = "black", fill = "lightgrey") +
          # geom_sf(data = city_trees, aes(), color = "darkgreen", size = 0.1) +
          theme_void()

        # Add grade polygons
        grade_plot <- base_plot +
          geom_sf(data = canopy_select(), aes(fill = "canopy"), alpha = 0.3) +
          geom_sf(data = poverty_select(), aes(fill = "poverty"), alpha = 0.3) +
          geom_sf(data = grade_select(), aes(color = class1), fill = NA) +
          scale_fill_manual(values = c("canopy" = "green3", "poverty" = "purple")) +
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
                    mean_poverty = mean(poverty))
        ) ### end summary_table output

      output$hist_poverty <- renderPlot({
       ggplot() +
          geom_histogram(data = grade_select(),
                         aes(x = poverty)) +
          theme_minimal()
      }) ### end hist_poverty output

      output$hist_canopy <- renderPlot({
        ggplot() +
          geom_histogram(data = grade_select(),
                         aes(x = existing_canopy_pct)) +
          theme_minimal()
      }) ### end hist_canopy output

      output$hist_heatER <- renderPlot({
        ggplot() +
          geom_histogram(data = grade_select(),
                         aes(x = zip_pct_64)) +
          labs(x = "excess ER visits on hot days") +
          theme_minimal()
      }) ### end hist_heatER output

    } ### end server

### Combine them into an app:
shinyApp(ui = ui, server = server)




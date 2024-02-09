### Attach necessary packages

library(shiny)
library(tidyverse)
library(palmerpenguins)

### Create the user interface

ui <- fluidPage(
  titlePanel('I add title'),
  sidebarLayout(
    sidebarPanel('put my widgets here',

        radioButtons(
          inputId = 'penguin_species',
          label = 'choose penguin species',
          choices = c('Adelie',"Gentoo","Cool Chinstrap Penguins!" = "Chinstrap")
          ),

        selectInput(
          inputId = "pt_color",
          label = "Select point color",
          choices = c("Roses are red" = "red",
                      "Violets are blue" = "blue",
                      "Oranges are ..." = "orange")
        ) ### end of selectInput

        ), ### end sidebarPanel

    mainPanel('put my graph here',
              plotOutput(outputId = 'penguin_plot'),
              h3('Summary table'),
              tableOutput(outputId = 'penguin_table')
              ) ### end main panel

  ) ### end sidebarLayout
) ### end of fluidPage

### Create the server function

server <- function(input, output) {

  penguin_select <- reactive({
    penguins_df <- penguins %>%
      filter(species == input$penguin_species)
    return(penguins_df)
  }) #### end penguin_select reactive fxn

  output$penguin_plot <- renderPlot({
    ggplot(data = penguin_select()) +
      geom_point(aes(x = flipper_length_mm, y = body_mass_g),
                 color = input$pt_color)
  }) ### end penguin_plot

  penguin_sum_table <- reactive({
    penguin_summary_df <- penguins %>%
      filter(species == input$penguin_species) %>%
      group_by(sex) %>%
      summarize(mean_flip = mean(flipper_length_mm, na.rm = TRUE),
                mean_mass = mean(body_mass_g, na.rm = TRUE))
    return(penguin_summary_df)
  })

  output$penguin_table <- renderTable(
    penguin_sum_table()
  )



} ### end server


### Combine them into an app

shinyApp(ui = ui, server = server)

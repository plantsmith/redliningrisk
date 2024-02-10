### Attach necessary packages

library(shiny)
library(tidyverse)
library(palmerpenguins)
library(bslib)

my_theme <- bs_theme(bootswatch = 'vapor') %>%
  bs_theme_update(bg = "rgb(235, 175, 175)", fg = "rgb(63, 11, 11)",
                     primary = "#B5C142", secondary = "#575155", info = "#103851",
                     base_font = font_google("Zilla Slab"), code_font = font_google("Syne Mono"),
                     heading_font = font_google("Montserrat Alternates"), font_scale = 1.3)


### Create the user interface

ui <- fluidPage(
  theme = my_theme,

  titlePanel('I add title'),
  sidebarLayout(
    sidebarPanel(

      actionButton(inputId = "dice_button", label = "Lucky", icon = icon("dice")),

      textOutput(outputId = "diceroll"),

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

    mainPanel(
      h2("This is our heading font"),
      p("this is our body text"),
      code("here is code"),

              plotOutput(outputId = 'penguin_plot'),
              h3('Summary table'),
              tableOutput(outputId = 'penguin_table')
              ) ### end main panel

  ) ### end sidebarLayout
) ### end of fluidPage

### Create the server function

server <- function(input, output) {

  # bs_themer() ### only temporary until we get theme we like - then hard code theme


  output$diceroll <- reactive({
    x <- input$dice_button
    rolls <- sample(1:6, size = 2, replace = TRUE)
    txt_out <- sprintf("Die 1: %s, die 2: %s, total: %s",rolls[1], rolls[2],sum(rolls))
    return(txt_out)
  })

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




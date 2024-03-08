### Create the user interface:
ui <- fluidPage(

  theme=bs_theme(bootswatch = 'yeti'),

  titlePanel(h1("Mapping Heat Risk Inequality")),

  tabsetPanel(
    tabPanel(
      title = 'Home',
      includeMarkdown('intro_text.md')
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
                 uiOutput("summary_table")
        ), ### end mainPanel
      ), ### end sidebarLayout
    ), ### end tab 2

    tabPanel(
      title = 'Health Indicators',
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

        ), ### end sidebarPanel
        mainPanel(
          h5("Percent of Census Tract Living in Poverty"),
          plotOutput(outputId = "hist_poverty", height = "200"),
          h5("Percent of Tree Canopy Coverage"),
          plotOutput(outputId = "hist_canopy", height = "200"),
          h5("Number of Excess Heat-related ER Visits"),
          plotOutput(outputId = "hist_heatER", height = "200")

        ) ### end mainPanel
      ) ### end sidebarLayout

    ), ### end tab 3

    tabPanel(
      title = 'Demographics',
      sidebarLayout(
        sidebarPanel("Select redlining categories to see the demographic composition of census tracts within that category.",
                     radioButtons(inputId = "grade_pie",
                                  label = strong("Choose Redlining Category"),
                                  choices = c("Best" = "A",
                                              "Still Desirable" = "B",
                                              "Definitely Declining" = "C" ,
                                              "Hazardous" = "D"),
                                  selected = "A")

        ),
        mainPanel(
        plotOutput("pie")
        )
      ) ### end sidebarLayout

     ), ### end tab 4

    tabPanel(
      title = 'PCA',
      sidebarLayout(
        sidebarPanel("Select location blah blah blah",
                     radioButtons(inputId = "loc",
                                  label = strong("Choose Location"),
                                  choices = c("Los Angeles",
                                              "Long Beach"),
                                  selected = "Los Angeles")

        ),
        mainPanel(
          plotOutput("pca_plot")
        )
      ) ### end sidebarLayout
    ), ### end tab 5

    tabPanel(
      title = 'Data & Resources',
      includeMarkdown('citations.md')
      ) ### end tab 6

  ) ### end tabsetPanel



) ### end fluidPage

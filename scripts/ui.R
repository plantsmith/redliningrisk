
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
                     radioButtons(inputId = "grade",
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





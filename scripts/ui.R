ui <- fluidPage(
  theme = bs_theme(bootswatch = "yeti"),

  ############################HOMEPAGE###########################################
  titlePanel(h1("Mapping Heat Risk Inequality")),

  tabsetPanel(
    tabPanel("Home",
             # Content for the home page
             # Including the image, text, etc.
             img(src = "la-skyline.jpeg", width = "100%"),
             p(em("Ariel View of Los Angeles 2023. Image from RDNE Photo Archive"),
               style = "text-align: center; font-size:12px"), # end photo text
             hr(), # horizontal line break
             fluidRow(
               column(width = 8,
                      h4(strong("PURPOSE"), style = "text-align:justify;color:black"),
                      p("Enter Text Here"), # End paragraph 1
                      br(), # Line break
                      h4(strong("WHAT IS REDLINING"), style = "text-align:justify;color:black"),
                      p("The Home Owner's Loan Corporation (HOLC), established during the New Deal to stabilize the housing market amidst the Great Depression, aimed to assist struggling homeowners. However.....ADD THE REST"),
                      br(),
                      p("TEST"),
                      br(),
                      h4(strong("ENVIRONMENTAL IMPLICATIONS"), style = "text-align:justify;color:black;background-color:#8EC7D2;padding:15px;border-radius:10px"),
                      p("ADD THE REST"),
                      br(),
                      p("TEST"),
                      br(),
                      h4(strong("HEALTH IMPLICATIONS"), style = "text-align:justify;color:black;background-color:#8EC7D2;padding:15px;border-radius:10px"),
                      p("The Home Owner's Loan Corporation (HOLC), established during the New Deal to stabilize the housing market amidst the Great Depression, aimed to assist struggling homeowners. However.....ADD THE REST"),
                      br(),
                      p("TEST"),
                      br() # end of background section
               )
             ), # end fluidrow 1

             # "Developed by" section added here
             p(em("Developed by"),br("Olivia Hemond and Natalie Smith"),style="text-align:center;color:black"),
             br()
    ),

    ############################MAP##########################################
    tabPanel("Map",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 checkboxGroupInput(
                   inputId = "class1",
                   label = strong("Choose Redlining Category"),
                   choices = c("Best" = "A",
                               "Still Desirable" = "B",
                               "Definitely Declining" = "C" ,
                               "Hazardous" = "D"),
                   selected = "A"
                 ),
                 varSelectInput(inputId = "variable_name",
                                label = strong("Choose Variable"),
                                data = enviroscreen_trimmed %>% st_drop_geometry(),
                                selected = "existing_canopy_pct",
                                multiple = FALSE)
               ),
               mainPanel(width = 9,
                         "Select redlining categories to see which census tracts in the city were historically assigned that rating.",
                         "Toggle between variables in the data to visualize the areas of the city with higher or lower canopy coverage, percent of the population living in poverty, or number of excessive heat-related ER visits.",
                         plotOutput(outputId = "grade_plot", width = "100%"),
                         h5("Average Canopy Cover, % Poverty, and Excessive Heat-Related ER Visits by Redlining Grade"),
                         uiOutput("summary_table")
               )
             )
    ),
    ############################HEALTH###########################################
    tabPanel("Health Indicators",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 radioButtons(
                   inputId = "grade",
                   label = strong("Choose Redlining Category"),
                   choices = c("Best" = "A",
                               "Still Desirable" = "B",
                               "Definitely Declining" = "C" ,
                               "Hazardous" = "D"),
                   selected = "A"
                 )
               ),
               mainPanel(
                 h5("Percent of Census Tract Living in Poverty"),
                 plotOutput(outputId = "hist_poverty", height = "200"),
                 h5("Percent of Tree Canopy Coverage"),
                 plotOutput(outputId = "hist_canopy", height = "200"),
                 h5("Number of Excess Heat-related ER Visits"),
                 plotOutput(outputId = "hist_heatER", height = "200")
               )
             )
    ),
    ############################DEMOGRAPHICS###########################################
    tabPanel("Demographics",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 radioButtons(
                   inputId = "grade_pie",
                   label = strong("Choose Redlining Category"),
                   choices = c("Best" = "A",
                               "Still Desirable" = "B",
                               "Definitely Declining" = "C" ,
                               "Hazardous" = "D"),
                   selected = "A"
                 )
               ),
               mainPanel(
                 plotOutput("pie")
               )
             )
    ),
    tabPanel("PCA",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 radioButtons(
                   inputId = "loc",
                   label = strong("Choose Location"),
                   choices = c("Los Angeles", "Long Beach"),
                   selected = "Los Angeles"
                 )
               ),
               mainPanel(
                 plotOutput("pca_plot")
               )
             )
    ),
    ############################CITE###########################################
    tabPanel("Data & Resources",
             includeMarkdown('citations.md')
    )
  )
)

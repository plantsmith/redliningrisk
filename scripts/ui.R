
# my_theme <- bs_theme(bootswatch = 'vapor') %>%
#   bs_theme_update(bg = "rgb(235, 175, 175)", fg = "rgb(63, 11, 11)",
#                   primary = "#B5C142", secondary = "#575155", info = "#103851",
#                   base_font = font_google("Zilla Slab"), code_font = font_google("Syne Mono"),
#                   heading_font = font_google("Montserrat Alternates"), font_scale = 1.3)
#
# ui <- fluidPage(
#   theme = my_theme,

ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),
  ############################HOMEPAGE###########################################
  titlePanel(h1("Mapping Heat Risk Inequality")),

  tabsetPanel(
    tabPanel("Home",
             # Adding an image to the front page
             imageOutput("la-skyline"),

             # Adding text beneath photo for credits
             p(em("Ariel view of Los Angeles. Photo by RMDE Photo Archive."), style="text-align: center; font-size:12px"
             ), # end photo text
             hr(), # horizontal line break


             fluidRow(
               column(width = 8,
                      h4(strong("PURPOSE"), style = "text-align:justify;color:black"),
                      p("Enter Text Here", style = "font-size: 10pt;"), # End paragraph 1
                      br(), # Line break

                      h4(strong("WHAT IS REDLINING"), style = "text-align:justify;color:black"),
                      p("The Home Owners' Loan Corporation (HOLC), established during the New Deal to stabilize the housing market amidst the Great Depression, aimed to assist struggling homeowners. However, HOLC's operations also perpetuated racial discrimination in mortgage lending, reflecting prevailing attitudes of the time.",
                        br(),
                        br(),
                        "Between 1935 and 1940, HOLC created area descriptions and color-coded maps to evaluate neighborhoods' mortgage security. HOLC's criteria included housing quality, property values, and residents' racial and ethnic backgrounds. These maps categorized areas into four types: 'Type A' neighborhoods outlined in green were considered the most desirable for lending, typically affluent suburbs; 'Type B' neighborhoods outlined in blue were still desirable; 'Type C' neighborhoods outlined in yellow were declining, and 'Type D' neighborhoods outlined in red were the riskiest for mortgage support, often older districts in city centers and predominantly Black.",
                        br(),
                        br(),
                        "These grades were used for redlining, restricting mortgage financing and homeownership opportunities, particularly in communities of color. These discriminatory practices continue to shape urban inequality today.",
                        style = "font-size: 10pt;"), # Adjusting font size
                      br(),

                      h4(strong("ENVIRONMENTAL IMPLICATIONS"), style = "text-align:justify;color:black"),
                      p("Environmental disparities in American cities reflect historic redlining policies that favored wealthy, predominantly white neighborhoods over poorer, often minority communities. A study led by scientists in 2017-2018 used HOLC redlining maps to investigate the link between discriminatory housing practices and contemporary environmental stressors, particularly heat islands. They found that areas previously redlined by HOLC were significantly hotter than greenlined neighborhoods during summer months, mainly due to differences in surface materials and tree canopy coverage. Subsequent research has confirmed these findings, highlighting the enduring impact of past discriminatory policies on present-day environmental inequalities and public health outcomes.",
                        style = "font-size: 10pt;"), # Adjusting font size
                      br(),

                      h4(strong("HEALTH IMPLICATIONS"),  style = "text-align:justify;color:black"),
                      p("The mechanisms through which historic redlining influences present-day public health are an ongoing topic of study. Potential contributing factors include economic isolation, disparate property valuation, and environmental exposures.",
                        br(),
                        br(),
                        "Research on redlining and health has intensified since the digitization of HOLC maps, revealing associations between redlined areas and various health indicators such as mortality, pre-term birth, cardiovascular disease, and COVID-19 infection burden. Redlining has also been linked to environmental determinants of health, such as air pollution and access to healthcare services.",
                        style = "font-size: 10pt;"), # Adjusting font size
                      br(),
                      # end of background section
               ),
               column(width = 4,
                      # Content for the second column
                      img(src = "redlining-la.jpeg", width = "100%"),
                      p(em("HOLC map of  Los Angeles County, 1939. Image from  Mapping Inequality,University of Richmond's Digital Scholarship Lab."),
                        style = "text-align: center; font-size:12px"), # end photo text
                      br(), # Line break
                      img(src = "your_image2.jpeg", width = "100%"),
                      p(em("TBD"),
                        style = "text-align: center; font-size:12px"), # end photo text
                      br(), # Line break
                      img(src = "your_image3.jpeg", width = "100%"),
                      p(em("TBD"),
                        style = "text-align: center; font-size:12px"), # end photo text
               )
             ), # end fluidrow 1

             # "Developed by" section added here
             p(em("Developed by"), br("Olivia Hemond and Natalie Smith"), style = "font-size: 10pt; text-align: left; color: black;"),
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

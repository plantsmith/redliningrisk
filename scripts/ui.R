

ui <- fluidPage(
  theme = bs_theme(bootswatch = "lux"),
  ############################HOMEPAGE###########################################
  titlePanel(h1("Mapping Heat Risk Inequality")),

  tabsetPanel(
    tabPanel("Home",
             # Adding an image to the front page
             HTML('<figure style="text-align:center;">
                 <img src="la-skyline.jpg" height="70%" width="70%" alt="Aerial view of Los Angeles">
                 <figcaption style="font-size:12px;">Aerial view of Los Angeles. Photo by RMDE Photo Archive.</figcaption>
                 </figure>'),
             hr(), # horizontal line break


             fluidRow(
               column(width = 7,
                      h4(strong("PURPOSE"), style = "text-align:justify;color:black"),
                      p("This interactive data application explores how historical redlining is related to modern-day urban health inequalities and environmental injustices.", style = "font-size: 12pt;"), # End paragraph 1
                      br(), # Line break

                      h4(strong("WHAT IS REDLINING"), style = "text-align:justify;color:black"),
                      p("The Home Owners' Loan Corporation (HOLC), established during the New Deal to stabilize the housing market amidst the Great Depression, aimed to assist struggling homeowners. However, HOLC's operations also perpetuated racial discrimination in mortgage lending, reflecting prevailing attitudes of the time.",
                        br(),
                        br(),
                        "Between 1935 and 1940, HOLC created area descriptions and color-coded maps to evaluate neighborhoods' mortgage security. HOLC's criteria included housing quality, property values, and residents' racial and ethnic backgrounds. These maps categorized areas into four types:",
                        br(),
                        tags$li("'Type A' neighborhoods outlined in green were considered the most desirable for lending, typically affluent suburbs;"),
                        tags$li("'Type B' neighborhoods outlined in blue were still desirable;"),
                        tags$li("'Type C' neighborhoods outlined in yellow were declining;"),
                        tags$li("'Type D' neighborhoods outlined in red were the riskiest for mortgage support, often older districts in city centers and predominantly Black and People of Color."),
                        br(),
                        "These grades were used for redlining, restricting mortgage financing and homeownership opportunities, particularly in communities of color. These discriminatory practices continue to shape urban inequality today.",
                        style = "font-size: 12pt;"), # Adjusting font size
                      br(),

                      h4(strong("ENVIRONMENTAL IMPLICATIONS"), style = "text-align:justify;color:black"),
                      p("Environmental disparities in American cities reflect historic redlining policies that favored wealthy, predominantly white neighborhoods over poorer, often minority communities. Wealthier urban areas tend to have more parks and trees, which combat the urban heat island effect by providing shade and cooling the air temperature. A study led by scientists in 2017-2018 used HOLC redlining maps to investigate the link between discriminatory housing practices and contemporary environmental stressors, particularly heat islands. They found that areas previously redlined by HOLC were significantly hotter than greenlined neighborhoods during summer months, mainly due to differences in surface materials and tree canopy coverage. Subsequent research has confirmed these findings, highlighting the enduring impact of past discriminatory policies on present-day environmental inequalities and public health outcomes.",
                        style = "font-size: 12pt;"), # Adjusting font size
                      br(),

                      h4(strong("HEALTH IMPLICATIONS"),  style = "text-align:justify;color:black"),
                      p("The mechanisms through which historic redlining influences present-day public health are an ongoing topic of study. Potential contributing factors include economic isolation, disparate property valuation, and environmental exposures.",
                        br(),
                        br(),
                        "Research on redlining and health has intensified since the digitization of HOLC maps, revealing associations between redlined areas and various health indicators such as mortality, pre-term birth, cardiovascular disease, and COVID-19 infection burden. Redlining has also been linked to environmental determinants of health, such as air pollution and access to healthcare services.",
                        style = "font-size: 12pt;"), # Adjusting font size
                      br(),
                      # end of background section
               ),
               column(width = 5,
                      # Content for the second column
                      img(src = "holc-redlining-la.jpeg", width = "100%"),
                      p(em("HOLC map of Los Angeles County, 1939. Image from Mapping Inequality, University of Richmond's Digital Scholarship Lab."),
                        style = "text-align: center; font-size:12px"), # end photo text
                      br(), # Line break
                      img(src = "no_trees_crenshaw.jpeg", width = "100%"),
                      p(em("Crenshaw Blvd, Los Angeles; Photo by Francine Orr / Los Angeles Times"),
                        style = "text-align: center; font-size:12px"), # end photo text
                      br(), # Line break
                      img(src = "tree_street.jpeg", width = "100%"),
                      p(em("Alpine Drive, Beverly Hills; Photo by Pernell Quilon"),
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
                                multiple = FALSE),
                 p(em("'canopy_pct' = % of area covered by tree canopy"),
                   style = "text-align: left; font-size:10px"),
                 p(em("'pct_poverty' = % of population living 2x below the federal poverty level"),
                   style = "text-align: left; font-size:10px"),
                 p(em("'heat_ER_visits' = daily excess number of emergency room visits during an extreme heat day"),
                   style = "text-align: left; font-size:10px"),

               ),
               mainPanel(width = 9,
                         br(),
                         "Select redlining categories to see which census tracts in the city were historically assigned that rating.",
                         "Toggle between variables in the data to visualize the areas of the city with higher or lower canopy coverage, percent of the population living in poverty, or number of excessive heat-related ER visits.",
                         plotOutput(outputId = "grade_plot", width = "900px", height = "600px"),
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
                 br(),
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
                 br(),
                 "Select redlining categories to see the demographic composition of areas historically assigned that rating.",
                 br(),
                 plotOutput("pie", width = "900px", height = "600px")
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
                 ),
                 p(strong("Full list of PCA variables:"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Asthma: Age-adjusted rate of emergency department visits for asthma"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Diesel PM (log_diesel_pm): Emissions from on-road and non-road sources, logged."),
                   style = "text-align: left; font-size:10px"),
                 p(em("Drinking Water: Drinking water contaminant index for selected contaminants"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Education: Percent of population over 25 with less than a high school education"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Existing Canopy Coverage (existing_canopy_pct): Percent of existing canopy coverage"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Heat Risk: Daily excess number of emergency visits during an extreme heat day"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Lead: Potential risk for lead exposure in children living in low-income communities with older housing"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Linguistic Isolation (ling_isol): Percent limited English speaking households"),
                   style = "text-align: left; font-size:10px"),
                 p(em("PM 2.5 (pm2_5): Annual mean PM2.5 concentrations"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Poverty: Percent of population living below two times the federal poverty level"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Traffic: Traffic density in vehicle-kilometers per hour per road length, within 150 meters of the census tract boundary"),
                   style = "text-align: left; font-size:10px"),
                 p(em("Unemployment: Percent of the population over the age of 16 that is unemployed and eligible for the labor force"),
                   style = "text-align: left; font-size:10px"),
               ),
               mainPanel(
                 br(),
                 "Select a location to view a Principal Component Analysis (PCA) biplot for that area.",
                 plotOutput("pca_plot", width = "900px", height = "600px"),
                 h5("Observations"),
                 tags$li("Poverty and low educational achievement are highly positively correlated. This may reflect the cyclical effects of poverty; for those living in povery, education and well-paying jobs are harder to obtain, perpetuating these conditions."),
                 tags$li("Asthma and heat illness rates are highly positively correlated. Interestingly, asthma rates are not strongly correlated with diesel particulate matter, traffic, or PM2.5 pollution. Perhaps there are other pollutants or risk factors that are more significant contributors to asthma."),
                 tags$li("The amount of tree canopy cover in a census tract is generally negatively correlated with poverty, pollution metrics, and health conditions. Areas in the 'A' grade generally had high canopy cover. This is a notable indication that higher canopy coverage seems to be present in more affluent communities, which are more economically stable and have lower health risks."),
                 tags$li("Interestingly, census tracts do not clearly cluster based upon redlining grade, but rather there seems to be a large amount of variation in the tracts in each grade. The one exception seems to be 'A' areas, which are generally found within the left half of the plots. The lack of clear clustering indicates there may be other variables worth exploring that more clearly delineate the differences between these areas."),
                 br(),
               )
             )
    ),

    ############################CITE###########################################
    tabPanel("Data & Resources",
             br(),
             includeMarkdown('citations.md')
    )
  )
)

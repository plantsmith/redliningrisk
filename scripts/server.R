server <- function(input, output, session){

}

peng_reactive <- reactive({
  penguins %>%
    filter(species %in% input$species) %>%
    filter(island %in% input$island)
})

output$peng_plot <- renderPlot({
  ggplot(data=peng_reactive())+
    geom_point(aes(x=flipper,
                   y=body_mass_g,
                   color=species,
                   shape=island))+
    theme_minimal()
})

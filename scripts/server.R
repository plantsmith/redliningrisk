### REACTIVE GRAPH ###

server <-function(input, output) {

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

    output$summary_table <- renderTable({
      means_table <- enviroscreen_final %>%
        st_drop_geometry() %>%
        drop_na() %>%
        group_by(class1) %>%
        summarize(n = n(),
                  mean_canopy = mean(existing_canopy_pct),
                  mean_heatER = mean(zip_pct_64),
                  mean_poverty = mean(poverty))

      # Rename columns as vec
      colnames(means_table) <- c("Class", "Count", "Mean Canopy", "Mean Heat ER", "Mean Poverty")

      return(means_table)
    }, spacing = 'm', width = '100%', align = 'c')


    ### end summary_table output

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

    pie_df <- reactive({
      enviroscreen_final %>%
      st_drop_geometry() %>%
      filter(class1 %in% input$grade_pie) %>%
      select(class1, white, hispanic, african_am, aapi, native_am, other_mult) %>%
      pivot_longer(cols = white:other_mult, names_to = "race", values_to = "percent") %>%
      drop_na() %>%
      group_by(class1, race) %>%
      summarize(mean_percent = mean(percent))
      })

    demographic_colors <- c("dodgerblue", "goldenrod2", "goldenrod4", "darkorange", "royalblue3", "slategrey")
    output$pie <- renderPlot({
      ggplot(data = pie_df(), aes(x = "", y = mean_percent, fill = race)) +
        geom_bar(stat="identity", width=1) +
        coord_polar("y", start=0) +
        scale_fill_manual(values = demographic_colors) +
        theme_void()
    })

  } ### end server

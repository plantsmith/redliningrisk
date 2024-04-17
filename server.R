### REACTIVE GRAPH ###

server <-function(input, output) {

  # bs_themer()

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




    grade_colors <- c("A" = "green", "B" = "cyan", "C" = "orange", "D" = "firebrick1")

    output$grade_plot <- renderPlot({
      # Base plot with LA County boundaries
      base_plot <- ggplot() +
        geom_sf(data = enviroscreen_final, color = "black", fill = "white") +
        theme_void()

       # define fill label by matching the same thing in the es_vars vector (in global enviro)
      fill_lbl <- names(es_vars[es_vars == input$variable_name])

      #define fill column name as a "name" object instead of "character"
      #this was what the varSelectInput automatically did, here we're doing it manually
      # so it works with regular selectInput (which returns a "character" object)
      fill_col <- sym(input$variable_name)

      # Add grade polygons
      grade_plot <- base_plot +
        geom_sf(data = enviroscreen_trimmed, aes(fill = !!fill_col)) +
        geom_sf(data = grade_select(), aes(color = class1), fill = NA, linewidth = 0.6) +
        scale_fill_gradient(low = "lightskyblue", high = "navy", na.value = NA) +
        scale_color_manual(values = grade_colors) +
        labs(color = "Redlining Grade",fill = fill_lbl)+
        theme(legend.title = element_text(size = 16),  # Adjust legend title size
       legend.text = element_text(size = 16))

      grade_plot
    }, height = 600, width = 900) ### end grade_plot output

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
      ggplot(data = grade_select_hist(), aes(x = poverty)) +
        geom_histogram(fill = "skyblue", color = "white", bins = 20) +
        labs(x = "Poverty", y = "Frequency", title = " ") +
        theme_minimal() +
        theme(axis.text = element_text(size = 18),
              axis.title = element_text(size = 18),
              plot.title = element_text(size = 22))
    })

    output$hist_canopy <- renderPlot({
      ggplot(data = grade_select_hist(), aes(x = existing_canopy_pct)) +
        geom_histogram(fill = "dodgerblue", color = "white", bins = 20) +
        labs(x = "Existing Canopy Percentage", y = "Frequency", title = " ") +
        theme_minimal() +
        theme(axis.text = element_text(size = 18),
              axis.title = element_text(size = 18),
              plot.title = element_text(size = 22))
    })

    output$hist_heatER <- renderPlot({
      ggplot(data = grade_select_hist(), aes(x = zip_pct_64)) +
        geom_histogram(fill = "navy", color = "white", bins = 20) +
        labs(x = "Excess ER Visits on Hot Days", y = "Frequency", title = " ") +
        theme_minimal() +
        theme(axis.text = element_text(size = 18),
              axis.title = element_text(size = 18),
              plot.title = element_text(size = 22))
    })


    # Rename race
    race_pie <- c("white" = "White", "hispanic" = "Hispanic", "african_am" = "African American",
                  "aapi" = "Asian/Pacific Islander", "native_am" = "Native American",
                  "other_mult" = "Other/Multiracial")

    pie_df <- reactive({
      enviroscreen_final %>%
        st_drop_geometry() %>%
        filter(class1 %in% input$grade_pie) %>%
        select(class1, white, hispanic, african_am, aapi, native_am, other_mult) %>%
        pivot_longer(cols = white:other_mult, names_to = "race", values_to = "percent") %>%
        drop_na() %>%
        group_by(class1, race) %>%
        summarize(mean_percent = round(mean(percent), digits = 1)) %>%
        mutate(labels = paste0(mean_percent, "%")) %>%
        mutate(race = race_pie[race])
    })

    # Color palette
    demographic_colors <- c("#86CEFA", "#73B9EE","#5494DA","#3373C4", "#1750AC", "#003396")

    output$pie <- renderPlot({
      ggplot(data = pie_df(), aes(x = "", y = mean_percent, fill = race)) +
        geom_bar(stat = "identity", width = 1, color = "white") +
        geom_text(aes(x = 1.3, label = labels),
                  color = "white",
                  size = 7,
                  position = position_stack(vjust = 0.5)) +
        coord_polar("y", start = 0) +
        scale_fill_manual(values = demographic_colors) +
        theme_void() +
        theme(legend.position = "right",  # Moving legend to the right
              legend.title = element_text(size = 16),  # Adjust legend title size
              legend.text = element_text(size = 16)) +  # Adjust legend text size
        labs(title = " ", fill = "Race")  # Adding title and legend title
    }, height = 600, width = 900)

    ###PCA###

 class1_colors <- c("A" = "limegreen", "B" = "deepskyblue2", "C" = "orange", "D" = "firebrick1")

    output$pca_plot <- renderPlot({
     pca <-  clean_screen %>%
        filter(approx_loc %in% input$loc) %>%
        select(where(is.numeric)) %>%
        prcomp(scale = TRUE)
      autoplot(pca,
             data = clean_screen %>%
               filter(approx_loc %in% input$loc),
             color = "class1",
             loadings = TRUE,
             loadings.label = TRUE,
             loadings.colour = "black",
             loadings.label.colour = "black",
             loadings.label.vjust = -0.5)+
      scale_color_manual(values = class1_colors) +
      labs(color = "Redlining Category") +
      theme_minimal()+
        theme(legend.text = element_text(size = 14),
              legend.title = element_text(size = 14))
  }, height = 600, width = 900) ### end pca_plot output

  } ### end server

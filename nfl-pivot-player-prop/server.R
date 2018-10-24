library(shiny)

shinyServer(function(input, output) {
    
    dat_table <- reactive({
        # get user selected table
        df <- get(input$select_table)
        
        if (input$select_table == "player_games") {
            df <- player_games %>%
                mutate(
                    # this function gets the week numbers
                    week = sapply(date, function(x) {
                        calendar$label[x >= calendar$startDate & x <= calendar$endDate]
                        })
                    ) %>%
                # filter(Team %in% c("ATL","LA")) %>%
                select(game.id, week, Team, name, starts_with("pass"), starts_with("rush"), starts_with("rec")) %>%
                select(-contains("two")) %>%
                filter(rowSums(select(., starts_with("rec"), starts_with("rush"), starts_with("pass"))) > 0)
            }
        
        m.df <- melt(df, id.vars = 1:4)
        colnames(m.df) <- colnames(m.df) %>% tolower()
        m.df
        })
    
    dat <- reactive({ 
        gd <- dat_table() %>%
            filter(value>1) %>%
            filter(!str_detect(variable, "lng")) %>%
            filter(!str_detect(variable, "fumbs")) %>%
            filter(!str_detect(variable, "two"))
        
        if(input$select_table=="player_games"){
            
           gd <- gd %>% filter(str_detect(variable, input$prop)) 
        }
        
        gd
        
    })
    
    output$pivot <- renderRpivotTable({
        
        dat() %>% 
            #filter(team=="ATL")%>%
        rpivotTable(.,rows=c("team", "name"), cols=c("variable"),
                    #vals = "Freq",
                    #aggregatorName = "Sum",
                    
                    aggregators = list(Sum = htmlwidgets::JS('$.pivotUtilities.aggregators["Integer Sum"]'),
                                       Count = htmlwidgets::JS('$.pivotUtilities.aggregators["Count"]'),
                                       Average = htmlwidgets::JS('$.pivotUtilities.aggregators["Average"]')),
                    rendererName = "Table",
                    vals="value",
                    width="100%", height="800px")
        
        
    })
})

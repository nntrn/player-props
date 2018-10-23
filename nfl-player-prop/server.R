library(shiny)
library(FSA)

shinyServer(function(input, output) {
    
    
    game_data <- reactive({ 
        gd <- boxscore %>%
            filter(team %in% input$select_team) %>%
            # left join for the date column only 
            left_join(season_games[c("GameID", "date")], by = c("games_id" = "GameID")) %>%
            mutate(
                # this function gets the week numbers
                week = sapply(date, function(x) {
                    calendar$label[x >= calendar$startDate & x <= calendar$endDate]
                })
                ) %>%
            select(week, date, field, team, opp, everything())
        
    })
    
    
    player_data <- reactive({
        pd <- player_games %>%
            filter(Team %in% input$select_team) %>%
            mutate(
                # tds is rush td + rec td
                tds = rowSums(select(., ends_with("tds"))),
                week = sapply(date, function(x) {
                    calendar$label[x >= calendar$startDate & x <= calendar$endDate]
                })
            ) %>%
            left_join(boxscore[c("games_id", "team", "opp")], 
                      by = c("game.id" = "games_id", "Team" = "team")) %>%
            select(-c(game.id, playerID)) 
        
        
    })
    
    
    output$games <- DT::renderDataTable({
        gd2 <- game_data() %>%
            select(-c(date, games_id,field)) %>%
            rename(total = team_total, both = total) %>%
            arrange(team, week)
        
        gd2[is.na(gd2)] <- 0
        
        
        sketch <- htmltools::withTags(table(
          thead(
            tr(
              id = "first-row",
              th(colspan = ncol(gd2) - 10, ""),
              th(colspan = 5, class = "box", "quarter"),
              th(colspan = 2, class = "box", "score"),
              th(colspan = 3, class = "box", "scoring type")
            ),
            tr(lapply(names(gd2), th))
          )
        ))
        print(sketch)
        
        
        DT::datatable( # use drop = FALSE to preserve the original dimensions
            gd2[, drop = FALSE, ],
            rownames = FALSE,
            container = sketch,
            class = "cell-border compact",
            extensions = "Scroller",
            options = list(
                dom = "t",
                scrollY = 250,
                scrollX = TRUE,
                scroller = TRUE
            )
        ) %>%
            formatStyle(c("Q1", "Q2", "Q3", "Q4", "Q5"), 
                        backgroundColor = styleInterval(0, c("#fff", "#f0f1f4")))
    })
    
    
    
        output$summary <- renderPrint({
          statsum <- game_data() %>% rename(TT=team_total)
          
          do.call("rbind", as.list(
              by(statsum, list(team = statsum$team), function(x) {
                  y <- subset(x, select = Q1:total)
                  apply(y, 2, input$agg) %>% round(1)
            
                  })
              ))
        })


        output$pass_summary <- renderPrint({
          players <- player_data() %>%
            select(week, team = Team, opp, name, starts_with("pass")) %>%
            select(-contains("two")) %>%
            filter(pass.att > 0) %>%
            arrange(team, name, week)
        
          colnames(players) <- gsub("(pass\\.|pass)", "", colnames(players))
        
          do.call("rbind", as.list(
            by(players, list(team = players$name), function(x) {
              y <- subset(x, select = att:ints)
              apply(y, 2, input$agg) %>% round(1)
            })
          ))
        })
        
        output$rush_summary <- renderPrint({
            players <- player_data() %>%
                select(week, team = Team, opp, name, starts_with("rush")) %>%
                select(-contains("two")) %>%
                filter(rush.att > 0) %>%
                arrange(team, name, week)
            
            colnames(players) <- gsub("(rush\\.|rush)", "", colnames(players))
            
            do.call("rbind", as.list(
                by(players, list(team = players$name), function(x) {
                    y <- subset(x, select = att:tds)
                    apply(y, 2, input$agg) %>% round(0)
                })
            ))
        })
        
        output$rec_summary <- renderPrint({
            players <- player_data() %>%
                select(week, team = Team, opp, name, starts_with("rec")) %>%
                select(-contains("two"), -contains("lng")) %>%
                filter(recept>0|recyds>0) %>%
                arrange(team, name, week) %>%
                select(team, recept, yds=recyds, tds=rec.tds, fumbs=recfumbs,everything())
            
            do.call("rbind", as.list(
                by(players, list(team = players$name), function(x) {
                    y <- subset(x, select = recept:tds)
                    apply(y, 2, input$agg) %>% round(0)
                })
            ))
        })
        
        
    # this is the output for quarterbacks 
    # filter for pass data 
    output$players <- DT::renderDataTable({
        pass_df <- player_data() %>%
            select(week, team = Team, opp, name, starts_with(input$prop), tds
                   #starts_with("rec"),starts_with("rush")
                   ) %>%
            select(-contains("two")) %>%
            select(everything(),tds) %>%
            arrange(team, name, week)
        
        if(input$prop=="pass"){
            pass_df <- pass_df %>% subset(pass.att>0) %>%
                mutate(tds=tds-pass.tds)
        }
        if(input$prop=="rush"){
            pass_df <- pass_df %>% subset(rush.att>0)
        }
        if(input$prop=="rec"){
            pass_df <- pass_df %>% subset(recept>0|recyds>0)
        }
        
        
        
        DT::datatable( # use drop = FALSE to preserve the original dimensions
            pass_df[, drop = FALSE, ],
            rownames = FALSE,
            class = "cell-border compact",
            extensions = "Responsive",
            options = list(
                pageLength = 50
            )

        )
    }) 
    
    
    
    
    
})


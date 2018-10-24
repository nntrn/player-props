library(shiny)


fluidPage(
    title = "rpivotTable: player props | @nntrn",
    
    tags$head(
        tags$meta(name="description", content="view player prop data for 2018 nfl games"),
        tags$meta(name="keywords", content="nfl, player prop, betting, 2018"),
        tags$link(rel = "shortcut icon", href = "favicon.png"),
        tags$link(rel = "stylesheet", type = "text/css", href = "normalize.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "pivot-css.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    
    
    fluidRow(column(12,
                    titlePanel("rpivotTable: player prop"),
                    radioButtons("select_table", "table:", c("player_games", "boxscore"), selected = "player_games", inline=TRUE),
                    radioButtons("prop", "prop type:", c("pass", "rush","rec"), selected = "rec", inline=TRUE),
                    rpivotTableOutput("pivot")
                    )
             )
    )


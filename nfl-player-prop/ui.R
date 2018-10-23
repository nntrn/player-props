
fluidPage(
  title = "nfl player props | @nntrn",

  tags$head(
      tags$meta(name="description", content="view player prop data for 2018 nfl games"),
      tags$meta(name="keywords", content="nfl, player prop, betting, 2018"),
      tags$link(rel = "shortcut icon", href = "favicon.png"),
      tags$link(rel = "stylesheet", type = "text/css", href = "normalize.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
      ),

  
  fluidRow(
      column(12, 
             titlePanel("(another) nfl player prop"),
             a("nntrn.me", href = "http://nntrn.me"),
             p(a("github", href = "https://github.com/nntrn/player-props/tree/master/nfl-player-prop")),
             hr(),
             selectInput("select_team", "team (select multiple)", 
                         choices = sort(unique(boxscore$team)), 
                         multiple = TRUE, selected = c("LA")),
             DT::dataTableOutput("games")
             )
      ),

    column(9,
           fluidRow(
               radioButtons("prop", "prop type:", c("pass", "rush","rec"), selected = "rec", inline=TRUE),
               DT::dataTableOutput("players")
               )
           ),
    
    column(3,
         fluidRow(
             radioButtons("agg", "aggregate:", c("sum", "mean","min", "max"), selected = "sum", inline=TRUE),
             verbatimTextOutput("summary"),
             h4("passing"), verbatimTextOutput("pass_summary"),
             h4("rushing"), verbatimTextOutput("rush_summary"),
             h4("receiving"), verbatimTextOutput("rec_summary")
             ) 
         ) 
  
)








fluidPage(
  title = "nfl player props | @nntrn",

  tags$head(
      tags$link(rel = "shortcut icon", href = "favicon.png"),
        
      tags$link(rel = "stylesheet", type = "text/css", href = "normalize.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
      ),

  
  helpText(a("nntrn.me", href = "http://nntrn.me")),
  
  
  fluidRow(
      column(12, 
             titlePanel("(another) nfl player prop"),
             selectInput("select_team", "team (select multiple)", 
                         choices = sort(unique(boxscore$team)), 
                         multiple = TRUE, selected = c("LA", "KC")),
             DT::dataTableOutput("games")
             )
      ),

    column(9,
           fluidRow(
               radioButtons("prop", "prop type:", c("pass", "rush","rec"), selected="rec", inline=TRUE),
               DT::dataTableOutput("players")
               )
           ),
    
    column(3,
         fluidRow(
             radioButtons("agg", "aggregate:", c("sum", "mean","min", "max"), selected="sum", inline=TRUE),
             verbatimTextOutput("summary"),
             h4("passing"), verbatimTextOutput("pass_summary"),
             h4("rushing"), verbatimTextOutput("rush_summary"),
             h4("receiving"), verbatimTextOutput("rec_summary")
             ) #fluidRow
         ) #column
  
)







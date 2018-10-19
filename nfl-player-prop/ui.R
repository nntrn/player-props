
fixedPage(
  title = "nfl player props | @nntrn",

  tags$head(
      tags$link(rel = "shortcut icon", href = "favicon.png"),
        
      tags$link(rel = "stylesheet", type = "text/css", href = "normalize.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
      ),

  
  helpText(a("nntrn.me", href = "http://nntrn.me")),
  
  
  fixedRow(
      column(12, titlePanel("(another) nfl player prop"))
      ),

    
    fixedRow(
        column(12, 
               DT::dataTableOutput("games"),
               column(4,
                      selectInput("select_team", "team (select multiple)", 
                                  choices = sort(unique(boxscore$team)), 
                                  multiple = TRUE, selected = c("LA", "KC")),
                      radioButtons("prop", "prop type:", c("pass", "rush","rec"), selected="pass", inline=TRUE)
                      ),
               
               
               column(4, verbatimTextOutput("summary")),
               DT::dataTableOutput("players")
        )),
  
  fixedRow(
      column(12,
             column(12,radioButtons("agg", "aggregate:", c("sum", "mean","min", "max"),selected="sum", inline=TRUE)),
             column(4, h4("passing"), verbatimTextOutput("pass_summary")),
             column(4, h4("rushing"), verbatimTextOutput("rush_summary")),
             column(4,  h4("receiving"), verbatimTextOutput("rec_summary"))
          )
     
  )
)







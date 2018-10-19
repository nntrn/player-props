getCalendar <- function(){
    espn <- fromJSON("http://cdn.espn.com/core/nfl/scoreboard?xhr=1&render=true&device=desktop&country=us&lang=en&region=us&site=espn&edition-host=espn.com&site-type=full")
    
    calendar <-
        espn$content$sbData$leagues$calendar[[1]][1]$entries[[2]] %>%
        mutate(
            endDate = as.Date(endDate)-1,
            startDate = as.Date(startDate)
        ) %>%
        select(label, startDate, endDate)
    
    calendar
    
}
calendar <- getCalendar()
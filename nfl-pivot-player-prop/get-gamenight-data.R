library(nflscrapR)
library(tidyverse)

# Setting Up -------------------------------------------------------------------

options(stringsAsFactors = FALSE)
Sys.setenv(TZ = "America/Chicago")
options(width = 160)

#enable pretty printing for data frames with knitr's kable in R 
library(lemon)
knit_print.data.frame <- lemon_print

# set up ggplot2 theme
my_theme <- theme_bw() +
    theme( legend.position = "bottom",
           axis.text.x = element_text(colour = "grey20", size = 10, face = "bold"),
           axis.text.y = element_text(colour = "grey20", size = 10, face = "bold"))
theme_set(my_theme)
#scale_color_brewer(palette="Set1")


# Function ---------------------------------------------------------------------

uniqueCol <- function(mydf){
    mydf[vapply(mydf, function(x) length(unique(x)) > 1, logical(1L))]
}

auto <- function(x) {
    x %>% 
        mutate_all( funs(replace(., is.na(.), "")) ) %>%
        na.omit() %>%
        uniqueCol() %>%
        data.frame() %>%
        print() 
}

base <- "https://raw.githubusercontent.com/nntrn/player-props/master/nfl-player-prop/data/"

getWeek = function(dt){
    calendar <- read_csv(paste0(base,"calendar.csv"))
    sapply(dt, function(x) {
        y = calendar$label[x >= calendar$startDate & x <= calendar$endDate]
        # sprintf("wk%02d", as.integer(gsub("Week ", "", y )) ) 
        y = as.integer(gsub("Week ", "", y ))
    })
}

add_color = function(x){
    if(missing(x)){ x = "Set1" }
    require(RColorBrewer)
    scale_color_brewer(palette=x)
}

# getWeek("2018-09-06")


# Data -------------------------------------------------------------------------

pbp_2018 <- season_play_by_play(2018)
season_games <- season_games(2018)


# USER INPUT -------------------------------------------------------------------
# make sure to update the following values for the teams playing that night

team1 <- "MIN"
team2 <- "SEA"

c(team1,team2) %in% unique(teams$posteam)

teams <- 
    pbp_2018 %>% 
    filter(posteam == team1| posteam == team2) %>%
    mutate(week.val = getWeek(Date),
           week = sprintf("wk%02d", week.val)
           )

# PASS -------------------------------------------------------------------------

# show quarterbacks for both teams
teams %>%
    group_by(Passer, week) %>%
    summarise(n=n()) %>%
    filter(n > 1) %>%
    spread(week, n) %>%
    auto()

## get attempts, completes, incompletes 
pass_outcomes <-
    teams %>%
    filter(PassAttempt == 1) %>%
    select(week, qtr, Passer, PassOutcome, Receiver) %>%
    group_by(week, Passer, PassOutcome) %>%
    summarise(n = n()) %>% spread(PassOutcome, n) %>%
    mutate(Attempts = Complete + `Incomplete Pass`)

## Show Completion / Attempts
pass_outcomes %>%
    unite_("Complete_Attempts", c("Complete", "Attempts"),sep = "/") %>%
    select(-contains("Incomplete")) %>%
    spread(Passer, Complete_Attempts) %>%
    mutate_all( funs(replace(., is.na(.), '')) ) %>% 
    auto() 

# ggpplot for pass outcome 
pass_outcomes %>%
    group_by(Passer, week) %>%
    arrange(Passer) %>%
    select(-contains("Incomplete")) %>%
    print() %>%
    # PLOT ---------------------
    ggplot(aes(Complete, Attempts, color = Passer, label = week)) +
    geom_vline(xintercept = 30, color = "black") +
    geom_point(alpha=.4) +
    geom_text(size=3, vjust=-1.15) + 
    add_color()
    
pass_outcomes %>% 
    ggplot(aes(Attempts, Complete, color = Passer, label=week) ) +
    geom_boxplot() +
    geom_point(alpha = .4) +
    facet_wrap(Passer ~ .) + 
    add_color()

# TOUCHDOWNS -------------------------------------------------------------------
# note: we do not care if the touchdown play was reversed 

tds <- teams %>% 
    filter(Touchdown == "1") %>%
    mutate(scorer = ifelse(is.na(Receiver), Rusher, Receiver),
           scorer = ifelse(is.na(Rusher), Receiver, Rusher),
           week = getWeek(Date))

# sum of touchdowns per quarter
table(tds$qtr)

tds %>% 
    group_by(scorer, qtr) %>%
    summarise(n=n()) %>%
    spread(qtr, n) %>%
    auto()
    table()

## print rec (pass) + rush (run) touchdowns
tds %>%
    select(scorer, PlayType, qtr) %>%
    na.omit(scorer) %>%
    group_by(qtr, scorer, PlayType) %>%
    summarise(n=n()) %>%
    spread(PlayType, n) %>%
    mutate_all(funs(replace(., is.na(.), F)) ) %>%
    mutate(total = Pass + Run) %>%
    arrange(qtr, desc(total)) %>%
    mutate_all(funs(replace(., . == 0, '')) ) %>%
    auto()

# expanded table showing touchdowns made by qtr
# PASS_RUN
tds %>%
    select(week, desc, qtr, scorer, PlayType) %>%
    na.omit(scorer) %>%
    group_by(week, scorer,qtr,  PlayType) %>%
    summarise(n=n()) %>%
    spread(PlayType, n) %>%
    mutate_all(funs(replace(., is.na(.), F)) ) %>%
    unite_("Pass_Run", c("Pass", "Run"),sep = "_") %>%
    spread(week, Pass_Run) %>%
    arrange(qtr) %>% 
    auto() %>% 
    View()

# RECEPTION COUNT  -------------------------------------------------------------

## show TD count by quarter
table(tds$Receiver, tds$qtr)
table( tds$Rusher, tds$qtr)



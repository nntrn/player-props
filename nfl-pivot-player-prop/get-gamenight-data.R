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
my_theme <- theme_gray() +
    theme(
        axis.text.x = element_text(colour = "grey20", size = 10, face = "bold"),
        axis.text.y = element_text(colour = "grey20", size = 10, face = "bold"),
    ) + theme(legend.position="bottom")

theme_set(my_theme)

# note: we do not care if the touchdown play was reversed 


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
calendar <- read.csv(text=getURL(paste0(base,"calendar.csv")))

#calendar$week = sprintf("wk %02d", as.integer(gsub("Week ", "", calendar$label)) ) 

getWeek = function(dt){
    sapply(dt, function(x) {
        # return week   format: wk.00
        y = calendar$label[x >= calendar$startDate & x <= calendar$endDate]
        sprintf("wk.%02d", as.integer(gsub("Week ", "", y )) ) 
    })
    
}

#getWeek("2018-09-06")


# USER INPUT -------------------------------------------------------------------
# make sure to update the following values for the teams playing that night

team1 <- "JAX"
team2 <- "TEN"

# Data -------------------------------------------------------------------------

pbp_2018 <- season_play_by_play(2018)
season_games <- season_games(2018)

teams <- 
    pbp_2018 %>% 
    filter(posteam == team1| posteam == team2) %>%
    mutate( week = getWeek(Date) )

# PASS -------------------------------------------------------------------------

# show quarterbacks for both teams
teams %>%
    group_by(Passer) %>%
    summarise(n=n()) %>%
    filter(n > 1) %>%
    auto()

## get attempts, completes, incompletes 
pass_outcomes <-
    teams %>%
    filter(PassAttempt == 1) %>%
    select(week, qtr, Passer, PassOutcome, Receiver) %>%
    group_by(week, Passer, PassOutcome) %>%
    summarise(n = n()) %>% spread(PassOutcome, n) %>%
    mutate(Attempts = Complete + `Incomplete Pass`) %>%
    auto()


x %>% 
    mutate(total = rowSums( .[ sapply(., is.numeric)] )) %>%
    #filter(total > 0) %>%
    arrange(desc(total)) %>%
    #auto() %>%
    View()

## Show Completion / Attempts
pass_outcomes %>%
    unite_("Complete_Attempts", c("Complete", "Attempts"),sep = "/") %>%
    select(-contains("Incomplete")) %>%
    spread(week, Complete_Attempts) %>%
    mutate_all( funs(replace(., is.na(.), '')) ) %>% 
    auto() %>%
    View()


# ggpplot for pass outcome 
teams %>%
    group_by(Date, Passer, PassOutcome) %>%
    summarise(contains("Complete")) %>%
    filter(n > 1, !is.na(Passer)) %>%
    spread(PassOutcome, n) %>%
    arrange(Passer) %>%
    mutate(
        Attempts = Complete + `Incomplete Pass`,
        week = getWeek(Date) 
        ) %>%
    select(-`Incomplete Pass`) %>%
    print() %>%
   # auto() %>%
    # PLOT ---------------------
    ggplot(aes(week, Attempts, color = Passer, label = Passer)) +
    geom_hline(yintercept = 30, color = "black") +
    geom_point(alpha=.4) +
    geom_text(size=3) 
    


# TOUCHDOWNS -------------------------------------------------------------------
tds <- teams %>% 
    filter(Touchdown == "1") %>%
    mutate(scorer = ifelse(is.na(Receiver), Rusher, Receiver),
           scorer = ifelse(is.na(Rusher), Receiver, Rusher),
           week = getWeek(Date))

# sum of touchdowns per quarter
table(tds$qtr)

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
table(dat$Receiver, dat$qtr)
table( dat$Rusher, dat$qtr)



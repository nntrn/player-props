library(dplyr)
library(jsonlite)
library(shiny)
require(RCurl)
library(reshape)
library(htmlwidgets)
library(rpivotTable)

options(stringsAsFactors = FALSE)
Sys.setenv(TZ = "America/Chicago")
options(width = 160)

base <- "https://raw.githubusercontent.com/nntrn/player-props/master/nfl-player-prop/data/"

boxscore <- read.csv(text=getURL(paste0(base,"boxscore.csv")))
calendar <- read.csv(text=getURL(paste0(base,"calendar.csv")))
player_games <- read.csv(text=getURL(paste0(base,"player_games.csv")))
season_games <- read.csv(text=getURL(paste0(base,"season_games.csv")))


# test <- player_games %>% 
#     mutate(
#         # this function gets the week numbers
#         week = sapply(date, function(x) {calendar$label[x >= calendar$startDate & x <= calendar$endDate] })) %>%
#     #filter(Team %in% c("ATL","LA")) %>% 
#     select(game.id, week, Team, name, starts_with("pass"), starts_with("rush"), starts_with("rec")) %>% 
#     select(-contains("two")) %>% 
#     filter(rowSums(select(., starts_with("rec"),starts_with("rush"), starts_with("pass"))) > 1) 
#     #arrange(name, date) %>%
#    
# 
# # {id.vars = 1:4} = game.id, date, Team, name
# m.test = melt(test, id.vars = 1:4)
# #cast(m.test, Team + name ~ variable,sum)

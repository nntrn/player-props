library(tinytex)
library(nflscrapR)
library(XML)
library(dplyr)
library(jsonlite)
library(tidyverse)
library(tibble)
library(tidyr)
library(tidytext)
library(DT)
library(shiny)
library(htmltools)
library(psych)

options(stringsAsFactors = FALSE)
Sys.setenv(TZ = "America/Chicago")
options(width = 160)


# get game_ids from nflscrapR
g_id <- extracting_gameids(2018, playoffs = FALSE)


boxscore <- read_csv("./data/boxscore.csv")
calendar <- read_csv("./data/calendar.csv")
player_games <- read_csv("./data/player_games.csv")
season_games <- read_csv("./data/season_games.csv")


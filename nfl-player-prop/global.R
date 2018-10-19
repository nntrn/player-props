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


boxscore <- read_csv("./nfl-player-prop/data/boxscore.csv")
calendar <- read_csv("./nfl-player-prop/data/calendar.csv")
player_games <- read_csv("./nfl-player-prop/data/player_games.csv")
season_games <- read_csv("./nfl-player-prop/data/season_games.csv")


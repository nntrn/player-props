# library(tinytex)
library(nflscrapR)
library(RCurl)
library(XML)
library(jsonlite)
library(tidytext)
library(DT)
library(shiny)
library(tidyverse)
#library(htmltools)
#library(psych)

options(stringsAsFactors = FALSE)
Sys.setenv(TZ = "America/Chicago")
options(width = 160)


## getGames() ====================

getGames <- function(gameid) {
    
    base <- "http://www.nfl.com/liveupdate/game-center/"
    urlBuilder <- paste0(base, gameid, "/", gameid, "_gtd.json")
    
    dat <- fromJSON(urlBuilder)
    
    scoring_count <-
        dat[[1]][[4]] %>%
        sapply("[") %>%
        t() %>%
        data.frame() %>%
        select(qtr, team, type) %>%
        # sapply(as.character) converts the list column into single values
        sapply(as.character) %>%
        data.frame() %>%
        group_by(team) %>%
        summarise(
            FG = sum(type == "FG"), #field-goal
            SAF = sum(type == "SAF"), #safety
            TD = sum(type == "TD") #touchdown
        )
    
    games_by_id <- list()
    
    for (i in 1:2) {
        # 1 is for home 
        # 2 is for away 
        games_by_id[[i]] <-
            bind_cols(
                games_id = gameid,
                team = dat[[1]][[i]]$abbr,
                dat[[1]][[i]]$score %>% data.frame()
            ) %>%
            data.frame() %>%
            mutate(
                opp = ifelse(i == 1, paste0("@", dat[[1]][[2]]$abbr), dat[[1]][[1]]$abbr),
                field = ifelse(i == 1, "H", "A"),
                result = "Tie",
                result = case_when(
                    dat[[1]][[i]]$score$T / (dat[[1]][[1]]$score$T + dat[[1]][[2]]$score$T) > .5 ~ "W",
                    dat[[1]][[i]]$score$T / (dat[[1]][[1]]$score$T + dat[[1]][[2]]$score$T) < .5 ~ "L",
                    dat[[1]][[1]]$score$T == dat[[1]][[2]]$score$T ~ "Tie"
                ),
                total = dat[[1]][[1]]$score$T + dat[[1]][[2]]$score$T
            ) %>%
            # rename quarter names 
            rename(Q1 = X1, Q2 = X2, Q3 = X3, Q4 = X4, Q5 = X5, team_total = T) %>%
            select(games_id, team, field, opp, result, everything()) %>%
            left_join(scoring_count, by = "team")
    }
    games <- bind_rows(games_by_id)
}


## boxscore + player_games ====================

# get game_ids from nflscrapR
g_id <- extracting_gameids(2018, playoffs = FALSE)

remove_gid <- format(Sys.Date(), "%Y%m%d00")

g_id <- g_id %>%
    subset(remove_gid != g_id) %>%
    unique()


bs <- list()
pg <- list()

for (i in seq(along = g_id)) {
    bs[[i]] <- getGames(g_id[i]) 
    pg[[i]] <- player_game(g_id[i]) 
}

boxscore <- bind_rows(bs)
player_games <- bind_rows(pg)

rm(bs,pg)


season_games <- season_games(2018)


#write.csv(calendar, file = "./data/calendar.csv",row.names = FALSE)
write.csv(boxscore, file = "nfl-player-prop/data/boxscore.csv",row.names = FALSE)
write.csv(player_games, file = "nfl-player-prop/data/player_games.csv",row.names = FALSE)    
write.csv(season_games, file = "nfl-player-prop/data/season_games.csv",row.names = FALSE)   


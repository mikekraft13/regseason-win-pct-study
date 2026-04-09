# Loading libraries
source(here::here("r","Libraries.R"))

# If the raw data needs to be loaded back in ####
read_raw_savant_rds_data <- T
if(read_raw_savant_rds_data){source(here::here('r', 'Load-RDS-Files.R'))}

# Cleaning dataframes by year, dropping unnecessary columns ####

df_list <- list(savant_pbp2014, savant_pbp2015, savant_pbp2016, savant_pbp2017, savant_pbp2018,
                savant_pbp2019, savant_pbp2020, savant_pbp2021, savant_pbp2022, savant_pbp2023,
                savant_pbp2024, savant_pbp2025)


## Cleaning individual datasets ####

filtered_dfs <- map(df_list, ~ .x |>
                      filter(!is.na(pitch_type) & pitch_type != '') |>
                      select(-any_of(c("spin_rate_deprecated", "break_angle_deprecated", "break_length_deprecated", "game_type",
                                       "game_year", "tfs_deprecated", "tfs_zulu_deprecated", "umpire", "sv_id", "vx0", "vy0", "vz0", 
                                       "ax", "ay", "az", "fielder2", "fielder3", "fielder4", "fielder5", "fielder6", "fielder7","fielder8",
                                       "fielder9", "if_fielding_alignment", "of_fielding_alignment", "bat_speed", "swing_length",
                                       "delta_pitcher_run_exp", "hyper_speed", "home_score_diff", "bat_score_diff", "home_win_exp",
                                       "bat_win_exp", "age_pit_legacy", "age_bat_legacy", "n_priorpa_thisgame_player_at_bat",
                                       "pitcher_days_since_prev_game", "batter_days_since_prev_game", "pitcher_days_until_next_game",
                                       "batter_days_until_next_game"))))

# Temp code for only cleaning a single data frame, and not a list of data frames
savant_pbp2025 <- savant_pbp2025 |>
  filter(!is.na(pitch_type) & pitch_type != '') |>
  select(-any_of(c("spin_rate_deprecated", "break_angle_deprecated", "break_length_deprecated", "game_type",
                   "game_year", "tfs_deprecated", "tfs_zulu_deprecated", "umpire", "sv_id", "vx0", "vy0", "vz0", 
                   "ax", "ay", "az", "fielder2", "fielder3", "fielder4", "fielder5", "fielder6", "fielder7","fielder8",
                   "fielder9", "if_fielding_alignment", "of_fielding_alignment", "bat_speed", "swing_length",
                   "delta_pitcher_run_exp", "hyper_speed", "home_score_diff", "bat_score_diff", "home_win_exp",
                   "bat_win_exp", "age_pit_legacy", "age_bat_legacy", "n_priorpa_thisgame_player_at_bat",
                   "pitcher_days_since_prev_game", "batter_days_since_prev_game", "pitcher_days_until_next_game",
                   "batter_days_until_next_game")))

savant_pbp2023 <- savant_pbp2023 |>
  filter(!is.na(pitch_type) & pitch_type != '') |>
  select(-any_of(c("spin_rate_deprecated", "break_angle_deprecated", "break_length_deprecated", "game_type",
                   "game_year", "tfs_deprecated", "tfs_zulu_deprecated", "umpire", "sv_id", "vx0", "vy0", "vz0", 
                   "ax", "ay", "az", "fielder2", "fielder3", "fielder4", "fielder5", "fielder6", "fielder7","fielder8",
                   "fielder9", "if_fielding_alignment", "of_fielding_alignment", "bat_speed", "swing_length",
                   "delta_pitcher_run_exp", "hyper_speed", "home_score_diff", "bat_score_diff", "home_win_exp",
                   "bat_win_exp", "age_pit_legacy", "age_bat_legacy", "n_priorpa_thisgame_player_at_bat",
                   "pitcher_days_since_prev_game", "batter_days_since_prev_game", "pitcher_days_until_next_game",
                   "batter_days_until_next_game")))
         

## Binding the cleaned datasets ####
filtered_dfs_binded <- bind_rows(filtered_dfs)

## Saving the above filtered datasets as RDS files to clean up environment ####

rds_files_need_update <- F
if(rds_files_need_update == T){
  saveRDS(filtered_dfs_binded, here::here('data', 'filtered_dfs_binded.rds'))
}


# IF YOU HAVE ALREADY RAN THE ABOVE CODE AND ONLY WANT TO HAVE filtered_dfs_binded IN THE ENVIRONMENT ####
filtered_dfs_binded <- read_rds(here::here('data', 'filtered_dfs_binded.rds'))
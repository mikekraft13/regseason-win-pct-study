library(tidyverse)
library(baseballr)
library(httr)

# Line to create temp directory
dir.create('data/temp', recursive = T, showWarnings = T)

# Set variables for the season to scrape and the start and end date for that season
season <- 2025
season_start_date <- '2025-03-18'
season_end_date <- '2025-09-28'

# Create an array of dates from the first to last day of the season
season_dates <- seq.Date(as.Date(season_start_date), as.Date(season_end_date), by = 'day')


# Function to grab CSV pitch-by-pitch data from baseball savant and save them into temporary files
getStatcastPitchByPitch <- function(date_in, date_out) {
  url <- paste0('https://baseballsavant.mlb.com/statcast_search/csv?all=true&hfPT=&hfAB=&hfBBT=&hfPR=&hfZ=&stadium=&hfBBL=&hfNewZones=&hfGT=R%7CPO%7CS%7C&hfC&hfSea=', season, '%7C&hfSit=&hfOuts=&opponent=&pitcher_throws=&batter_stands=&hfSA=&player_type=batter&hfInfield=&team=&position=&hfOutfield=&hfRO=&home_road=&game_date_gt=', date_in, '&game_date_lt=', date_out, '&hfFlag=&hfPull=&metric_1=&hfInn=&min_pitches=0&min_results=0&group_by=name&sort_col=pitches&player_event_sort=h_launch_speed&sort_order=desc&min_abs=0&type=details')
  download.file(url, destfile = paste0('data/temp/temp-savant-', date_in, '-', date_out, '.csv'), mode = "wb")
}

# Loop through the array of dates and use the function to download pitch-by-pitch data in three data increments
lapply(1:(length(season_dates) / 3), function(i) {
  getStatcastPitchByPitch(season_dates[i * 3 - 2], season_dates[i * 3])
})

# Read in all of the downloaded temp files and combine them into one data.frame, filtered by regular season only
savant_pitch_by_pitch <- lapply(list.files(path = 'data/temp', pattern = "^temp.*\\.csv$", full.names = TRUE), function(i) {
  read.csv(i)
}) %>%
  bind_rows() %>%
  filter(game_type == 'R')

# Get new savant data
new_savant <- lapply(list.files(path = 'data/temp', pattern = "^temp.*\\.csv$", full.names = T), function(i) {
  df <- tryCatch(
    read_csv(i, locale = locale(encoding = 'UTF-8'), skip_empty_rows = TRUE, col_names = TRUE),
    error = function(e) {
      message(paste('Error reading:', i, '->', e$message))
      return(tibble())
    }
  )
  if (nrow(df) > 0) {
    common_cols <- intersect(names(df), names(savant_pitch_by_pitch))
    df <- df %>% mutate(across(all_of(common_cols), ~ {
      ref_type <- class(savant_pitch_by_pitch[[cur_column()]])[1]
      if (ref_type == 'numeric') {
        as.numeric(.)
      } else if (ref_type == 'integer') {
        as.integer(.)
      } else if (ref_type == 'character') {
        as.character(.)
      } else {
        .
      }
    }))
    
    return(df)
  } else {
    return(tibble())
  }
}) %>%
  bind_rows()

# Filter down new savant
if (nrow(new_savant) > 0) {
  new_savant <- new_savant %>%
    filter(game_type == 'R') %>%
    mutate(
      across(any_of(names(savant_pitch_by_pitch)), ~ {
        ref_type <- class(savant_pitch_by_pitch[[cur_column()]])[1]
        if (ref_type == 'numeric') {
          as.numeric(.)
        } else if (ref_type == 'character') {
          as.character(.)
        } else if (ref_type == 'integer') {
          as.integer(.)
        } else {
          .
        }
      }, .names = '{.col}')
    )
}

# Save the data.frame of pitches for the season into an RDS file labeled by the season
# qs::qsave(new_savant, 'rds/savant_pbp2025.qs', preset = 'high')
saveRDS(new_savant, 'rds/savant_pbp2025.rds')

# Delete the downloaded temp files
file.remove(list.files(path = 'data/temp', pattern = "^temp.*\\.csv$", full.names = T))

# Delete the temp folder
unlink('data/temp', recursive = T)


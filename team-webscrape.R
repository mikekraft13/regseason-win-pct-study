

years <- 2014:2025
outfile <- "mlb_team_stats_2014_2025.xlsx"

br_url <- function(year) {
  paste0("https://www.baseball-reference.com/leagues/MLB/", year, ".shtml")
}

scrape_year_br <- function(year) {
  url <- br_url(year)
  message("Downloading: ", url)
  
  page <- read_html(url)
  
  # Table id for team batting stats (BR is consistent: 'teams_standard_batting')
  table_node <- page %>% html_element("table#teams_standard_batting")
  
  if (is.na(table_node)) {
    stop("Could not find batting table for year ", year)
  }
  
  df <- table_node %>% html_table()
  
  # Remove header repeat rows
  df <- df[df$Tm != "Tm", ]
  
  # Clean numeric columns
  df_clean <- df %>%
    mutate(across(
      .cols = -Tm,
      .fns = ~ suppressWarnings(as.numeric(str_replace_all(.x, "[,%]", "")))
    ))
  
  # Rankings
  rank_df <- df_clean %>% rename(Team = Tm)
  
  for (col in names(rank_df)[names(rank_df) != "Team"]) {
    if (is.numeric(rank_df[[col]])) {
      rank_df[[paste0(col, "_rank")]] <- rank(-rank_df[[col]], ties.method = "min")
    } else {
      rank_df[[paste0(col, "_rank")]] <- NA
    }
  }
  
  rank_df
}

# Create workbook
wb <- createWorkbook()

for (yr in years) {
  df_year <- scrape_year_br(yr)
  addWorksheet(wb, sheetName = as.character(yr))
  writeData(wb, sheet = as.character(yr), df_year)
  Sys.sleep(1)
}

saveWorkbook(wb, outfile, overwrite = TRUE)
message("Saved workbook: ", outfile)

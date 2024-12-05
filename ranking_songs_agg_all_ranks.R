# Load necessary libraries
library(dplyr)
library(purrr)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)
print(args)
print(getwd())

# List all .rds files that are ranking_songs, read in, store as list
files <- list.files(pattern = "\\.rds$", full.names = TRUE)
regional_data <- map(files, readRDS) # purrr

# Merge and aggregate the data
i=args[1]
merged_data <- regional_data %>%
  reduce(full_join, by = "title_artist") %>%   # Merge all data frames by title_artist
  mutate(rank = rowSums(across(starts_with(paste0("rank_",i)), ~replace_na(., 0)))) %>%  # Sum rank
  select(title_artist, rank)  # Keep only title_artist and the aggregated rank_i
saveRDS(merged_data, file=paste0("rank_",i,"_ranking_songs.rds"))

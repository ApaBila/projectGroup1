if (require("dplyr")) {
  print("Loaded package dplyr.")
} else {
  print("Failed to load package dplyr.")  
}

if (require("tidyr")) {
  print("Loaded package tidyr.")
} else {
  print("Failed to load package tidyr.")  
}

args <- commandArgs(trailingOnly = TRUE)
print(args)
print(getwd())
country <- read.csv(paste0(args[1],".csv"))

country$title_artist <- paste(sep="\n",country$title, country$artist)

wide_df <- country %>%
  group_by(title_artist, rank) %>%              # Group by title_artist and rank
  summarise(count = n(), .groups = "drop") %>%  # Count occurrences of each rank
  pivot_wider(names_from = rank,                # Pivot rank into columns
              values_from = count, 
              names_prefix = "rank_",           # Add prefix to column names
              values_fill = list(count = 0))    # Fill missing counts with 0

print(length(wide_df))

wide_df <- wide_df[,c("title_artist","rank_1")]

saveRDS(wide_df, paste0(args[1],"_ranking_songs.rds"))
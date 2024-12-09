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

# Load data of region, read in by queue in .sub
args <- commandArgs(trailingOnly = TRUE)
print(args)
print(getwd())
country <- read.csv(paste0("by_region/", args[1], ".csv"))

# Separate individual artists from artist column, with "featuring"/multiple artists
country <- country %>%
  mutate(artist_individual = artist) %>%            # Copy artist column for manipulation
  separate_rows(artist_individual, sep = ",") %>%   # Split artists separated by commas
  mutate(artist_individual = trimws(artist_individual)) # Trim whitespace around artist names

# Create a "wide" dataframe with 1-200 rank counts of each artist
wide_df <- country %>%
  group_by(artist_individual, rank) %>%             # Group by individual artist and rank
  summarise(count = n(), .groups = "drop") %>%      # Count occurrences of each rank
  pivot_wider(
    names_from = rank,                              # Pivot rank into columns
    values_from = count,
    names_prefix = "rank_",                         # Add prefix to column names
    values_fill = list(count = 0)                   # Fill missing counts with 0
  )

print(length(wide_df))

# Keep only first rank and save. TODO: weighted rank?
wide_df <- wide_df[, c("artist_individual", "rank_1")]
saveRDS(wide_df, paste0("ranking_artists/", args[1], "_ranking_artists.rds"))

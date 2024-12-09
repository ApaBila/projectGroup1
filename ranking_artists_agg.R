library(dplyr)
library(purrr)
library(ggplot2)
library(tidyr)

# List all .rds files that are ranking_artists, read in, store as list
files <- list.files("ranking_artists/", pattern = "\\.rds$", full.names = TRUE)
files <- files[files != "ranking_artists//Global_ranking_artists.rds"]
regional_data <- map(files, readRDS)

#Barchart####
# Merge and aggregate the data
merged_data <- regional_data %>%
  reduce(full_join, by = "artist_individual") %>% # Merge all data frames
  mutate(rank_1 = rowSums(across(starts_with("rank_1"), ~replace_na(., 0)))) %>% # Sum all rank_1 columns
  select(artist_individual, rank_1) # Keep only artist and aggregated rank_1


# Filter the top 10 artists by agg rank_1 counts. Then barchart.
top_artists <- merged_data %>%
  arrange(desc(rank_1)) %>%    # Sort by rank_1 in descending order
  slice_head(n = 10)
ggplot(top_artists, aes(x = reorder(artist_individual, rank_1), y = rank_1)) + 
  geom_bar(stat = "identity", fill = "steelblue") + # Create bars
  coord_flip() + # Flip coordinates for readability
  labs(
    title = "Top 10 Artists by Rank 1 Counts (Summed)",
    x = "Artist",
    y = "Rank 1 Count"
  ) + 
  theme_minimal() +  # Apply a clean theme
  theme(
    axis.text.y = element_text(size = 16),
    plot.title = element_text(size = 32),
    axis.title.x = element_text(size = 24),
    axis.title.y = element_text(size = 24)
  )
ggsave("barchart_top10_artists.jpg", width=1024*4, height=768*3, units="px")

library(maps)
#Map 1####
# Identify the globally top-ranking artist
top_artist <- merged_data %>%
  arrange(desc(rank_1)) %>%
  slice(1) %>%
  pull(artist_individual)
# Extract data for the top-ranking artist_individual from all regions
top_artist_individual_regions <- map_dfr(files, function(file) {
  region_data <- readRDS(file)
  region_name <- gsub("_ranking_artists\\.rds$", "", basename(file))  # Extract region name
  region_top_artist <- region_data %>%
    filter(artist_individual == top_artist) %>%   # Filter for the top artist
    mutate(region = region_name)  # Add the region name
})
top_artist_individual_summary <- top_artist_individual_regions %>%
  group_by(artist_individual) %>%
  summarise(
    total_regions = n(),  # Number of regions where the artist appears
    total_rank_1 = sum(rank_1, na.rm = TRUE)  # Total rank_1 counts across regions
  )
# Prepare data for mapping (adjust region names, merge)
map_data <- top_artist_individual_regions %>%
  mutate(region = case_when(
    region == "United_States" ~ "USA",
    region == "United_Kingdom" ~ "UK",
    region == "Czech_Republic" ~ "Czech Republic",
    region == "Dominican_Republic" ~ "Dominican Republic",
    TRUE ~ gsub("_", " ", region)  # Replace underscores with spaces
  ))
world_map <- map_data("world")
map_data <- world_map %>%
  left_join(map_data, by = c("region" = "region"))
# Plot the map
ggplot(map_data, aes(long, lat, group = group)) + 
  geom_polygon(aes(fill = rank_1), color = NA) +  # Color by rank_1
  scale_fill_gradient(low = "lightblue", high = "#3a066eff", na.value = "grey80") +  # Gradient for rank_1
  labs(
    title = paste("Regional Rank 1 Counts for:", top_artist),
    fill = "Rank 1 Count"
  ) + 
  theme_minimal() + 
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(size = 32)
  )
ggsave("map_top1_artist.jpg", width=1024*4, height=768*3, units="px")



#Map 2####
# Identify the globally second-ranking artist
second_artist <- merged_data %>%
  arrange(desc(rank_1)) %>%
  slice(1) %>%
  pull(artist_individual)
# Extract data for the second-ranking artist_individual from all regions
second_artist_individual_regions <- map_dfr(files, function(file) {
  region_data <- readRDS(file)
  region_name <- gsub("_ranking_artists\\.rds$", "", basename(file))  # Extract region name
  region_second_artist <- region_data %>%
    filter(artist_individual == second_artist) %>%   # Filter for the second artist
    mutate(region = region_name)  # Add the region name
})
second_artist_individual_summary <- second_artist_individual_regions %>%
  group_by(artist_individual) %>%
  summarise(
    total_regions = n(),  # Number of regions where the artist appears
    total_rank_1 = sum(rank_1, na.rm = TRUE)  # Total rank_1 counts across regions
  )
# Prepare data for mapping (adjust region names, merge)
map_data <- second_artist_individual_regions %>%
  mutate(region = case_when(
    region == "United_States" ~ "USA",
    region == "United_Kingdom" ~ "UK",
    region == "Czech_Republic" ~ "Czech Republic",
    region == "Dominican_Republic" ~ "Dominican Republic",
    TRUE ~ gsub("_", " ", region)  # Replace underscores with spaces
  ))
world_map <- map_data("world")
map_data <- world_map %>%
  left_join(map_data, by = c("region" = "region"))
# Plot the map
ggplot(map_data, aes(long, lat, group = group)) + 
  geom_polygon(aes(fill = rank_1), color = NA) +  # Color by rank_1
  scale_fill_gradient(low = "lightblue", high = "#3a066eff", na.value = "grey80") +  # Gradient for rank_1
  labs(
    title = paste("Regional Rank 1 Counts for:", second_artist),
    fill = "Rank 1 Count"
  ) + 
  theme_minimal() + 
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(size = 32)
  )
ggsave("map_top2_artist.jpg", width=1024*4, height=768*3, units="px")
# Load necessary libraries
library(dplyr)
library(purrr)
library(ggplot2)
library(tidyr)

# List all .rds files that are ranking_songs, read in, store as list
files <- list.files(pattern = "\\.rds$", full.names = TRUE)
regional_data <- map(files, readRDS) # purrr


#Barchart####
# Merge and aggregate the data
merged_data <- regional_data %>%
  reduce(full_join, by = "title_artist") %>%   # Merge all data frames by title_artist
  mutate(rank_1 = rowSums(across(starts_with("rank_1"), ~replace_na(., 0)))) %>%  # Sum all rank_1 columns
  select(title_artist, rank_1)  # Keep only title_artist and the aggregated rank_1

# Filter the top 10 songs by agg rank_1 counts. Barchart.
top_songs <- merged_data %>%
  arrange(desc(rank_1)) %>%
  slice_head(n = 10)
ggplot(top_songs, aes(x = reorder(title_artist, rank_1), y = rank_1)) + 
  geom_bar(stat = "identity", fill = "steelblue") + # Create bars
  coord_flip() + # Flip coordinates for readability
  labs(
    title = "Top 10 Songs by Rank 1 Counts",
    x = "Title and Artist",
    y = "Rank 1 Count"
  ) + 
  theme_minimal() +  # Apply a clean theme
  theme(axis.text.y = element_text(size = 10))  # Adjust text size



#Map 1####
#TODO: maybe make this more generic - let there be arguments for how many song maps we want
# Take the number 1 hit, go back to region files but this time keep region names
top_song <- top_songs %>%
  slice(1) %>%
  pull(title_artist)
top_song_regions <- map_dfr(files, function(file) { # purr, but this time df
  region_data <- readRDS(file)
  region_name <- gsub("_ranking_songs\\.rds$", "", basename(file))  # Extract region name
  region_top_song <- region_data %>%
    filter(title_artist == top_song) %>%   # Filter for the top song
    mutate(region = region_name)  # Add the region name
})
# Second hit
second_song <- top_songs %>%
  slice(2) %>%
  pull(title_artist)
second_song_regions <- map_dfr(files, function(file) { 
  region_data <- readRDS(file)
  region_name <- gsub("_ranking_songs\\.rds$", "", basename(file))  
  region_top_song <- region_data %>%
    filter(title_artist == second_song) %>%   # Filter for second song
    mutate(region = region_name)
})
# For more EDA while we're at it: The Top Song by Region
regional_top_songs <- map_dfr(files, function(file) {
  region_data <- readRDS(file)
  region_name <- gsub("_ranking_songs\\.rds$", "", basename(file)) # Extract region name
  region_top <- region_data %>%
    filter(rank_1 == max(rank_1, na.rm = TRUE)) %>% # Select song(s) with max rank_1
    mutate(region = region_name) # Add the region name
  region_top
})
print(table(regional_top_songs$title_artist))

world_map <- map_data("world") # load ggplot's map data

# Mapping #1
# Adjust region names for second_song_regions
map_data <- top_song_regions %>%
  mutate(region = case_when(
    region == "United_States" ~ "USA",
    region == "United_Kingdom" ~ "UK",
    TRUE ~ gsub("_", " ", region)  # Replace underscores with spaces
  ))
# Merge 
map_data <- world_map %>%
  left_join(map_data, by = c("region" = "region"))
# Plot
ggplot(map_data, aes(long, lat, group = group)) + 
  geom_polygon(aes(fill = rank_1), color = "white") +  # Color by rank_1
  scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "grey80") +  # Gradient for rank_1
  labs(
    title = paste("Regional Rank 1 Counts for:", top_song),
    fill = "Rank 1 Count"
  ) + 
  theme_minimal() + 
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )



# Mapping #2
# Adjust region names for top_song_regions
map_data_2 <- second_song_regions %>%
  mutate(region = case_when(
    region == "United_States" ~ "USA",
    region == "United_Kingdom" ~ "UK",
    TRUE ~ gsub("_", " ", region)  # Replace underscores with spaces
  ))
# Merge 
map_data_2 <- world_map %>%
  left_join(map_data_2, by = c("region" = "region"))
# Plot
ggplot(map_data_2, aes(long, lat, group = group)) + 
  geom_polygon(aes(fill = rank_1), color = "white") + 
  scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "grey80") +
  labs(
    title = paste("Regional Rank 1 Counts for:", second_song),
    fill = "Rank 1 Count"
  ) + 
  theme_minimal() + 
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )


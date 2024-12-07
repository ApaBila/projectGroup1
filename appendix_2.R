library(dplyr)
library(lubridate)
library(ggplot2)

Global <- read.csv("~/madison/1_Semester/605/project/STAT605-Project-Group1/by_region/Global.csv")

# Preprocessing columns
# Create unique song identifier that has artists' name(s)
Global$title_artist <- paste(Global$title, Global$artist, sep="_")
# Make R recognize the dates
Global$date <- as.Date(Global$date)

# Get the top 7 songs with the most rank 1 occurrences
top_7_rank_1_songs <- Global %>%
  filter(rank == 1) %>%     # filter to rank 1 only
  count(title_artist) %>%   # get counts per title_artist
  arrange(desc(n)) %>%      # sort
  head(7) %>%               # get rows of top 7
  pull(title_artist)        # get title_artist only of top 7

# Filter the data for these top 7 songs and track rank changes
weekly_rank <- Global %>%
  filter(title_artist %in% top_7_rank_1_songs) %>% 
  mutate(week = floor_date(date, "week")) %>%  # Extract the start of the week
  select(title_artist, week, rank) %>%  # Keep necessary columns only
  arrange(week, rank)  # Ensure the data is ordered by week and rank

# Plot
ggplot(weekly_rank, aes(x = week, y = rank, color = title_artist)) +
  geom_line(linewidth = 2.5) +  # Line plot for each song
  labs(
    x = "Date",
    y = "Rank"
    #title = "Weekly Rank Changes for Top 7 Songs with Most Rank 1" # removed, in slides
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +  # Format x-axis to show years
  scale_y_continuous(limits = c(1, 200)) +  # Set y-axis to go from 1 to 200
  theme_minimal() +  # Apply a clean theme
  theme(
    axis.text.y = element_text(size = 16),
    axis.text.x = element_text(size = 16),
    plot.title = element_text(),
    axis.title.x = element_text(size = 24),
    axis.title.y = element_text(size = 24),
    legend.text = element_text(size=16),
    legend.title = element_text(size = 24)
  )
ggsave("linechart_top7.png", width=1024*6, height=768*3, units="px")
# Load required libraries
library(dplyr)
library(ggplot2)

# Read arguments from the command line
args <- commandArgs(trailingOnly = TRUE)
print(args)

# Correct the missing closing parenthesis
data <- read.csv(paste0(args[1], ".csv"))

# Convert date column to Date format and extract components
data$date <- as.Date(data$date)
data$year <- format(data$date, "%Y")
data$month <- format(data$date, "%m")
data$day <- format(data$date, "%d")

# Loop through the specified years to plot graphs for each year
for (y in 2017:2021) {
  
  avg_rank <- data %>%
    # Filter for the specified date range (December 24–26)
    filter(day <= 26 & day >= 24 & month == "12" & year == y) %>%
    # Group by month, title, and artist, then calculate the average rank
    group_by(month, title, artist) %>%
    summarise(AverageRank = mean(rank), .groups = "drop")
  
  # Extract the top 5 songs for the month
  top5_songs_per_month <- avg_rank %>%
    group_by(month) %>%
    arrange(AverageRank) %>%
    slice_head(n = 5)
  
  # Create a filtered dataset of the top 5 songs
  selected_top5 <- data.frame(
    title = top5_songs_per_month$title,
    artist = top5_songs_per_month$artist
  )
  
  filtered_top5 <- data %>%
    inner_join(selected_top5, by = c("title", "artist"))
  
  # Filter for December data of the top 5 songs
  avg_rank <- filtered_top5 %>%
    filter(month == "12" & year == y)
  
  # Generate the plot
  p <- ggplot(avg_rank, aes(x = day, y = rank, group = title, color = title)) +
    geom_line(size = 1) +
    geom_point(size = 2) +
    scale_y_reverse() +
    labs(
      title = paste("Ranking Trend for Top 5 Songs in December for", y, "in Global"),
      x = "Date",
      y = "Rank"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5),
      axis.title.y = element_text(angle = 360, vjust = 0.5, hjust = 0.5),
      plot.background = element_rect(fill = "white", color = NA)
    )
  
  # Save the plot as a PNG file
  ggsave(
    filename = paste("Ranking_Trend_Top_5_Songs_December_", y, "_in_", args[1], ".png", sep = ""),
    plot = p,
    width = 10,
    height = 8,
    dpi = 300
  )
}

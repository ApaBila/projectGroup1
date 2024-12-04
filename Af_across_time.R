library(data.table)
library(dplyr)
library(tidyverse)
library(tools)

args <- commandArgs(trailingOnly=TRUE)
file <- args[1]
data <- fread(file)
city_name <- file_path_sans_ext(basename(file))

data$date <- as.Date(data$date)
data$month <- month(data$date)
data$year <- year(data$date)

af_cols <- grep("^af_", names(data), value = TRUE)
af_cols <- c('af_danceability','af_energy','af_loudness','af_liveness')
# Group by year and month, calculate averages for af_ columns
avg_data <- data %>%
  group_by(year, month) %>%
  summarise(across(all_of(af_cols), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"), .groups = "drop") %>%
  mutate(time = as.Date(paste(year, month, "01", sep = "-")))  # Create a time variable for continuous plotting

# Convert to long format, include variable names
long_data <- avg_data %>%
  pivot_longer(cols = starts_with("avg_af_"), names_to = "variable", values_to = "value")

# Plot all af_ variables over time
p <- ggplot(long_data, aes(x = time, y = value, group = variable)) + 
  geom_line(size = 0.8, color = "steelblue") +  # Adjust line color and size
  #geom_point(size = 1.5, color = "black") +  # Adjust point size and color
  scale_x_date(
    date_labels = "%Y-%m", 
    date_breaks = "3 months"  # Reduce frequency of labels for cleaner appearance
  ) +  
  labs(
    title = paste("Average of Auto Feature Columns Over Time for",city_name),
    x = "Time",
    y = "Average Value"
  ) + 
  theme_minimal() + 
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),  # Title adjustment
    axis.title = element_text(size = 10),  # Adjust axis title font size
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),  # Smaller and rotated x-axis labels
    axis.text.y = element_text(size = 9),  # Adjust y-axis label font size
    strip.text = element_text(size = 10, face = "bold"),  # Facet label formatting
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.grid.major = element_line(color = "gray90")  # Lighten major grid lines
  ) + 
  facet_wrap(~variable, scales = "free", ncol = 2)  # Set two columns for facets
ggsave(paste0('plot/',city_name,'.png'))

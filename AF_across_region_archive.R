library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
args <- commandArgs(trailingOnly = TRUE)
file_path <- args[1]

file_name <- basename(file_path)
file_name_no_ext <- sub("\\.csv$", "", file_name)

data <- read.csv(file_path)
data$date <- as.Date(data$date, format = "%Y-%m-%d")
data$month <- month(data$date)
data$year <- year(data$date)

af_cols <- grep("^af_", names(data), value = TRUE)

avg_data <- data %>%
  group_by(year,month) %>%
  summarise(across(all_of(af_cols), ~ mean(.x, na.rm = TRUE), .names = "avg_{.col}"), .groups = "drop")

long_data <- avg_data %>%
  pivot_longer(cols = starts_with("avg_af_"), names_to = "variable", values_to = "value")

p <-ggplot(long_data, aes(x = month, y = value, color = as.factor(year), group = year)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~ variable, scales = "free_y") +
  scale_x_continuous(breaks = 1:12, labels = month) + 
  labs(
    title = paste("Average of Auto Feature Columns by Month and Year for", file_name_no_ext),
    x = "Month",
    y = "Average Value",
    color = "Year"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.title.y = element_text(angle = 360, vjust = 0.5, hjust = 0.5),  # rotate y axis lable
    plot.background = element_rect(fill = "white", color = NA)
  )

print(p)

output_plot <- paste0("output/region/Average of Auto Feature Columns by Month and Year for ",file_name_no_ext, ".png")
ggsave(output_plot, plot = p, width = 8, height = 6, dpi = 300)

summary_stats <- data %>%
  summarise(across(all_of(af_cols), list(
    min = ~ min(.x, na.rm = TRUE),
    max = ~ max(.x, na.rm = TRUE),
    mean = ~ mean(.x, na.rm = TRUE),
    median = ~ median(.x, na.rm = TRUE),
    sd = ~ sd(.x, na.rm = TRUE),
    n_missing = ~ sum(is.na(.x))
  ), .names = "{.col}_{.fn}"))

table <- t(summary_stats)
colnames(table)[1] <- "Value"
print(table)

output_file <- paste0("output/region/Summary of Auto Feature Columns for ",file_name_no_ext, ".csv")
write.csv(table, output_file ,row.names = TRUE, col.names = TRUE)


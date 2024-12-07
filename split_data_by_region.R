# WARNING: Assumes you have alrady downloaded merged_data.csv from
# https://www.kaggle.com/datasets/sunnykakar/spotify-charts-all-audio-data
# and are in a directory with that file
# WARNING: This script takes a lot of memory and disk

merged_data <- read.csv("merged_data.csv")

# Filter to top200 chart, remove chart column + X and url (aren't needed either)
top200 <- subset(merged_data, chart == "top200", select = -c(X, chart, url))

# Split the dataset into a list of regional datasets, then loop to create *.csvs
split_data <- split(top200, top200$region)
for (region in names(split_data)) {
  file_name <- paste0(region, ".csv") # Create valid filename with no spcaces
  write.csv(split_data[[region]], file = file_name, row.names = FALSE)
}
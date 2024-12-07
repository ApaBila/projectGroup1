library(dplyr)
library(tidyr)

# Read in regional data
args <- commandArgs(trailingOnly = TRUE)
file_name <- args[1]
file <- paste0(args[1],".csv")
data <- read.csv(file)

# Get the mean of all the audio features
af_columns <- data %>% select(starts_with("af_"))
mean_values <- colMeans(af_columns, na.rm = TRUE)
result <- data.frame(
  File = file_name,
  t(mean_values) 
)

saveRDS(result, paste0(args[1],"_af.rds"))

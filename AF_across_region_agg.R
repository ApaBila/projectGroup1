library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)
library(patchwork)


# List all .rds files that are af, read in, store as list
files <- list.files("AF_across_region/",pattern = "\\_af.rds$", full.names = TRUE)
final_data <- map(files, readRDS) # purrr
cat(length(files))

merged_data1 <- final_data %>%
  reduce(full_join) 
af_columns <- merged_data1 %>% select(starts_with("af_"))
long_data1 <- merged_data1 %>%
  pivot_longer(cols = starts_with("af_"), names_to = "variable", values_to = "value")%>%
  filter(!is.na(value)) 
cat(length(long_data1))

plot_list <- list()
plotdata <- list()

for (i in 1:12) {
  print(i)
  plotdata[[i]] <- long_data1 %>%
    filter(variable == colnames(af_columns)[i]) %>%
    arrange(desc(value)) %>%
    slice_head(n = 10)
  
  plot_list[[i]] <- ggplot(plotdata[[i]], aes(x = reorder(File, value), y = value)) +
    geom_bar(stat = "identity", fill = "steelblue") +  
    labs(title = colnames(af_columns)[i],
         x = "Region",
         y = "Value")  +
    coord_flip() +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 10))
}

final_plot <- wrap_plots(plot_list, ncol = 4) + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.background = element_rect(fill = "white", color = NA))  

#print(final_plot)
ggsave("Top_10_Regions_for_Features.png", plot = final_plot, width = 18, height = 10, dpi = 300)


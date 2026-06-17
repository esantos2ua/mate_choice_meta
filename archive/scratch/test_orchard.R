library(metafor)
library(orchaRd)
library(ggplot2)

df_new <- data.frame(
  yi = rnorm(10, mean = 0.5), 
  vi = runif(10, 0.1, 0.3), 
  study = paste0("Study_N_", 1:10), 
  trial = paste0("Trial_N_", 1:10), 
  source = "New"
)
df_old <- data.frame(
  yi = rnorm(10, mean = 0.2), 
  vi = runif(10, 0.1, 0.3), 
  study = paste0("Study_O_", 1:10), 
  trial = paste0("Trial_O_", 1:10), 
  source = "Original"
)
df_all <- rbind(df_new, df_old)

# Fit three separate models
mod_new <- rma.mv(yi, vi, random = ~ 1 | study / trial, data = df_new)
mod_old <- rma.mv(yi, vi, random = ~ 1 | study / trial, data = df_old)
mod_all <- rma.mv(yi, vi, random = ~ 1 | study / trial, data = df_all)

# Extract results
res_new <- mod_results(mod_new, group = "study")
res_old <- mod_results(mod_old, group = "study")
res_all <- mod_results(mod_all, group = "study")

# Strip class, rename, and restore class
class(res_new) <- "list"
res_new$mod_table$name <- "New"
res_new$data$moderator <- "New"
class(res_new) <- c("orchard", "data.frame")

class(res_old) <- "list"
res_old$mod_table$name <- "Original"
res_old$data$moderator <- "Original"
class(res_old) <- c("orchard", "data.frame")

class(res_all) <- "list"
res_all$mod_table$name <- "Combined"
res_all$data$moderator <- "Combined"
class(res_all) <- c("orchard", "data.frame")

# Now submerge them!
sub_res <- submerge(res_new, res_old, res_all)

# Add real_source column to sub_res$data
class(sub_res) <- "list"
sub_res$data$real_source <- c(rep("New", 10), rep("Original", 10), rep("New", 10), rep("Original", 10))
class(sub_res) <- c("orchard", "data.frame")

# Plot!
p <- orchard_plot(sub_res, xlab = "ES")

# Change mappings to color by real_source
p$layers[[1]]$mapping$colour <- aes(colour = real_source)$colour
p$layers[[1]]$mapping$fill <- aes(fill = real_source)$fill

# Add scale
p_final <- p + 
  scale_colour_manual(values = c("New" = "#D55E00", "Original" = "#0072B2"), name = "Data Source") +
  scale_fill_manual(values = c("New" = "#D55E00", "Original" = "#0072B2"), name = "Data Source")

print("Final plot rendered successfully!")
print(p_final)

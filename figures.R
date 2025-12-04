###  (3) Generates the figures of the project  ####
library(tidyverse)
tsne_df <- read_csv("~/work/derived_data/tsne.csv")
umap_df <- read_csv("~/work/derived_data/umap.csv")

# 2d tsne and umap representation color coded by order in the book
library(viridis)
tsne_par_order <- ggplot(tsne_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "t-SNE of 'The Sound and the Fury' embeddings, colored by paragraph order",
    color = "Paragraph Order"
  )

umap_par_order <- ggplot(umap_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "UMAP of 'The Sound and the Fury' embeddings, colored by paragraph order",
    color = "Paragraph Order"
  )





# 2d tsne and umap representation color coded by narrator perspective
benjy_end     <- 1017   # quentin's section starts on paragraph 1018
quentin_end   <- 1939  # jason's section starts on paragraph 1940
jason_end     <- 2670  # omniscient section starts at paragraph 2671

tsne_df <- tsne_df %>% # assigns each paragraph to it's respective section
  mutate(
    section = case_when(
      para_id <= benjy_end            ~ "1. Benjy",
      para_id <= quentin_end          ~ "2. Quentin",
      para_id <= jason_end            ~ "3. Jason",
      TRUE                            ~ "4. Omniscient"
    )
  )

tsne_narr_order <- ggplot(tsne_df, aes(x = x, y = y, color = section)) +
  geom_point(alpha = 0.7, size = 1.5) +
  scale_color_manual(
    values = c(
      "1. Benjy"      = "#56B4E9",
      "2. Quentin"    = "#009E73",
      "3. Jason"      = "#CC79A7",
      "4. Omniscient" = "#E69F00"
    )
  ) +
  theme_minimal() +
  labs(
    title = "t-SNE of 'The Sound and the Fury' embeddings, colored by narrator",
    subtitle = "Colored by narrative section",
    color = "Narrator"
  )

umap_df <- umap_df %>%
  mutate(
    section = case_when(
      para_id <= benjy_end            ~ "1. Benjy",
      para_id <= quentin_end          ~ "2. Quentin",
      para_id <= jason_end            ~ "3. Jason",
      TRUE                            ~ "4. Omniscient"
    )
  )

umap_narr_order <- ggplot(umap_df, aes(x = x, y = y, color = section)) +
  geom_point(alpha = 0.7, size = 1.8) +
  scale_color_manual(
    values = c(
      "1. Benjy"      = "#56B4E9",
      "2. Quentin"    = "#009E73",
      "3. Jason"      = "#CC79A7",
      "4. Omniscient" = "#E69F00"
    )
  ) +
  theme_minimal() +
  labs(
    title = "UMAP of 'The Sound and the Fury' embeddings, colored by narrator",
    subtitle = "Colored by narrative section",
    color = "Narrator"
  )

ggsave(filename = "~/work/figures/tsne_par_order.jpeg", 
       plot = tsne_par_order, 
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/umap_par_order.jpeg", 
       plot = umap_par_order,
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/tsne_narr_order.jpeg", 
       plot = tsne_narr_order,   
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/umap_narr_order.jpeg", 
       plot = umap_narr_order,
       width = 6, 
       height = 4, 
       units = "in")



# Animated HTML that shows progression of story
library(plotly)

# Ensure data is sorted
umap_df <- umap_df %>% arrange(para_id)

# Group paragraphs into bins of 10 → reduces frames & prevents crashing
umap_df$frame_group <- floor(umap_df$para_id / 10)

animation <- plot_ly(
  umap_df,
  x = ~x,
  y = ~y,
  frame = ~frame_group,    # animation steps
  type = "scatter",
  mode = "markers",
  color = ~section,        # narrator
  marker = list(size = 8, opacity = 1),
  text = ~paste0(
    "Paragraph ID: ", para_id, "<br>",
    "Narrator: ", section, "<br><br>",
    substr(paragraph, 1, 200), "..."
  ),
  hoverinfo = "text"
) %>%
  
  layout(
    title = "UMAP Animation (10 Paragraphs per Frame)",
    xaxis = list(title = "UMAP dim 1"),
    yaxis = list(title = "UMAP dim 2")
  ) %>%
  
  # Animation settings
  animation_opts(
    frame = 150,      # speed between frames
    transition = 0,
    redraw = FALSE   # important for stability
  ) %>%
  
  animation_button(label = "Play")

# Build animation (I think it works better with UMAP, but I kept tsne here)
# p <- plot_ly(
#   tsne_df,
#   x = ~x,
#   y = ~y,
#   frame = ~frame_group,    # animation steps
#   type = "scatter",
#   mode = "markers",
#   color = ~section,        # narrator
#   marker = list(size = 8, opacity = 0.9),
#   text = ~paste0(
#     "Paragraph ID: ", para_id, "<br>",
#     "Narrator: ", section, "<br><br>",
#     substr(paragraph, 1, 200), "..."
#   ),
#   hoverinfo = "text"
# ) %>%
#   
#   layout(
#     title = "t-SNE Animation (Grouped Every 10 Paragraphs)",
#     xaxis = list(title = "t-SNE dim 1"),
#     yaxis = list(title = "t-SNE dim 2")
#   ) %>%
#   
#   # Animation settings
#   animation_opts(
#     frame = 100,      # speed between frames
#     transition = 0,
#     redraw = FALSE   # important for stability
#   ) %>%
#   
#   animation_button(label = "Play")




# Interactive 3-D Scatter plot with plotly to confirm structure
tsne_3d <- plot_ly(
  data = tsne_df,
  x = ~x,
  y = ~y,
  z = ~z,
  color = ~factor(section),
  colors = c("#56B4E9", "#009E73", "#CC79A7", "#E69F00"), # colorblind-friendly palette
  type = "scatter3d",
  mode = "markers",
  marker = list(size = 3, opacity = 0.5),
  text = ~paste0(
    "Paragraph ID: ", para_id, "<br>",
    "Narrator: ", section, "<br><br>",
    substr(paragraph, 1, 200), "..."
  ),
  hoverinfo = "text"
)

# Interactive 3-D Scatter plot with plotly to confirm structure
umap_3d <- plot_ly(
  data = umap_df,
  x = ~x,
  y = ~y,
  z = ~z,
  color = ~factor(section),
  colors = c("#56B4E9", "#009E73", "#CC79A7", "#E69F00"), # colorblind-friendly palette
  type = "scatter3d",
  mode = "markers",
  marker = list(size = 3, opacity = 0.5),
  text = ~paste0(
    "Paragraph ID: ", para_id, "<br>",
    "Narrator: ", section, "<br><br>",
    substr(paragraph, 1, 200), "..."
  ),
  hoverinfo = "text"
)

# outputting html file and static image for final report
library(htmlwidgets)

saveWidget(animation, file = "~/work/figures/animated.html", selfcontained = TRUE)
saveWidget(tsne_3d, file = "~/work/figures/tsne3d.html", selfcontained = TRUE)
saveWidget(umap_3d, file = "~/work/figures/umap3d.html", selfcontained = TRUE)
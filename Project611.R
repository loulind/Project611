########### this is a scratch document for my final BIOS 611 project #######
##### please see the README for full instructions on running the program ####
# reading in plain text file
library(tidyverse)
txt <- read_file("~/work/raw_data/sound_and_fury.txt")






# splitting into paragraph tokens (a lot of the dialogue is one liners?)
paragraphs <- txt %>%
  str_split("\\n\\s*\\n") %>% # split on empty lines
  unlist() %>%                # creates vector from string
  str_squish() %>%            # clean white space
  discard(~ .x == "") %>%     # remove empty paragraphs
  tibble(paragraph = .)       # creates new paragraph tibble column
paragraphs <- paragraphs[-(3182:3235), ]  # remove non-story INTRO
paragraphs <- paragraphs[-(1:18), ]  # remove non-story OUTRO
view(paragraphs)





# NEED HELP HERE! somehow get ollama qwen3 embedding model and calculate embedding vector?
library(jsonlite)
library(httr)
embed_paragraph <- function(text) {
  url <- "http://host.docker.internal:11434/api/embeddings"
  
  body <- list(
    model = "qwen3-embedding:8b",
    prompt = text
  )
  
  res <- httr::POST(
    url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )
  
  parsed <- jsonlite::fromJSON(httr::content(res, as = "text"))
  return(parsed$embedding)
}

embeddings <- paragraphs$paragraph |> 
  map(embed_paragraph) |> 
  do.call(what = rbind)

# Find unique embeddings and their mapping
emb_mat <- embeddings  # rename for clarity
ind_unique <- !duplicated(emb_mat)   # TRUE for first occurrence
emb_unique <- emb_mat[ind_unique, ]  # unique embedding rows





# t-SNE 
# (might want to compare to UMAP dimensionality reduction?)
# (UMAP assumes normal distribution across reimannian manifold)
library(Rtsne)
# set.seed(123) WAIT TO FINISH PROJECT BEFORE SETTING SEED!!!
tsne_unique <- Rtsne(
  emb_unique,
  dims = 2,
  perplexity = 30,
  verbose = TRUE
)

# initialize matrix of t-SNE coords for all rows
tsne_coords <- matrix(NA, nrow = nrow(emb_mat), ncol = 2)

# fill in coordinates
tsne_coords[ind_unique, ] <- tsne_unique$Y

# for duplicated rows, copy coordinates of their first occurrence
dup_map <- match(1:nrow(emb_mat), which(ind_unique))
tsne_coords <- tsne_unique$Y[dup_map, ]

tsne_df <- paragraphs %>%
  mutate(
    x = tsne_coords[, 1],
    y = tsne_coords[, 2],
    para_id = row_number()
  )






# Experimenting with UMAP 
# (supposed to preserve global structure better while also maintaining local)
library(umap)
umap_config <- umap.defaults
umap_config$n_neighbors <- 15
umap_config$min_dist <- 0.1
umap_config$metric <- "euclidean"

umap_unique <- umap(emb_unique, config = umap_config)

# mapping back to paragraph original positions
# coordinates for unique rows
coords_unique <- umap_unique$layout

# match each row in the full matrix to the unique rows
dup_map <- match(1:nrow(emb_mat), which(ind_unique))

# full coordinate matrix aligned with paragraphs
umap_coords <- coords_unique[dup_map, ]

# final umap df
umap_df <- paragraphs %>%
  mutate(
    x = umap_coords[, 1],
    y = umap_coords[, 2],
    para_id = row_number()
  )





# 2d tsne and umap representation color coded by order in the book
library(viridis)
tsne_chrono <- ggplot(tsne_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "t-SNE of Paragraph Embeddings from *The Sound and the Fury*",
    color = "Paragraph Order"
  )

umap_chrono <- ggplot(umap_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "UMAP of Paragraph Embeddings from *The Sound and the Fury*",
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

tsne_narrator <- ggplot(tsne_df, aes(x = x, y = y, color = section)) +
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
    title = "Paragraph-Level t-SNE of 'The Sound and the Fury'",
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
umap_narrator <- ggplot(umap_df, aes(x = x, y = y, color = section)) +
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
    title = "Paragraph-Level UMAP of 'The Sound and the Fury'",
    subtitle = "Colored by narrative section",
    color = "Narrator"
  )

ggsave(filename = "~/work/figures/tsne_chrono.jpeg", 
       plot = tsne_chrono, 
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/umap_chrono.jpeg", 
       plot = umap_chrono,
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/tsne_narrator.jpeg", 
       plot = tsne_narrator,   
       width = 6, 
       height = 4, 
       units = "in")
ggsave(filename = "~/work/figures/umap_narrator.jpeg", 
       plot = umap_narrator,
       width = 6, 
       height = 4, 
       units = "in")

# animated interactive plotly graph
library(plotly)

frames <- map(unique(umap_df$frame), function(k) {
  df_k <- umap_df %>% filter(frame <= k)   # <- cumulative subset
  
  list(
    name = k,
    data = list(
      list(
        x = df_k$x,
        y = df_k$y,
        mode = "markers",
        type = "scatter",
        marker = list(size = 6, opacity = 0.8),
        text = paste0(
          "Paragraph ID: ", df_k$para_id, "<br>",
          "Narrator: ", df_k$section, "<br><br>",
          substr(df_k$paragraph, 1, 200), "..."
        ),
        hoverinfo = "text",
        color = df_k$section
      )
    )
  )
})

p <- plot_ly(
  data = umap_df[1,],   # first point only (plotly needs something to start with)
  x = ~x,
  y = ~y,
  type = "scatter",
  mode = "markers",
  marker = list(size = 6, opacity = 0.8),
  text = ~paste0(
    "Paragraph ID: ", para_id, "<br>",
    "Narrator: ", section, "<br><br>",
    substr(paragraph, 1, 200), "..."
  ),
  hoverinfo = "text",
  color = ~section
) %>%
  layout(
    title = "Animated UMAP (Cumulative): Paragraphs Appearing in Order",
    xaxis = list(title = "UMAP-1"),
    yaxis = list(title = "UMAP-2"),
    updatemenus = list(
      list(
        type = "buttons",
        buttons = list(
          list(label = "Play", method = "animate", args = list(NULL)),
          list(label = "Pause", method = "animate",
               args = list(NULL, list(mode = "immediate")))
        )
      )
    )
  ) %>%
  animation_opts(
    frame = 50,         # ms
    transition = 0,
    redraw = TRUE       # important: redraw full cumulative graph each frame
  )

p$x$frames <- frames

p
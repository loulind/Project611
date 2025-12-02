######  (2) GENERATES DIMENSIONALITY-REDUCED DATA  #########
library(tidyverse)
embeddings <- read_csv("~/work/derived_data/embeddings.csv")
paragraphs <- read_csv("~/work/derived_data/paragraphs.csv")

# Find unique embeddings and their mapping
emb_mat <- as.matrix(embeddings)
ind_unique <- !duplicated(emb_mat)   # TRUE for first occurrence
emb_unique <- emb_mat[ind_unique, ]  # unique embedding rows


# t-SNE 
library(Rtsne)
set.seed(12012025)
tsne_unique <- Rtsne(
  emb_unique,
  dims = 3,
  perplexity = 30,
  verbose = TRUE
)

# initialize matrix of t-SNE coords for all rows
tsne_coords <- matrix(NA, nrow = nrow(emb_mat), ncol = 3)

# fill in coordinates
tsne_coords[ind_unique, ] <- tsne_unique$Y

# for duplicated rows, copy coordinates of their first occurrence
dup_map <- match(1:nrow(emb_mat), which(ind_unique))
tsne_coords <- tsne_unique$Y[dup_map, ]

tsne_df <- paragraphs %>%
  mutate(
    x = tsne_coords[, 1],
    y = tsne_coords[, 2],
    z = tsne_coords[, 3],
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


# exporting tsne and umap-transformed data
write.csv(tsne_df, file = "~/work/derived_data/tsne.csv", row.names = FALSE)
write.csv(umap_df, file = "~/work/derived_data/umap.csv", row.names = FALSE)
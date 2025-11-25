library(tidyverse)
library(httr)
library(jsonlite)
library(digest)
library(Rtsne)
library(viridis)

########### this is a scratch document for my final BIOS 611 project #######
# (1) reading in plain text file
library(tidyverse)
txt <- read_file("~/work/Data/sound_and_fury.txt")






# (2) splitting into paragraph tokens (a lot of the dialogue is one liners?)
paragraphs <- txt %>%
  str_split("\\n\\s*\\n") %>% # split on empty lines
  unlist() %>%                # creates vector from string
  str_squish() %>%            # clean white space
  discard(~ .x == "") %>%     # remove empty paragraphs
  tibble(paragraph = .)       # creates new paragraph tibble column
paragraphs <- paragraphs[-(3182:3235), ]  # remove non-story INTRO
paragraphs <- paragraphs[-(1:18), ]  # remove non-story OUTRO
view(paragraphs)




# (3) Pulling in model
OLLAMA_MODEL <- "qwen3-embedding:8b"
CACHE_DIR <- ".embedding_cache"

if (!dir.exists(CACHE_DIR)) dir.create(CACHE_DIR)

get_cache_path <- function(text) {
  file.path(CACHE_DIR, paste0(digest(text, algo = "md5"), ".json"))
}





# (4) Computing embeddings for every paragraph
fetch_ollama_embedding <- function(text) {  # Send text → embedding vector
  resp <- httr::POST(
    url = "http://localhost:11434/api/embeddings",
    body = list(
      model = OLLAMA_MODEL,
      prompt = text
    ),
    encode = "json"
  )
  parsed <- httr::content(resp, as = "parsed", encoding = "UTF-8")
  return(parsed$embedding)
}

get_embedding <- function(text) {
  cache_path <- get_cache_path(text)
  if (file.exists(cache_path)) {
    return(jsonlite::fromJSON(cache_path))
  }
  emb <- fetch_ollama_embedding(text)
  write(jsonlite::toJSON(emb, auto_unbox = TRUE), cache_path)
  return(emb)
}

paragraph_embeddings <- lapply(paragraphs$paragraph, get_embedding)
embedding_matrix <- do.call(rbind, paragraph_embeddings)





# (5) t-SNE 
# (might want to compare to UMAP dimensionality reduction?)
# (UMAP assumes normal distribution across reimannian manifold)
library(Rtsne)
# set.seed(123) WAIT TO FINISH PROJECT BEFORE SETTING SEED!!!

tsne_out <- Rtsne(
  unique_embeddings,
  dims = 2,
  perplexity = 30,
  verbose = TRUE
)

tsne_coords <- tsne_out$Y[unique_index, ]

tsne_df <- paragraphs %>%
  mutate(
    x = tsne_coords[, 1],
    y = tsne_coords[, 2],
    para_id = row_number()
  )





# (6) 2d tsne representation color coded by order in the book
library(viridis)
ggplot(tsne_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "t-SNE of Paragraph Embeddings from *The Sound and the Fury*",
    color = "Paragraph Order"
  )




# (7) 2d tsne representation color coded by narrator perspective
benjy_end     <- 800   # ends at paragraph ~800 (fix later)
quentin_end   <- 1600  # ends at paragraph ~1600
jason_end     <- 2400  # ends at paragraph ~2400
#  the remainder of the book is a 3rd person omniscient perspective

tsne_df <- tsne_df %>% # assigns each paragraph to it's respective section
  mutate(
    section = case_when(
      para_id <= benjy_end            ~ "1. Benjy",
      para_id <= quentin_end          ~ "2. Quentin",
      para_id <= jason_end            ~ "3. Jason",
      TRUE                            ~ "4. Omniscient"
    )
  )

ggplot(tsne_df, aes(x = x, y = y, color = section)) +
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
    title = "Paragraph-Level t-SNE of *The Sound and the Fury*",
    subtitle = "Colored by narrative section",
    color = "Narrator"
  )
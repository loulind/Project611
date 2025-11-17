install.packages("text") # need to add these packages to my dockerfile!
install.packages("text2vec")
install.packages("Rtsne")
install.packages("viridis") # colorblind friendly

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
paragraphs <- paragraphs[-(3182:3235), ]  # remove non-story material
paragraphs <- paragraphs[-(1:18), ]
view(paragraphs)






# (3) tokenizing
library(text2vec)
tokens <- paragraphs$paragraph %>%
  tolower() %>%
  word_tokenizer()

it <- itoken(tokens, progressbar = TRUE) # creating iterator

# (4) building vocabulary
vocab <- create_vocabulary(it)
vectorizer <- vocab_vectorizer(vocab)
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5)






# (5) training glove word embeddings 
# (GloVe embeddings capture semantics well but not deep context)
# (Would need transformer embedding from Python to capture deeper context)
glove <- GlobalVectors$new(rank = 100, x_max = 10)
word_embeddings_main <- glove$fit_transform(tcm, n_iter = 15)
word_embeddings_context <- glove$components

# Final embedding = main + context
word_vectors <- word_embeddings_main + t(word_embeddings_context)





# (6) converting paragraphs to embedding 
# (paragraph embedding = mean of the vectors for all words it contains)
paragraph_embeddings <- lapply(tokens, function(tok) {
  # keep only tokens that have embeddings
  valid <- tok[tok %in% rownames(word_vectors)]
  if (length(valid) == 0) {
    return(rep(0, ncol(word_vectors)))  # fallback for empty
  }
  colMeans(word_vectors[valid, , drop = FALSE])
}) %>% 
  do.call(rbind, .)

# Remove duplicate rows
unique_embeddings <- unique(paragraph_embeddings)

# Keep track of which rows map back to which paragraph
unique_index <- match(
  data.frame(t(paragraph_embeddings)),
  data.frame(t(unique_embeddings))
)





# (7) t-SNE (might want to compare to UMAP dimensionality reduction)
library(Rtsne)
set.seed(123)

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





# (8) 2d tsne representation color coded by order in the book
library(viridis)
ggplot(tsne_df, aes(x = x, y = y, color = para_id)) +
  geom_point(alpha = 0.8, size = 2) +
  scale_color_viridis(option = "plasma") +
  theme_minimal() +
  labs(
    title = "t-SNE of Paragraph Embeddings from *The Sound and the Fury*",
    color = "Paragraph Order"
  )




# (9) 2d tsne representation color coded by narrator perspective
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
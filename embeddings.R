#####  (1) CREATES EMBEDDINGS VECTOR FOR TEXT  ##########

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



# Ollama qwen3 embedding model and calculate embedding vector?
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



# exporting unique embedding vector and embeddings matrix
write.csv(embeddings, file = "~/work/derived_data/embeddings.csv", row.names = FALSE)
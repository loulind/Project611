---
title: "README for Lou's BIOS 611 Project"
---
The data set is a plain text file version of The Sound and the Fury by \n
William Faulkner. This project separates the novel by paragraph, uses \n
a locally-run LLM to create embeddings for each paragraph, and finally \n
conducts dimensionality reduction on the embedding vector to visualize the \n
narrative in 2 dimensions. 

Might want to generate a control dataset with GPT?

1. Download plain text file at: https://www.gutenberg.org/ebooks/75170 \n 
\t and save the file as sound_and_fury.txt
2. Clone git repository and cd into project directory
3. Give execute permissions to start.sh with ```chmod +x start.sh```
4. Run ```./start.sh``` in terminal
5. In Console, ```setwd("~/work")``` and in Terminal, ```cd ~/work/```
6. Download Ollama. In terminal, run these commands: ollama pull qwen3-embedding:8b
ollama serve


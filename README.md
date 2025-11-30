---
title: "README for Lou's BIOS 611 Project"
---
The data set is a plain text file version of The Sound and the Fury by \n
William Faulkner. This project separates the novel by paragraph, uses \n
a locally-run LLM to create embeddings for each paragraph, and finally \n
visualizes the data in 2d using clustering and dimensionality reduction \n
on the embedding vector narrative in 2 dimensions. 

The plain text file can be downloaded at: https://www.gutenberg.org/cache/epub/75170/pg75170.txt
(I also pushed the file to my Github just because it was a small file)

1. If necessary, download the plain text file above; save as "sound_and_fury.txt"
2. Clone git repository
3. Run ```./start.sh``` in host terminal. \n
\t (might need to give execute permissions with ```chmod +x start.sh```
4. In R Console, you may need to ```setwd("~/work")``` and in Rstudio Terminal, ```cd ~/work/```
5. Download Ollama application from: https://ollama.com/download/
6. In host terminal, run the following (it will take awhile) \n
```ollama pull qwen3-embedding:8b
ollama serve```
7. In Rstudio Terminal do ```Make clean``` and then you can either ```Make all``` \n
\t or ```Make <specific-output>```


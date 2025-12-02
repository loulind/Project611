---
title: "Embedding and Dimensionality Reduction of 'The Sound and the Fury' by William Faulkner"
author: "Lou Lindsley"
---
The data set is a plain text file version of The Sound and the Fury by
William Faulkner. This project separates the novel by paragraph, uses
a locally-run LLM to create embeddings for each paragraph, and finally
visualizes the data in 2d using clustering and dimensionality reduction
on the embedding vector. 

The plain text file can be downloaded at: https://www.gutenberg.org/cache/epub/75170/pg75170.txt
(I also pushed the file to my Github just because it was a small file)

1. If necessary, download the plain text file above; save as "sound_and_fury.txt"
2. Clone git repository and cd into project directory
3. Run ```./start.sh``` in host terminal.
(might need to give execute permissions with ```chmod +x start.sh```
4. Open browser to http://localhost:8787 (user: rstudio, pw: 123)
5. In R Console, you may need to ```setwd("~/work")``` and in Rstudio Terminal, ```cd ~/work/```
6. Download Ollama application from: https://ollama.com/download/
7. In host terminal, run the following (it will take awhile)
```ollama pull qwen3-embedding:8b ; ollama serve```
8. In Rstudio Terminal do ```make clean``` and then you can either ```make report```
or ```make <specific-target>```
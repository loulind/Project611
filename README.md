---
title: "README for Lou's BIOS 611 Project"
---
EXPLAIN DATATSET HERE. Might want to generate a control dataset with GPT?

1. If Faulkner, download plain text file at: https://www.gutenberg.org/ebooks/75170 \n 
\t and save the file as sound_and_fury.txt
1. If EBV, download data at: 
https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/KYH9SF

2. Clone git repository and cd into project directory
3. Give execute permissions to start.sh with ```chmod +x start.sh```
4. Run ```./start.sh``` in terminal
5. In Console, ```setwd("~/work")``` and in Terminal, ```cd ~/work/```

. Download Ollama. In terminal, run these commands: ollama pull qwen3-embedding:8b
ollama serve


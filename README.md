*This is the README for Lou's BIOS 611 final project*

The data set is a plain text file version of 'The Sound and the Fury' by
William Faulkner. This project separates the novel by paragraph, uses
a locally-run LLM to create an embedding for each paragraph, and finally
visualizes the data in 2 and 3 dimensions using dimensionality reduction
on the embedding vector.

The plain text file can be downloaded at: https://www.gutenberg.org/cache/epub/75170/pg75170.txt
(I pushed the text file to my repo under work/raw_data/ to make it easier for the grader)

1. If necessary, download the plain text file above; save as "sound_and_fury.txt". 
(This project also requires downloading Docker Desktop)
2. Clone git repository and cd into project directory
3. Run ```./start.sh``` in host terminal.
(might need to give execute permissions with ```chmod +x start.sh```
4. Open browser to http://localhost:8787 (user: rstudio, pw: 123)
5. In R Console, use ```setwd("~/work")``` and in Rstudio Terminal, ```cd ~/work/```
6. Download Ollama application from: https://ollama.com/download/
7. In host terminal, run the following (it will take awhile to pull)
```ollama pull qwen3-embedding:8b ; ollama serve```
8. In Rstudio Terminal do ```make clean```, ```make dirs```, and then ```make report```
(or ```make <specific-target>```)

*For dev eyes only:*
Please see Makefile for the structure and flow of outputs in this project.
If you add a new figure to the project, add the file path as a target under
the "figures" entry. If you perform some intermediate analysis of the embedding,
create a new target in the Makefile with derived_data/embedding.csv as a 
dependency. If you need to pull in new packages to the container, add the 
package name to the import.packages command in the Dockerfile. You can test 
to make sure new targets work by using command ```make <new-target-name>```
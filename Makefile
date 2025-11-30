.PHONY: all clean dirs

# Generates all artefacts in project. it's better to better to make the artefacts in order
all:
	make dirs
	make 
	
# cleans project
clean:
	rm -rf Data
	rm -rf Figures

# creates folders for project and pulls in plain text file
dirs:
	mkdir -p Data
	curl -o Data/sound_and_fury.txt https://www.gutenberg.org/cache/epub/75170/pg75170.txt
	
	

# creates vector containing paragraphs in book
paragraphs.csv: paragraphs.R sound_and_fury.txt
	paragraphs.R

# creates embeddings vector
embeddings.csv: embeddings.R paragraphs.csv
	embeddings.Rd

# dimensionality reduction
tsne.csv umap.csv: tsne.R embeddings.csv
	tsne.R
	
# clustering
spectral.csv: embeddings.csv spectral.R
	spectral.R
	
# figures
tsne_scatter.png umap_scatter.png spectral_scatter.png: figures.R
	figures.R

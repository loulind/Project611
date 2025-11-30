.PHONY: all clean dirs

# Generates all artefacts in project. it's better to better to make the artefacts in order
all:
	make dirs
	make 
	
# cleans project
clean:
	rm -rf derived_data
	rm -rf figures

# creates folders for project
dirs:
	mkdir -p derived_data
	mkdir -p figures


# creates vector containing paragraphs in book
paragraphs.csv: paragraphs.R sound_and_fury.txt | dirs
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
tsne_narrator.png\
 umap_narrator.png\
 tsne_chrono.png\
 umap_chrono.png\
 spectral_scatter.png: figures.R
	figures.R

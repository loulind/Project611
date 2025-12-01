.PHONY: clean dirs

# cleans project
clean:
	rm -rf derived_data
	rm -rf figures

# creates folders for project
dirs:
	mkdir -p derived_data
	mkdir -p figures


# creates embeddings vector
embeddings.csv: ~/raw_data/sound_and_fury.txt embeddings.R | dirs
	embeddings.R

# dimensionality-reduced data
tsne.csv umap.csv: dim_reduce.R embeddings.csv
	dim_reduce.R

# figures
tsne_narr_order.png\
 umap_narr_order.png\
 tsne_par_order.png\
 umap_par_order.png\
 spectral_scatter.png: tsne.csv umap.csv spectral.csv figures.R
	figures.R
	
# report
report.html: tsne_narrator.png\
 umap_narrator.png\
 tsne_chrono.png\
 umap_chrono.png\
 spectral_scatter.png report.Rmd | dirs
	report.Rmd

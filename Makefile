all: candy_grouped_scores.csv

clean:
	rm -f candy_raw.csv candy_clean.csv resp_reorder_age.png heamap_candy_age_group.png candy_grouped_scores.csv

candy_raw.csv:
	Rscript 00_download-data.R

candy_clean.csv:candy_raw.csv 01_data-cleaning.R
	Rscript 01_data-cleaning.R

candy_grouped_scores.csv:candy_clean.csv 02_explore-data-plot.R
	Rscript 02_explore-data-plot.R
	rm Rplots.pdf
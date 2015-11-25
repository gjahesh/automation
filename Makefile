.PHONY: all clean
.DELETE_ON_ERROR:
.SECONDARY:
all: 02_explore-data-plot-report.html

candy_raw.csv:
	Rscript 00_download-data.R

candy_clean.csv:01_data-cleaning.R candy_raw.csv
	Rscript $<

candy_grouped_scores.csv resp_reorder_age.png heatmap_candy_age_group.png trick_treat_age_group.png :candy_clean.csv 02_explore-data-plot.R
	Rscript 02_explore-data-plot.R
	rm Rplots.pdf
	
03_explore-data-plot-report.html: 03_explore-data-plot-report.rmd resp_reorder_age.png heatmap_candy_age_group.png trick_treat_age_group.png candy_clean.csv 
	Rscript -e 'rmarkdown::render("$<")'

clean:
	rm -rf *.csv *.png 0*.md *.html 03_explore-data-plot-report.files
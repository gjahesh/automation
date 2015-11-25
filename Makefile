all: candy_clean.csv

clean:
	rm -f candy_raw.csv candy_clean.csv

candy_raw.csv:
	Rscript 00_download-data.R

candy_clean.csv:candy_raw.csv 01_data-cleaning.R
	Rscript 01_data-cleaning.R
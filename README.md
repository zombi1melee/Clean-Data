---
title: "Human Activity Recognition Using Smartphones Dataset Version 1.0"
author: "Charles Hale"
date: "Jan 20, 2015"
output: html_document
---

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones> looks at 30 volunteers who performed six activities ranging from walking to laying, all while wearing a smartphone on the waist. The data is used to demonstrate concepts of clean dataset analysis, put forth by [Hadley Wickham](http://vita.had.co.nz/papers/tidy-data.html).  To explore the dataset run the R script, `run_analysis.R` using source.
```{r}
source("run_analysis.R")
```

The script should download and unzip the dataset zip file into the data directory.  The script should also run if the data files have been previously unzipped into a `data` directory and if the original unzipped directory structure has not changed.
```{r}
# create directory to hold downloaded file
if(!file.exists("data")) {
  dir.create("data")
}

dest_file <- "./data/HARdatset.zip"
date_downloaded <- NULL
# get data
if(!file.exists(dest_file)) {
  file_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(file_URL, destfile = "./data/HARdatset.zip", method = "curl")
  (date_downloaded <- date())
}
```
When `run_analysis.R` is sourced, message text is printed in the console.  The messages note, if applicable, downloading, and reading of the data files.   The script will also pause to review the combined training and test datasets, named har dataset.  `Press return to continue` will complete the run.



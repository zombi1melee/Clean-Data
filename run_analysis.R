# Charles Hale
# January 24, 2015
# Getting and cleaning data project: Coursera  

# instead of displaying all digits, display 5 digits
options(digits = 5) 

library("dplyr")
library("data.table")

#################################################################
# download zip file
# create directory to hold downloaded file
if(!file.exists("data")) {
  dir.create("data")
}

dest_file <- "./data/HARdatset.zip"
date_downloaded <- NULL
file_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# get data
if(!file.exists(dest_file)) {
  download.file(file_URL, destfile = dest_file, method = "curl")
  (date_downloaded <- date())
}
if(file.exists(dest_file)) {
  unzip(zipfile = dest_file, exdir = path.expand("./data"))
}
list.files("./data")

#################################################################
# functions to read files
# template function to read files
load_dataset <- function(input, ...) {
  function(x) {
    data_set = NULL
    try(data_set <- fread(input = input, ...), silent = TRUE)
    cat(sprintf("Processing dataset...\n"))
    return(data_set)
  }
}

activity_label <-  load_dataset(input = "./data/UCI HAR Dataset/activity_labels.txt", 
                                stringsAsFactors = FALSE)

test_label <- load_dataset(input = "./data/UCI HAR Dataset/test/y_test.txt", 
                           stringsAsFactors = FALSE)

train_label <- load_dataset(input = "./data/UCI HAR Dataset/train/y_train.txt", 
                            stringsAsFactors = FALSE)

feature <- load_dataset(input = "./data/UCI HAR Dataset/features.txt", 
                        stringsAsFactors = FALSE)

# relabel column names to normalized names
relabel <- function(features) {
  require("stringr")
  features <- str_replace_all(features[,V2], "(Body)*Body", "Body")
  features <- sub("\\W", "-", features)
  features <- str_replace_all(features, "[()]", "")
  features <- str_replace_all(features, ",", "-")
  features <- tolower(features)
  return(features)
}  
# check if all data are numerical
check_numeric <- function(x) {
  if(all(unlist(lapply(x, is.numeric)))) {
    cat(x, "contains all numerical data.\n")
   # return(TRUE)
  }
  else {
    warning(x, "may not contain all numerical data.\n")
  # return(FALSE) 
  }
}
#################################################################
# reads in data
# read in numerical data using a matrix
testset_mx <- matrix(scan("./data/UCI HAR Dataset/test/X_test.txt", what = numeric()), 
                     2947, 561, byrow = TRUE)
trainset_mx <- matrix(scan("./data/UCI HAR Dataset/train/X_train.txt", what = numeric()), 
                      7352, 561, byrow = TRUE)
subjecttest_mx <- matrix(scan(file = "./data/UCI HAR Dataset/test/subject_test.txt", 
                         what = character()), ncol = 1)
subjecttrain_mx <- matrix(scan(file = "./data/UCI HAR Dataset/train/subject_train.txt", 
                          what = character()), ncol = 1)

# link class labels to activity names
exercise <-  activity_label()
setnames(exercise,1:2,c("class", "name")) 

# change activity names
activity <- c("stroll", "incline_walking", "decline_walking", "seated",
              "erect", "rest")
activity_labels <- cbind(exercise, activity)
activity_labels$activity <- as.character(activity_labels$activity) 

# recoded activity names for test and training sets to match class
recode_test <- test_label()
setnames(recode_test,1, "class") 
recode_test <- within(recode_test, {
  activity <- NA
  activity[class == 1]  <- activity_labels[1, activity]
  activity[class == 2]  <- activity_labels[2, activity]
  activity[class == 3]  <- activity_labels[3, activity] 
  activity[class == 4]  <- activity_labels[4, activity] 
  activity[class == 5]  <- activity_labels[5, activity]  
  activity[class == 6]  <- activity_labels[6, activity] 
  activity <- factor(activity)
})

recode_train <- train_label()
setnames(recode_train,1, "class") 
recode_train <- within(recode_train, {
  activity <- NA
  activity[class == 1]  <- activity_labels[1, activity] 
  activity[class == 2]  <- activity_labels[2, activity]
  activity[class == 3]  <- activity_labels[3, activity]
  activity[class == 4]  <- activity_labels[4, activity] 
  activity[class == 5]  <- activity_labels[5, activity] 
  activity[class == 6]  <- activity_labels[6, activity] 
  activity <- factor(activity)
})

# relabel column names
features <- feature()
relabel_feature <- relabel(features)
colnames(testset_mx) <- relabel_feature
colnames(trainset_mx) <- relabel_feature

colnames(subjecttest_mx) <- "subject"
colnames(subjecttrain_mx) <- "subject"

#################################################################
# merge training and test sets
test_dataset <- cbind(recode_test, subjecttest_mx, testset_mx)
train_dataset <- cbind(recode_train, subjecttrain_mx, trainset_mx)
# just checking if all data is numeric
check_numeric(test_dataset[,-c(1,2,3)])
check_numeric(train_dataset[,-c(1,2,3)])

# wide format HAR data set
har <- rbind(test_dataset, train_dataset)
har$subject <- as.character(har$subject)

# looking for NAs and NaNs
har[!complete.cases(har),]
# structure of har
str(har)
dim(har)
cat(sprintf("Merged training and test datasets\n"))
print(tbl_df(har[1:10, 1:10, with = FALSE]))
pause <- readline("Press Return to Continue.")

#################################################################
# extract mean and standard deviation columns
ds_tbl <- tbl_df(har)
# get column names
cn <- names(ds_tbl) 
# get mean columns
st_m <- str_detect(cn, "mean($|[^a-zA-Z])") 
dataset_mean <- ds_tbl[st_m]
# get std columns
st_std <- str_detect(cn, "std($|[^a-zA-Z])")
dataset_std <- ds_tbl[st_std]

# combine mean, standard deviation, volunteer/subjects, 
# and activity columns
dataset_mmt <- cbind(ds_tbl[, c(2,3)], dataset_mean, dataset_std)
dataset_mmt[1:10, 1:10]

#################################################################
# average of each variable for each activity and subject dataset
avg_subject <- dataset_mmt %>% group_by(subject, activity) %>% summarise_each(funs(mean))
avg_subject[1:10, 1:10]
# sample of rows
subject_sample <- avg_subject[sample(nrow(avg_subject), 10), ]
sample_n(avg_subject, 25, size = 3)

# different views of dataset based upon importance
avg_activity <- dataset_mmt %>% group_by(activity, subject) %>% summarise_each(funs(mean))
avg_activity[1:10, 1:10]
# write.table(avg_subject, file = "avg_subject.txt", row.name = FALSE)
cat(sprintf("Completed\n"))




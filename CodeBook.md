#Codebook

Data variables derived from <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones> based on experiments carried out using 30 volunteers, ranging in ages of 19 to 48.  Each person performed the following six activities wearing a smart phone where measurements were taken to capture 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz.

- Walking
- Walking Upstairs
- Walking Downstairs
- Sitting
- Standing
- Laying

Each record of the dataset consist of its triaxial acceleration, triaxial angular velocity, a 561-feature vector, activity labels, and subject identifiers.  There is also considerable coverage of the variables in the README.txt file that accompanies the download of the original dataset.  For further questions about the dataset please contact: activityrecognition@smartlab.ws

##Methodology
Functions consisting of `fread` and `matrix` are used to read in the data files as numerical and character variables.  After the data files are read into variables, the class labels are linked to activity names and the test labels are recoded.  Processes are used to change the activity names and recode the test and training labels to match their respected class.  Column names are also given descriptive names.  Two separate datasets are developed, where each dataset included numerical data, recoded names and subject data.  The datasets are then combined by row into a complete dataset using a wide format. 

```{r}
# wide format HAR data set
har <- rbind(test_dataset, train_dataset)
```

```{r}
# number or rows and columns
dim(har)
# structure of har
str(har)
tbl_df(har[1:10, 1:10, with = FALSE])
```
##Transformations
Changes to the original data include:

- The activity names changed to stroll, incline walking, decline walking, seated, erect, and rest.
- Merged the training and test sets into one dataset and transformed the dataset to reflect a wide format.
- Extracted the mean and standard deviation columns into a second dataset.
- Removed "()", replaced "," with "-", used lower case letters in column names, and removed duplicate column names.  
- Created a dataset with averages of variables for each activity and subject and composed of different views of the dataset.

##Conclusion
Calculate the average of each variable for each activity and each subject.

```{r}
avg_subject <- dataset_mmt %>% group_by(subject, activity) %>% summarise_each(funs(mean))
avg_subject[1:10, 1:10]
# sample of rows
subject_sample <- avg_subject[sample(nrow(avg_subject), 10), ]
sample_n(avg_subject, 25, size = 3)
```





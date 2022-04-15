# Getting and Cleaning Data Course Project

## loading packages
library(dplyr)

# Create data folder directory, first check if it exists or no
if(!file.exists('./data')){
  dir.create('./data') # create directory for dataset
}

# Download data from URL and unzip it
# Download dataset and unzip it
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = './data/Data.zip')
unzip(zipfile = './data/Data.zip', exdir='./data')

# Get the files from data folder
file_path <- file.path('./data', 'UCI HAR Dataset')
files <- list.files(file_path, recursive=TRUE)

## Read the text files and store data in data frames
# Train dataset
y_train <- read.table(file.path(file_path, "train", "y_train.txt"),col.names = 'code', header = FALSE)
x_train <- read.table(file.path(file_path, "train", "X_train.txt"),col.names = features$functions, header = FALSE)
sub_train <- read.table(file.path(file_path, "train", "subject_train.txt"), col.names = 'subject',header = FALSE)


# Test dataset
y_test  <- read.table(file.path(file_path, "test" , "y_test.txt" ),col.names = 'code', header = FALSE)
x_test  <- read.table(file.path(file_path, "test" , "X_test.txt" ),col.names = features$functions, header = FALSE)
sub_test  <- read.table(file.path(file_path, "test" , "subject_test.txt"),col.names = c('subject'), header = FALSE)

features <- read.table(file.path(file_path, "features.txt" ),col.names = c('n','functions'), header=FALSE)
activities <- read.table(file.path(file_path, "activity_labels.txt"),col.names = c('code','activity'), header = FALSE)


# Merges the training and the test sets to create one data set
subjects <- rbind(sub_train, sub_test)
lables <- rbind(y_train, y_test)
sets <- rbind(x_train, x_test)

mergedDataset <- cbind(subjects,lables,sets)


# Extracts only the measurements on the mean and standard deviation for each measurement. 
tidyDataSet <- mergedDataset %>%  select(subject, code, contains('mean'), contains('std'))

# Uses descriptive activity names to name the activities in the data set
tidyDataSet$code <- activities[tidyDataSet$code, 2]

# Appropriately labels the data set with descriptive variable names
names(tidyDataSet)[2] = "activity"
names(tidyDataSet)<-gsub("Acc", "Accelerometer", names(tidyDataSet))
names(tidyDataSet)<-gsub("Gyro", "Gyroscope", names(tidyDataSet))
names(tidyDataSet)<-gsub("BodyBody", "Body", names(tidyDataSet))
names(tidyDataSet)<-gsub("Mag", "Magnitude", names(tidyDataSet))
names(tidyDataSet)<-gsub("^t", "Time", names(tidyDataSet))
names(tidyDataSet)<-gsub("^f", "Frequency", names(tidyDataSet))
names(tidyDataSet)<-gsub("tBody", "TimeBody", names(tidyDataSet))
names(tidyDataSet)<-gsub("-mean()", "Mean", names(tidyDataSet), ignore.case = TRUE)
names(tidyDataSet)<-gsub("-std()", "STD", names(tidyDataSet), ignore.case = TRUE)
names(tidyDataSet)<-gsub("-freq()", "Frequency", names(tidyDataSet), ignore.case = TRUE)
names(tidyDataSet)<-gsub("angle", "Angle", names(tidyDataSet))
names(tidyDataSet)<-gsub("gravity", "Gravity", names(tidyDataSet))

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

final_data <- tidyDataSet %>% group_by(subject, activity) %>% summarise_all(funs(mean))


# Write the result in text file
write.table(final_data, './data/FinalData.txt', row.name = FALSE)


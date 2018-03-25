#Installing required packages
install.packages("data.table")
install.packages("reshape2")

#Calling the installed libraries
library(data.table)
library(reshape2)

source_file <- "FinalProject.zip"

# In this segment of the code I'm checking whether the file exists or not. If not, the variable fileURL will be used to download the dataset to work on this project.
if (!file.exists(source_file)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, source_file)
} 

# Now, I'll check for "UCI HAR Dataset". In case it doesn't exist I'll unzip the downloaded zip file (dataset).
if (!file.exists("UCI HAR Dataset")) { 
        unzip(source_file) 
}

# In this segment I'm working the labels and features of the file data
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
labels[,2] <- as.character(labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Mean and SD restriction
featuresDesired <- grep(".*mean.*|.*std.*", features[,2])
featuresDesired.names <- features[featuresDesired,2]
featuresDesired.names = gsub('-mean', 'Mean', featuresDesired.names)
featuresDesired.names = gsub('-std', 'Std', featuresDesired.names)
featuresDesired.names <- gsub('[-()]', '', featuresDesired.names)


# Coming up with the training and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresDesired]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresDesired]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Generating a single data source
singleDataSource <- rbind(train, test)
colnames(singleDataSource) <- c("subject", "activity", featuresDesired.names)

# Working with factors
singleDataSource$activity <- factor(singleDataSource$activity, levels = labels[,1], labels = labels[,2])
singleDataSource$subject <- as.factor(singleDataSource$subject)

singleDataSource.melted <- melt(singleDataSource, id = c("subject", "activity"))
singleDataSource.mean <- dcast(singleDataSource.melted, subject + activity ~ variable, mean)

write.table(singleDataSource.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
#Getting and Cleaning Data week4 project
#December 2020

#Load packages
library(data.table)
library(dplyr)

#Set the working directory
setwd("C:/Users/to10678/Desktop/R learning/Getting-and-Cleaning-Data---Week4-Project")

#Download data files, unzip, and specify time/date settings
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- "getdata_projectfiles_UCI HAR Dataset.zip"
if (!file.exists(filename)){
    download.file(URL, destfile = filename, mode='wb')
}
if (!file.exists("./getdata_projectfiles_UCI HAR Dataset")){
    unzip(destFile)
}
dateDownloaded <- date()

#set the working directory
setwd("./getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

#reading datas
feature_test <- read.table("./test/X_test.txt", header = F)
feature_train <- read.table("./train/X_train.txt", header = F)

subject_test <- read.table("./test/subject_test.txt", header = F)
subject_train <- read.table("./train/subject_train.txt", header = F)

label_test <- read.table("./test/y_test.txt", header = F)
label_train <- read.table("./train/y_train.txt", header = F)

label <- read.table("./activity_labels.txt", header = F)

feature <- read.table("./features.txt", header = F)

#Merge datas
feature_data <- rbind(feature_test, feature_train)
subject_data <- rbind(subject_test, subject_train)
label_data <- rbind(label_test, label_train)

#naming columns
names(label_data) <- "labelnumber"
names(label) <- c("labelnumber", "label")

#assign label to each labelnumber
activity <- left_join(label_data,label,"labelnumber")
activity <- activity[, 2]

#naming columns
names(subject_data) <- "subject"
names(feature_data) <- feature[,2]

#merge datas
data1 <- cbind(subject_data, activity)
data1 <- cbind(data1, feature_data)

#extracting only the mean and standard deviation
subfeature <- feature$V2[grep("mean\\(\\)|std\\(\\)", feature$V2)]
extract_list <- c("subject","activity",as.character(subfeature))
data1 <- subset(data1, select=extract_list)

#rename the columns of data1
names(data1) <- gsub("^t", "time", names(data1))
names(data1) <- gsub("^f", "frequency", names(data1))
names(data1) <- gsub("Mag","Magnitude", names(data1))
names(data1) <- gsub("Acc","Accelerometer", names(data1))
names(data1) <- gsub("Gyro","Gyroscope", names(data1))

#Create a second dataset
data2 <- aggregate(. ~subject + activity, data1, mean)
data2 <- data2[order(data2$subject, data2$activity),]

#Save the second dataset to directory 
write.table(data2, file = "tidydata.txt",row.name=FALSE)


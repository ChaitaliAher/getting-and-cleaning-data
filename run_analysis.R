#Getting and Cleaning Data
#run_analysis.R

#Library
library(reshape2)
getwd()

#1. get dataset from web
rawDataDir <- "C:/Users/ADMIN/Documents/R/Datasets"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename <- "getdata_projectfiles_UCI HAR Dataset.zip"
rawDataDFn <- paste(rawDataDir, "/", "getdata_projectfiles_UCI HAR Dataset.zip", sep = "")
dataDir <- "C:/Users/ADMIN/Documents/R/Datasets"
dataDir
if (!file.exists(rawDataDir)) {
  dir.create(rawDataDir)
  download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = rawDataDFn, exdir = dataDir)
}
setwd("C:/Users/ADMIN/Documents/R/Datasets/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")
#C:\Users\ADMIN\Documents\R\Datasets\getdata_projectfiles_UCI HAR Dataset\UCI HAR Dataset\train

#2. merge {train, test} data set
# train data
?read.table
x_train <- read.table("X_train.txt",header = FALSE, sep = "", encoding = "UTF-8")
y_train <-  read.table("y_train.txt",header = FALSE, sep = "", encoding = "UTF-8")
s_train <- read.table("subject_train.txt",header = FALSE, sep = "", encoding = "UTF-8")

#view data
View(s_train)

# test data
x_test <- read.table("X_test.txt",header = FALSE, sep = "", encoding = "UTF-8")
y_test <-  read.table("y_test.txt",header = FALSE, sep = "", encoding = "UTF-8")
s_test <- read.table("subject_test.txt",header = FALSE, sep = "", encoding = "UTF-8")

# merge {train, test} data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)


#3. load feature & activity info
# feature info
feature <- read.table("features.txt",header = FALSE, sep = "", encoding = "UTF-8")

# activity labels
a_label <- read.table("activity_labels.txt",header = FALSE, sep = "", encoding = "UTF-8")
a_label[,2] <- as.character(a_label[,2])

# cols & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


#4 Extract data by cols 
x_data <- x_data[selectedCols]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = a_label[,1], labels = a_label[,2])
allData$Subject <- as.factor(allData$Subject)


#5. generate tidy data set
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

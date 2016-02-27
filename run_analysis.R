# Getting and Cleaning Data Course Project
# You should create one R script called run_analysis.R that does the following.
# 1_Merges the training and the test sets to create one data set
# 2_Extracts only the measurements on the mean and standard deviation for each measurement
# 3_Uses descriptive activity names to name the activities in the data set
# 4_Appropriately labels the data set with descriptive variable names
# 5_From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# 0. Before starting

# A. Get the data
# a. Download the file and put the file in the “./data” folder

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./data/Dataset.zip")

# b. Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# c. Unzipped files are in the folder “UCI HAR Dataset”
path_unzip <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_unzip, recursive=TRUE)
files

# B.Reading data from various files
# B-1 Read data from the files into the variables

#Read the Activity files
TrainActivity <- read.table(file.path(path_unzip, "train", "Y_train.txt"),header = FALSE)
TestActivity  <- read.table(file.path(path_unzip, "test" , "Y_test.txt" ),header = FALSE)

#Read the Subject files
TrainSubject <- read.table(file.path(path_unzip, "train", "subject_train.txt"),header = FALSE)
TestSubject  <- read.table(file.path(path_unzip, "test" , "subject_test.txt"),header = FALSE)

#Read Features files
TestFeatures  <- read.table(file.path(path_unzip, "test" , "X_test.txt" ),header = FALSE)
TrainFeatures <- read.table(file.path(path_unzip, "train", "X_train.txt"),header = FALSE)

# B-2 Identify properties of variable

str(TestActivity)
str(TrainActivity)
str(TestSubject)
str(TrainSubject)
str(TestFeatures)
str(TrainFeatures)


# 1.	Merges the training and the test sets to create one data set. (Merges “train” and “test” sets to create one data set)
# 1) Row bind data
SubjectData <- rbind(TrainSubject, TestSubject)
ActivityData<- rbind(TrainActivity, TestActivity)
FeaturesData<- rbind(TrainFeatures, TestFeatures)

# 2) Set name
names(SubjectData)<-c("subject")
names(ActivityData)<- c("activity")
FeaturesDataNames <- read.table(file.path(path_unzip,  "features.txt"), head=FALSE)
names(FeaturesData)<- FeaturesDataNames$V2

# 3) Merge column
CombineData <- cbind(SubjectData, ActivityData)
Data <- cbind(FeaturesData, CombineData)

# 2.	Extracts only the measurements on the mean and standard deviation for each measurement.

# 2-1 Subset Name of Features by measurements on the “mean” and “standard deviation”
# i.e taken Names of Features with “mean()” or “std()”
subFeaturesDataNames<-FeaturesDataNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesDataNames$V2)]

# 2-2 Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subFeaturesDataNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# 2-3 Check the structures of the data frame Data
str(Data)

# 3.	Uses descriptive activity names to name the activities in the data set

# 3-1 Read descriptive activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(path_unzip, "activity_labels.txt"),header = FALSE)

# 3-2 Facorize Variale activity in the data frame Data using descriptive activity names

# 4.	Appropriately labels the data set with descriptive variable names.

#prefix t is replaced by time
names(Data)<-gsub("^t", "time", names(Data))

# •	Acc is replaced by Accelerometer
names(Data)<-gsub("Acc", "Accelerometer", names(Data))

# •	Gyro is replaced by Gyroscope
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))

# •	prefix f is replaced by frequency
names(Data)<-gsub("^f", "frequency", names(Data))

# •	Mag is replaced by Magnitude
names(Data)<-gsub("Mag", "Magnitude", names(Data))

# •	BodyBody is replaced by Body
names(Data)<-gsub("BodyBody", "Body", names(Data))

# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Create tidy dataset with the average of each variable for each activity and each subject based on the data set in step 4.

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "iTidyData.txt",row.name=FALSE)









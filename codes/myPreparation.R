#Task1
#1.1 Extract the data into an R data frame. 
data <- read.csv("./data/Indian Liver Patient Dataset (ILPD).csv",header = FALSE)

#1.2 Assign the following names to the 11 different columns in your dataset
names(data) <- c("Age","Gender","TB","DB","Alkphos","Sgpt","Sgot","TP","Albumin","AG_Ratio","Class")

#1.3 fill "AG_Ratio" column with the median of this column.
is.na(data$AG_Ratio)
# There are 4 missing values in AG_Ratio.
sum(is.na(data$AG_Ratio))
# Filling them.
data[is.na(data$AG_Ratio),"AG_Ratio"] <- median(data$AG_Ratio,na.rm=T)

#1.4 Replace all “2” in the Class column with “0” to indicate “no_ patient” to be consistent with the convention.
task1_data <- data
task1_data[task1_data$Class == 2,"Class"] <- 0
#1.5 Change the "Class" comlumn type from integer to factor.
task1_data$Class <- as.factor(task1_data$Class)
is.factor(task1_data$Class)

task1_data

saveRDS(task1_data, file="ilpd_processed.Rda")




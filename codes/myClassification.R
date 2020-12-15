#Task 3
set.seed(45)
library("lattice") # Better Graphical function
library("ggplot2") # Data visualization
library("plotly") # Interactive data visualizations
library("psych") # For correlation visualizations
library("rattle") # Graphing decision trees
library("caret") # Machine learning
library("party") # Decision Tree
library("class")
library("hash")

# 3.1 Divide the dataset into “training” and “test” subsets randomly (70% and 30% respectively)
indices <- sample(2, nrow(task1_data),replace = TRUE, prob = c(0.7, 0.3))
train_data <- task1_data[indices == 1,]
test_data <- task1_data[indices == 2,]
dim(train_data)
dim(test_data)

#3.2
#Using correlation matrix to find the important attributes and we can see that TB,DB,Sgpt,Sgot,TP,Albumin and AG_Ratio have strong correlation.
pairs.panels(data[,1:10], scale = TRUE, bg = c("red","green")[data$Class], pch = 21, main = "Correlation Matrix of Data")
#Buliding tree by all attributes with strong correlation.
test_formula <- Class ~ TB+ DB+ Sgpt+ Sgot + TP +Albumin+AG_Ratio
tree_1 <- ctree(test_formula, data = train_data)
plot(tree_1,type = "simple")
testPred1 <- predict(tree_1, test_data)
table(test_data$Class,testPred1 )[2:1,2:1]
#Buliding tree by all attributes with low correlation.
test_formula_2 <- Class ~ Age + Gender + TB + Sgpt + TP +AG_Ratio
tree_2 <- ctree(test_formula_2, data = train_data)
plot(tree_2,type = "simple")
testPred1 <- predict(tree_2, test_data)
table(test_data$Class,testPred1 )[2:1,2:1]
#Using all attributes to build the tree and they have the same precision,recall and accuracy.
my_formula <- Class ~ Age + Gender + TB + DB + Alkphos + Sgpt + Sgot + TP + Albumin + AG_Ratio
task_tree <- ctree(my_formula, data = train_data)
print(task_tree)
plot(task_tree)
plot(task_tree,type = "simple")
#calculate precision, recall and accuracy.
testPred <- predict(task_tree, test_data)
table(test_data$Class,testPred )[2:1,2:1]
#The above 3 trees have the same measures.(sad news)


#3.3
test_tree <- ctree(my_formula, data = train_data, 
                  controls  = ctree_control(testtype = "Teststatistic",minbucket = 17))
print(test_tree)
plot(test_tree,type = "simple")
#predict the test data
Pred <- predict(test_tree, test_data)
table(test_data$Class,Pred)[2:1,2:1]

#3.4 KNN
# convert all factor values to numeric values
train_data$Gender <- as.numeric(train_data$Gender)
test_data$Gender <- as.numeric(test_data$Gender)

evaluation <- function(actual,prediction){
  evaluation <- hash()
  x <- table(prediction,actual)
  .set(evaluation,keys = 'precision',values = posPredValue(x, positive="1"))
  .set(evaluation,keys = 'recall',values = sensitivity(x, positive="1"))
  .set(evaluation,keys = 'F1',values = (2 *  evaluation[['precision']] * evaluation[['recall']]) 
                                        / ( evaluation[['precision']] + evaluation[['recall']]))
  return(evaluation)
}

prediction_knn_1  <- knn(train_data[,-11], test_data[,-11], train_data$Class, k=1, prob=TRUE)
evaluation(test_data$Class,prediction_knn_1)

prediction_knn_2  <- knn(train_data[,-11], test_data[,-11], train_data$Class, k=2, prob=TRUE)
evaluation(test_data$Class,prediction_knn_2)

prediction_knn_3  <- knn(train_data[,-11], test_data[,-11], train_data$Class, k=3, prob=TRUE)
evaluation(test_data$Class,prediction_knn_3)

prediction_knn_4  <- knn(train_data[,-11], test_data[,-11], train_data$Class, k=4, prob=TRUE)
evaluation(test_data$Class,prediction_knn_4)

prediction_knn_5  <- knn(train_data[,-11], test_data[,-11], train_data$Class, k=5, prob=TRUE)
evaluation(test_data$Class,prediction_knn_5)
#We got the highest F1 value when "k" is 4.


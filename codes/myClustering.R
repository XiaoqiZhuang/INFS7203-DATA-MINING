#Task 2
library("lattice") # Better Graphical function
library("ggplot2") # Data visualization
library("plotly") # Interactive data visualizations
library("psych") # For correlation visualizations
library("rattle") # Graphing decision trees
library("caret") # Machine learning
library("party") # Decision Tree
library("class")

#2.1 Load the preprocessed data file from Task 1 into a data frame. 
task2_data <- readRDS(file = 'ilpd_processed.Rda')
task2_data <- task2_data[,3:9]

#2.2 Rescale the values of every column to the range of (0,1).
task2_data <- apply(task2_data, MARGIN = 2, FUN = function(X) (X - min(X))/diff(range(X)))
task2_data <- data.frame(task2_data)


#2.3 Cluster the data into 2 clusters.
clusters_2 <- kmeans(task2_data, 2, nstart = 20)
clusters_2
clusters_num <- as.factor(clusters_2$cluster)
clusters_num
task_2_3 <- ggplot(task2_data, aes(Alkphos, TP, color = clusters_num)) + geom_point()
task_2_3


#2.4 color the points according to the Class column.
task_2_4 <- ggplot(task1_data, aes(Alkphos, TP, color = task1_data$Class)) + geom_point()
task_2_4
#2.5 Compare the 2 plots.
#The clusters from k-means divide the data into upper and lower pieces on these two dimensions. However, the real clusters are interlaced on these two dimensions.

#2.6 k=3,4,5
#k=3
clusters_3 <- kmeans(task2_data, 3, nstart = 20)
clusters_3_num <- as.factor(clusters_3$cluster)
clusters_3_plot <- ggplot(task2_data, aes(Alkphos, TP, color = clusters_3_num)) + geom_point()
clusters_3_plot
#k=4
clusters_4 <- kmeans(task2_data, 4, nstart = 20)
clusters_4_num <- as.factor(clusters_4$cluster)
clusters_4_plot <- ggplot(task2_data, aes(Alkphos, TP, color = clusters_4_num)) + geom_point()
clusters_4_plot
#k=5
clusters_5 <- kmeans(task2_data, 5, nstart = 20)
clusters_5_num <- as.factor(clusters_5$cluster)
clusters_5_plot <- ggplot(task2_data, aes(Alkphos, TP, color = clusters_5_num)) + geom_point()
clusters_5_plot

#2.7 Compare the SSE, S2=43.47,s3=31.96,s4=27.20,s5=23.28
clusters_2$tot.withinss
clusters_3$tot.withinss
clusters_4$tot.withinss
clusters_5$tot.withinss

sse <- list()

for(k in 2:20){
  c <- kmeans(task2_data,k,nstart = 20)
  x <- c$tot.withinss
  sse <- append(sse,x)
}
sse
#From the plot, 6 is the sharp change so the dataset may have 6 clusters.
plot(2:20,sse)


clusters_6 <- kmeans(task2_data, 6, nstart = 20)
clusters_6_num <- as.factor(clusters_6$cluster)
clusters_6_plot <- ggplot(task2_data, aes(Alkphos, TP, color = clusters_6_num)) + geom_point()
clusters_6_plot
clusters_6
#nstart has the same result from 100 to 30
clusters_6_nstart <- kmeans(task2_data, 6, nstart = 100)
#iter.max does not have some impact.
clusters_6_nstart_iter <- kmeans(task2_data, 6, nstart = 30,iter.max = 8)
#compare sse after changing paramaters
clusters_6_nstart$tot.withinss
clusters_6$tot.withinss
clusters_6_nstart_iter$tot.withinss

#2.8
dist <- dist(task2_data,method = "euclidean")
hclusters <- hclust(dist)
hclusters
plot(hclusters,hang=-1) 
rect.hclust(hclusters,k=2,border = 2:3)  
rect.hclust(hclusters,k=3,border = 2:4) 
rect.hclust(hclusters,k=4,border = 2:5) 
rect.hclust(hclusters,k=5,border = 2:6) 
#Cluster validity by Statistical Framework
random_data <- data.frame("TB"=runif(100,min=0,max=1),"DB"=runif(100,min=0,max=1),"Alkphos"=runif(100,min=0,max=1),"Sgpt"=runif(100,min=0,max=1),"Sgot"=runif(100,min=0,max=1),"TP"=runif(100,min=0,max=1),"Albumin"=runif(100,min=0,max=1))
dist_random <- dist(random_data,method = "euclidean")
random_hcluster <- hclust(dist_random)
plot(random_hcluster,hang=-1)


#2.9
#Strategy: Use mds plot to have a global view of all attributes.
#We want to find a new subtype of disease. 
#It also equals that find the kmeans clusters in the hierarchical cluster "1" because "1" means patients and it will have many subtypes and k-means can divide them.

#mds preparation
mds_x = cmdscale(dist)
mds_x = data.frame(mds_x)
xy = cbind(mds_x, task2_data)

#compare with 2 and do not find something.
cu.hclusters_2 <- as.factor(cutree(hclusters,k=2))
ggplot(xy, aes(x=X1,y=X2,colour =  cu.hclusters_num))+geom_point()
ggplot(xy, aes(x=X1,y=X2,colour =  clusters_num))+geom_point()

#compare with 3 and do not find something.
cu.hclusters_3 <- as.factor(cutree(hclusters,k=3))
ggplot(xy, aes(x=X1,y=X2,colour =  cu.hclusters_3))+geom_point()
ggplot(xy, aes(x=X1,y=X2,colour =  clusters_3_num))+geom_point()

#compare with 4. The hierarchical cluster '1' seems to cantain the k-means cluster '1','2','3'.
cu.hclusters_4 <- as.factor(cutree(hclusters,k=4))
ggplot(xy, aes(x=X1,y=X2,colour =  cu.hclusters_4))+geom_point()
ggplot(xy, aes(x=X1,y=X2,colour =  clusters_4_num))+geom_point()
table(clusters_4_num,cu.hclusters_4)

#compare with 5. The hierarchical cluster '1' seems to cantain the k-means cluster '1','2','4'.
#And k-means cluster'4' and '1' are totally be in the hierarchical cluster '1' which I think they are subtypes of diseases.
cu.hclusters_5 <- as.factor(cutree(hclusters,k=5))
ggplot(xy, aes(x=X1,y=X2,colour =  cu.hclusters_5))+geom_point()
ggplot(xy, aes(x=X1,y=X2,colour =  clusters_5_num))+geom_point()
table(clusters_5_num,cu.hclusters_5)

#2.10  the default agglomeration method is "complete" which is MAX.
hc_default <- hclust(dist)
plot(hc_default,hang=-1)
#MIN
hc_min <- hclust(dist,method="single")
plot(hc_min,hang=-1) 
cu.hclusters_min <- cutree(hc_min,k=2)
#0.713
posPredValue(table(cu.hclusters_min,data$Class),positive = '1')

#MAX
hc_max <- hclust(dist,method="complete")
plot(hc_max,hang=-1) 
cu.hclusters_max <- cutree(hc_max,k=2)
#0.711
posPredValue(table(cu.hclusters_max,data$Class),positive = '1')

#AVERAGE
hc_average <- hclust(dist,method="average")
plot(hc_average,hang=-1) 
cu.hclusters_avg <- cutree(hc_average,k=2)
#0.713
posPredValue(table(cu.hclusters_avg,data$Class),positive = '1')

#CENTROID
hc_centroid <- hclust(dist,method="centroid")
plot(hc_centroid,hang=-1) 
cu.hclusters_cen <- cutree(hc_centroid,k=2)
#0.713  
posPredValue(table(cu.hclusters_cen,data$Class),positive = '1')

#Load library
library(RODBC)

#Establish connection with database in SQL Server
myconn <-odbcDriverConnect('Driver={SQL Server}; Server=SERVER_NAME; Database=DB_NAME; Port=1433; PROTOCOL=TCPIP; trusted_connection=yes;UID=USERNAME;PWD=PASSWORD')

#Load data for two different numeric columns in two separate datasets. Add more columns to create smaller subsets 
sites.M1 <- sqlQuery(myconn, 'select column_name, number_column1 from Table where ISNUMERIC(number_column1) = 1')
sites.M2 <- sqlQuery(myconn, "select column_name, number_column2 from Table where ISNUMERIC(number_column2) = 1")

close(myconn)

#Load data in data frames. Add more columns to create smaller subsets
sites.data1 <- data.frame(column_name = as.factor(sites.M1$column_name), metric = c(sites.M1$number_column1))
sites.data2 <- data.frame(column_name = as.factor(sites.M2$column_name), metric = c(sites.M2$number_column2))

library(plyr)
#Use ddply: For each subset of a data frame, apply function then combine results into a data frame
#Calculate median
result.1 <- ddply(sites.data1, .(column_name), summarize, quantiles = quantile(metric, c(.50)))
result.2 <- ddply(sites.data2, .(column_name), summarize, quantiles = quantile(metric, c(.50)))

#Uncomment the following code to get all the percentiles - 10th, 25th, 50th (median), 75th, 90th, and Sample Size
#result.1 <- sites.data1[, .(p10 = quantile(metric, c(.10)), p25 = quantile(metric, c(.25)), median = quantile(metric, c(.50)), p75 = quantile(metric, c(.75)), p90 = quantile(metric, c(.90)), sampleN = .N), by=.(column_name)]
#result.2 <- sites.data2[, .(p10 = quantile(metric, c(.10)), p25 = quantile(metric, c(.25)), median = quantile(metric, c(.50)), p75 = quantile(metric, c(.75)), p90 = quantile(metric, c(.90)), sampleN = .N), by=.(column_name)]

#Combine the data frames into a single data fram
result <- merge.data.frame(result.2, result.1, by = "column_name", all=TRUE)

#Set all nds to a negative integer
result[is.na(res)] <- -99

#Order by column used to merge the data frames
result <- result[order(result$column_name),]
View(result)

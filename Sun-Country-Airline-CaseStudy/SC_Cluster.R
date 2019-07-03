# In this program we will perform clustering on the Sun Country Airlines data

# We will start with the data file SC_data_CleanedUp.csv which was created after data cleanup and pre-processing we discussed 
# in the earlier videos

# We set the working directory using setwd()

setwd("C:/Users/stang/Desktop/BANA 200/R Tool")

# Then we read the data using the read.csv function

data <- read.csv("SC_data_CleanedUp.csv")

# We will be using the dplyr package for data manipulation

install.packages("dplyr")
library(dplyr)

# Let's aggregate up to the customer-trip level.
customer_data<-data%>% 
  group_by(PNRLocatorID,UID)%>%
  summarise(PaxName=first(PaxName),
            BookingChannel=first(BookingChannel), 
            amt=max(TotalDocAmt), 
            UFlyRewards=first(UFlyRewardsNumber), 
            UflyMemberStatus=first(UflyMemberStatus), 
            age_group=first(age_group), 
            true_origin=first(true_origin), 
            true_destination=first(true_destination), 
            round_trip=first(round_trip), 
            group_size=first(group_size), 
            group=first(group), 
            Seasonality=first(Seasonality), 
            days_pre_booked=max(days_pre_booked))

is.data.frame(customer_data)

dim(customer_data)

# Let's remove columns that won't be too useful for clustering, like IDs, names.
clustering_data<-subset(customer_data,select=-c(PNRLocatorID,UID,PaxName,UFlyRewards))

#Let's normalize the data before doing our cluster analysis.
normalize <- function(x){
  return ((x - min(x))/(max(x) - min(x)))
}

clustering_data = mutate(clustering_data,
                         amt = normalize(amt),
                         days_pre_booked = normalize(days_pre_booked), 
                         group_size=normalize(group_size))

# The K-Means clustering algorithm works only with numerical data

# For categorical data, we need to convert each of the factor levels into numerical 1/0 dummy variables

# We will be using the ade4 package for converting categorical data into numerical dummy variables

install.packages("ade4")
library(ade4)

# The example below shows how the acm.disjonctif() function of the ade4 package can be 
# used to convert categorical variables into dummy variables

# library(ade4)
# df <-data.frame(eggs = c("foo", "foo", "bar", "bar"), ham = c("red","blue","green","red"))
# acm.disjonctif(df)
#   eggs.bar eggs.foo ham.blue ham.green ham.red
# 1        0        1        0         0       1
# 2        0        1        1         0       0
# 3        1        0        0         1       0
# 4        1        0        0         0       1

clustering_data <- as.data.frame(clustering_data)
clustering_data <-  clustering_data %>% 
  cbind(acm.disjonctif(clustering_data[,c("BookingChannel","age_group",
                                          "true_origin","true_destination","UflyMemberStatus","seasonality")]))%>% 
  ungroup()

#Remove the original (non-dummy-coded) variables
clustering_data<-clustering_data %>%select(-BookingChannel,-age_group,-true_origin,-true_destination,-UflyMemberStatus,-seasonality)

#Now run k-Means and look at the within SSE curve; 3 - 5 seems like the best solution here...

SSE_curve <- c()
for (n in 1:15) {
  kcluster <- kmeans(clustering_data, n)
  sse <- sum(kcluster$withinss)
  SSE_curve[n] <- sse
}

SSE_curve

print("SSE curve for the ideal k value")
plot(1:15, SSE_curve, type="b", xlab="Number of Clusters", ylab="SSE")

#Let's go with 5 clusters ...

kcluster<- kmeans(clustering_data, 5)

names(kcluster)

print("the size of each of the clusters")
kcluster$size

#Let's add a new column with the cluster assignment, which we will call "Segment", 
# for each observation in customer_data

segment<-as.data.frame(kcluster$cluster)

colnames(segment) <- "Segment" 

customer_segment_data <- cbind.data.frame(customer_data, segment)

write.csv(customer_segment_data, "SC_customer_segment_data.csv")


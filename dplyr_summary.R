# This program provides a summary of the dplyr package in R

# It is based on https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html

# We start by installing the dplyr package

install.packages("dplyr")
library(dplyr)

# Next we install the package nycflights13, which contains data on all flights that departed New York City in 2013

install.packages("nycflights13")
library(nycflights13)

# Use the dim function to see the dimensons of the data frame

dim(flights)

flights

# The head() function displays the top 6 rows of the data frame

head(flights)

# Here are the basic data manipulation operations in dplyr

#   filter() to select rows based on attribute values.
#   arrange() to reorder the rows, based on specified criteria.
#   select() and rename() to select variables based on their names.
#   mutate() and transmute() to add new variables that are functions of existing variables.
#   summarise() to condense multiple values to a single value.
#   sample_n() and sample_frac() to take random samples of the data set.


filter(flights, month == 1, day == 1)
arrange(flights, year, month, day)

# The following arranges the data frame in descending order of arr_delays

arrange(flights, desc(arr_delay))

# Here are two ways of selecting just the year, month and day columns

select(flights, year, month, day)
select(flights, year:day)

# Here we select all but the year, month and day columns
select(flights, -(year:day))

select(flights, tail_num = tailnum)

# rename keeps all the columns, changing the name of the column tailnum to tail_num

rename(flights, tail_num = tailnum)

# mutate allows you to add new columns (variables) that are functions of existing columns (variables)

mutate(flights, 
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
       )

# Use transmute if you only want to keep the new variaables

transmute(flights,
          gain = arr_delay - dep_delay,
          gain_per_hour = gain / (air_time / 60)
          )

# summarize allows you to collapse a data frame into a single row

summarise(flights,
          delay = mean(dep_delay, na.rm = TRUE)
          )

# Here is a summarization of the the number of flights per year, per month and per day, respectively

daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))

(per_month <- summarize(per_day, flights = sum(flights)))

(per_year <- summarise(per_month, flights = sum(flights)))

# sample_n and sample_frac allow you to random sample a fixed number of rows or a fixed fraction of rows, respectively

sample_n(flights, 10)

sample_frac(flights, 0.01)

# The function group_by breaks down a data frame into groups of rows, than allows you to apply data operations "by group"

by_tailnum <- group_by(flights, tailnum)

delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))

delay <- filter(delay, count > 20, dist < 2000)

delay

# Now, here is a summarization of the number of planes and the number of flights by destination

destinations <- group_by(flights, dest)
summarise(destinations,
          planes = n_distinct(tailnum),
          flights = n()
)

# Now we will do some data visualization using the package ggplot2
# A quick summary for ggplot2 is available in Chapter 3 of the eBook R for Data Science: http://r4ds.had.co.nz/data-visualisation.html

install.packages("ggplot2")
library(ggplot2)

# We will now create a scatter plot of delay versus dist, where the size of the point is proportional to the count of the number of flights
# The ggplot function first specifies the data frame (delay in this case)
# aes stands for "aesthetic mappings"
# Layers are added in turn to the plot. In this case we add a scatter plot using geom_point and a smoothed line to fit the data using geom_smooth
# scale_size_area scales the size of the plot, ensuring that a count of 0 is mapped to a size of 0

ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()







  
  
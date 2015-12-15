# Based on YT video 'Hands-on Tutorial Dplyr Tutorial for Faster Data Manipulation in R'
# https://www.youtube.com/watch?v=jWjqLW-u3hc 

# 5 basic verbs:
# filter
# select
# arrange
# mutate
# summarize
# puls 'group by'

# load dplyr and data
library(dplyr)
library(hflights)

# explore data
data("hflights")
str(hflights)

# 'tbl_df' creates 'local data frame' that prints nicer
flight <- tbl_df(hflights)
flight
head(flight)

#### dplyr
## FILTER rows
# base r approach for filtering rows 
flight[flight$Month==1 & flight$DayofMonth==1,]
# dplyr filter - comma or ampersand for AND
filter(flight, Month==1, DayofMonth==1)
# pipe for OR
filter(flight, UniqueCarrier=="AA"|UniqueCarrier=="UA")
# find rows with na - looks like there are none
filter(flight,is.na(FlightNum)) # use !is.na to exclude na rows


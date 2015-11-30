# Based on YT video 'Hands-on Tutorial Dplyr Tutorial for Faster Data Manipulation in R'
# https://www.youtube.com/watch?v=jWjqLW-u3hc 
# as well as:
# http://genomicsclass.github.io/book/pages/dplyr_tutorial.html 

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
# match? would love to know how to get partial match, such as 'N5...'
filter(flight, TailNum %in% c("N565AA","N576AA"))
filter(flight, TailNum %in% "N565AA")
# >=
filter(flight, DepTime >=1400)

# boolean
# ==, >, <, >=, <=,!=,%in%

## SELECT columns
fcols <- select(flight,UniqueCarrier,DepDelay,Cancelled,Diverted)
fcols
# unselect columns with -
fcols2 <- select(flight,-UniqueCarrier,-DepDelay,-Cancelled,-Diverted)
fcols2
# range of cols
fcols3 <- select(flight,Year:DepTime)
fcols3
# use chr string
head(select(flight,starts_with("D")))
# additional select options:
# ends_with() - end with chr string
# contains() - contain chr string
head(select(flight,contains("Time")))
# matches() - match regex
# one_of() - names from a group of names (?)

## Piping: %>%
# allows to string functions from left to right for readability, rather than nested
# instead of...
head(select(flight,Year:DepTime))
# the more logical-flowing left-right
flight %>% select(Year:DepTime) %>% head

## ARRANGE order of rows
flight %>% arrange(FlightNum) %>% head

# Based on YT video 'Hands-on Tutorial Dplyr Tutorial for Faster Data Manipulation in R'
# https://www.youtube.com/watch?v=jWjqLW-u3hc 
# as well as:
# http://genomicsclass.github.io/book/pages/dplyr_tutorial.html 
# other:
# Hadley Wickham (1 of 2 - 50 min): https://www.youtube.com/watch?v=8SGif63VW6E 
# Roger Peng: https://www.youtube.com/watch?v=aywFompr1F4 

# 5 basic verbs (lower case):
# FILTER
# SELECT
# ARRANGE
# MUTATE
# SUMMARIZE
# plus 'GROUP_BY' and 'RENAME'

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
summary(flight)

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
filter(flight,is.na(ArrTime))
filter(flight,!is.na(ArrTime))
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

# RENAME: renames columns
fcarrier <- rename(flight,carrier=UniqueCarrier)
fcarrier <- rename(fcarrier,Yr=Year,Mth=Month,Mthd=DayofMonth,Weekday=DayOfWeek)
names(fcarrier)

## Piping: %>%
# allows to string functions from left to right for readability, rather than nested
# instead of...
head(select(flight,Year:DepTime))
# the more logical-flowing left-right
flight %>% select(Year:DepTime) %>% head

## ARRANGE order of rows aka 'sort'
flight %>% arrange(FlightNum) %>% head
# piping together select cols then arrange (sort) on multiple rows, then filter, 
# then show head
flight %>% 
  select(Year,Month,DayofMonth,DepTime,FlightNum) %>%
  arrange(FlightNum,DepTime) %>%
  filter(DepTime>1200) %>%
  head
# as above but descend sort on Flightnum
flight %>% 
  select(Year,Month,DayofMonth,DepTime,FlightNum) %>%
  arrange(desc(FlightNum),DepTime) %>%
  filter(DepTime>1200) %>%
  head

## MUTATE new cols
# add col to calc flight time (not actually accurate due to 60 min in hr)
flight %>%
  mutate(ftime=ArrTime-DepTime) %>%
  select(FlightNum,DepTime,ArrTime,ftime)
  head
# multiple new cols at once - calc speed (demonstration, not nec. accurate)
flight %>%
  mutate(ftime=ArrTime-DepTime, speed=Distance/(AirTime/60)) %>%
  select(FlightNum,DepTime,ArrTime,ftime,AirTime,Distance,speed)
head

## SUMMARISE to create summaries for a given col
# get the mean for AirTime, removing NA first
flight %>%
  filter(!is.na(AirTime)) %>%
  summarise(avgairtime=mean(AirTime))
flight %>%
  filter(!is.na(AirTime)) %>%
  summarise(avgairtime=mean(AirTime),
            maxairtime=max(AirTime),
            minairtime=min(AirTime),
            totalairtime=sum(AirTime),
            totalcount=n())

## GROUP BY specified dimension (as in SQL)
flight %>%
  filter(!is.na(AirTime)) %>%
  group_by(UniqueCarrier) %>%
  summarise(avgairtime=mean(AirTime),
            maxairtime=max(AirTime),
            minairtime=min(AirTime),
            totalairtime=sum(AirTime),
            totalcount=n())



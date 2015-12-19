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
library(hflights) # requires hflights package
# considered writing to csv to store with project, but 20MB!
# write.csv(hflights,"hflight.csv")

# explore data
data("hflights")
str(hflights)

# 'tbl_df' creates 'local data frame' that prints nicer
flight <- tbl_df(hflights)
flight
head(flight)
summary(flight)
# convert year, month, dayofmonth cols into single date
flight$date <- as.Date(paste(flight$Year,flight$Month,flight$DayofMonth,sep="-"),format="%Y-%m-%d")
str(flight)


#### dplyr !!!!
## FILTER rows
# base r approach for filtering rows 
flight[flight$Month==1 & flight$DayofMonth==1,]
# dplyr filter
# a|b, a&b, a&!b
# comma or ampersand for AND
filter(flight, Month==1, DayofMonth==1)
filter(flight,date>"2011-06-01",date<"2011-06-15")
# pipe for OR
filter(flight, UniqueCarrier=="AA"|UniqueCarrier=="UA")
filter(flight,Dest %in% c("SFO","Oak"))
# %in% for OR (exact match only)
sfo_or_oak <- filter(flight,Dest %in% c("SFO","OAK"))
# flights where arrival delay is more than twice the departure delay
del <- filter(flight,ArrDelay > 2*DepDelay,DepDelay>0)

# find rows with na - looks like there are none
filter(flight,is.na(FlightNum)) # use !is.na to exclude na rows

# match 
filter(flight, TailNum %in% c("N565AA","N576AA"))
filter(flight, TailNum %in% "N565AA")
# match - partial
filter(flight,grepl("N5",TailNum))
filter(flight,!grepl("N576",TailNum))
# >=
filter(flight, DepTime >=1400)
filter(flight,is.na(ArrTime))
filter(flight,!is.na(ArrTime))
# boolean
# ==, >, <, >=, <=,!=,%in%


## SELECT columns
# , : c
# starts_with(x, ignore.case=TRUE)
# ends_with(x, ignore.case=TRUE)
# contains(x, ignore.case=TRUE) 
# matches(x,ignore.case=TRUE) match regex
# num_range("x",1:5, width=2)
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
# order flights by departure date, time, and flight number
flight %>% 
  select(Year,Month,DayofMonth,DepTime,FlightNum) %>%
  arrange(FlightNum,DepTime) %>%
  filter(DepTime>1200) %>%
  head
# as above but descend (desc) sort on Flightnum
flight %>% 
  select(Year,Month,DayofMonth,DepTime,FlightNum) %>%
  arrange(desc(FlightNum),DepTime) %>%
  filter(DepTime>1200) %>%
  head
# which were most delayed?
arrange(flight,desc(ArrDelay)) %>% select(UniqueCarrier,FlightNum,ArrDelay,Dest,Distance) %>% head
# which flights caught up the most?
arrange(flight,desc(DepDelay-ArrDelay)) %>% select(date,DepDelay,ArrDelay)


## MUTATE new cols that are functions of existing variables

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

## GROUP BY specified dimension and SUMMARIZE on that dimension (as in SQL)
flight %>%
  filter(!is.na(AirTime)) %>%
  group_by(UniqueCarrier) %>%
  summarise(avgairtime=mean(AirTime),
            maxairtime=max(AirTime),
            minairtime=min(AirTime),
            totalairtime=sum(AirTime),
            totalcount=n())

# SUMMARISE OPERATIONS




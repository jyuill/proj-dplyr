# Based on YT video 'Hands-on Tutorial Dplyr Tutorial for Faster Data Manipulation in R'
# https://www.youtube.com/watch?v=jWjqLW-u3hc 
# as well as:
# http://genomicsclass.github.io/book/pages/dplyr_tutorial.html 
# other:
# Hadley Wickham (1 of 2 - 50 min): https://www.youtube.com/watch?v=8SGif63VW6E 
# Roger Peng: https://www.youtube.com/watch?v=aywFompr1F4 
# also:
browseVignettes(package="dplyr") 

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


###### dplyr !!!!#####

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
# can also rename directly within SELECT
fcarrier2 <- select(flight,airline=UniqueCarrier, destination=Dest)

## PIPING: %>%...equivalent of 'then'
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
# some little trick to break out larger number into smaller components 
mutate(flightspeed, hour = DepTime %/% 100, min = DepTime %% 100) %>% select(date,DepTime,hour,min)

## SUMMARISE to create summaries for a given col
# min(x), median(x), max(x), quantile(x,p)
# n(x), n_distinct(x), sum(x), mean(x)
# sum(x >10), mean(x>10)
# sd(x2 var(x), iqr(x), mad(x)

# first use group_by
by_date <- group_by(flight,date)
head(by_date)
# summarize by various stats, filtering each one for no na
summarise(filter(by_date),
          med=median(DepDelay, na.rm=TRUE),
          max=max(DepDelay, na.rm=TRUE),
          q90=quantile(DepDelay,0.9, na.rm=TRUE))
# same idea as above but filtering variable for na upfront
summarise(filter(by_date,!is.na(DepDelay)),
          med=median(DepDelay),
          mean=mean(DepDelay),
          m15=mean(DepDelay>15)) # mean for departure delays more than 15 min (?)

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

# which destinations have highest average delays?
late_destinations <- flight %>% 
  filter(!is.na(ArrDelay)) %>% # remove na
  group_by(Dest) %>% # group by destination
  summarise(med=median(ArrDelay),mean = mean(ArrDelay), q80=quantile(ArrDelay,0.8),n=n()) %>% # summarize desired variables
  filter(n>100) %>% # exclude those destinations with less than 100 flights in the dataset
  arrange(desc(mean)) # show data in descending order  of average arrival delay

# which flights fly every day?
flight %>%
  group_by(UniqueCarrier, FlightNum) %>% # group by airline, flight number
  summarise(n=n_distinct(date)) %>% # count number of distinct dates for each item in the group
  filter(n==365) # filter for those with 365 distinct dates (1 per day of year)

planes <- flight %>%
  filter(!is.na(ArrDelay)) %>%
  group_by(TailNum) %>%
  filter(n()>30) %>%
  arrange(TailNum)

planes %>%
  mutate(z_delay= (ArrDelay - mean(ArrDelay))/sd(ArrDelay)) %>%
  filter(z_delay >5) %>%
  select(date,UniqueCarrier,TailNum,ArrDelay,z_delay)

planes %>%
  filter(min_rank(ArrDelay) <5) # top four least delayed flights for each plane

# Window functions
# aggregate: n inputs > 1 output
# Window: n inputs > n outputs
#   ranking functions - deal with ties differently
min_rank(c(1,1,2,3)) # ranks as 1,1,3,4
dense_rank(c(1,1,2,3)) # ranks as 1,1,2,3
row_number(c(1,1,2,3)) # ranks as 1,2,3,4

# lead and lag -> comparing differences from one row to other
daily <- flight %>%
  group_by(date) %>%
  summarise(delay=mean(ArrDelay, na.rm=TRUE))

# calc difference between one observation and teh previous
# maintains same number of rows as original number of observations
# first item defaults to 'NA' but can be set or '0' or whatever (somehow - check help)
daily %>% mutate(delay-lag(delay))
# use order_by to ensure lag calculated properly even if rows not sorted by how you want to calc lag
daily %>% mutate(dlag=delay-lag(delay, order_by=date))

## JOINS - TWO-TABLE VERBS - typically not just one table for analysis
# get list and count of airports (destinations) - just exercise - real data below with long/lat
arprt <- flight %>% select(Dest) %>% group_by(Dest) %>% summarise(total=n())
# list only
arprt2 <- flight %>% select(Dest) %>% group_by(Dest) %>% summarise()

# more complete list, with longitude and latitude
library(nycflights13) # contains data for airlines, airports, flights, planes, weather
str(airports)
head(weather)

location <- airports %>% select(Dest=faa, airport=name,lat,lon)

# which destinations have the highest average delays?
delays <- flight %>% 
  group_by(Dest) %>%
  summarise(ArrDelay=mean(ArrDelay,na.rm=TRUE), n=n()) %>%
  arrange(desc(ArrDelay))

# same as above but with lat/lon from other table
delays <- flight %>% 
  group_by(Dest) %>%
  summarise(ArrDelay=mean(ArrDelay,na.rm=TRUE), n=n()) %>%
  arrange(desc(ArrDelay)) %>%
  left_join(location) # join to location data on 'Dest' -> automatically identifies join variable
View(delays)

# plot on map - easy! :)
library(ggplot2)
library(maps)
ggplot(delays,aes(lon,lat)) +
  borders("state") +
  geom_point(aes(colour=ArrDelay),size=5,alpha=0.9)+
  scale_colour_gradient2() +
  coord_quickmap()

instrument <- data.frame(name=c("John","Paul","George","Ringo","Stuart","Pete"),
                         instrument=c("guitar","bass","guitar","drums","bass","drums"))
band <- data.frame(name=c("John","Paul","George","Ringo","Reg","Eric"),
                   band=c("TRUE","TRUE","TRUE","TRUE","FALSE","FALSE"))

inner_join(instrument,band) # 'natural' join -> all items in both tables
left_join(instrument,band) # all items in left table with missing values when no matching data in othe
semi_join(instrument,band) # gets rows in left that match rows in right
anti_join(instrument,band) # gets rows in left that don't match rows in right

## JOIN delay data to weather data
# add hour variable
flight <- flight %>% mutate(hour = DepTime %/% 100) # use trick from line 145 above to get hour variable

# delays in departure by date and hour
hourly_delay <- flight %>%
  group_by(date,hour) %>%
  filter(!is.na(DepDelay)) %>%
  summarise(delay = mean(DepDelay), n=n()) %>%
  filter(n>10)
View(hourly_delay)

# check weather data in nycflights13 for date and hour variable
head(weather)
# add date variable as done early for flight data on line 33 (new dataframbe just to stay clean)
w2 <- weather
w2 <- mutate(w2,year2=year-2) # have to shift year data to 2011 to match flight data
w2$date <- as.Date(paste(w2$year2,w2$month,w2$day,sep="-"),format="%Y-%m-%d")
head(w2)
summary(w2)
# need to have unique rows for each date/hr - there may be multiple weather locations in weather data
w2 %>% group_by(origin) %>% summarize(total=n())
# filter for predominant location (for purposes of exercise)
wEWR <- w2 %>% filter(origin=="EWR")

# join date and hour delay data with weather for that date and hour
delay_weather <- hourly_delay %>% left_join(wEWR)

# explore data to see if weather accounts for delays (demo: won't really work because:
# houston flight data and nyc weather data)
qplot(temp,delay,data=delay_weather)
qplot(wind_speed,delay,data=delay_weather)
qplot(visib,delay,data=delay_weather)
qplot(wind_gust,delay,data=delay_weather)

## DO
# general purpose verb - slow but applies widely

## DATABASES
# also works with db datasources
# MySQL, BigQuery
# SQLite - comes with R
# dplyr translates the R commands into SQL
# SQL learning:
# - Learn how to use SELECT
#   - tech.pro/tutorial/1555/10-easy-steps-to-a-complete-understanding-of-sql (nat available)
#   - [alt] http://blog.csdn.net/dgly1611/article/details/18355593 
# - Learn Indices: www.sqlite.org/queryplanner.html

## LEARN MORE DPLYR
browseVignettes(package="dplyr")

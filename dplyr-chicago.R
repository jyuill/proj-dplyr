### DPLYR with Chicago Temperature Data
## Roger Peng lesson: https://www.youtube.com/watch?v=aywFompr1F4 
## data retrieved from: https://github.com/DataScienceSpecialization/courses/tree/master/03_GettingData/dplyr
library(dplyr)

chicago <- readRDS("chicago.rds")

str(chicago)
summary(chicago)
head(chicago)

library(ggplot2)
qplot(date,tmpd,data=chicago)

# some things to do with dplyr:
# separate date out to year and month and maybe day
# group_by month and summarize based on mean
# convert temps from fahrenheit to celsius (mutate)
# change column names to be more readable

library(lubridate)
# use lubridate to extract month and year from date
chicagomy <- chicago %>% mutate(month=month(date), year=year(date))
chicagomy$month <- as.factor(chicagomy$month) # convert month from numeric to factor
# (optional) create temp table and filter out any NA values in temp
chitemp <- select(chicagomy,tmpd,date,month,year) %>% filter(!is.na(tmpd))
# boxplot by month
qplot(month,tmpd,data=chitemp,geom="boxplot")


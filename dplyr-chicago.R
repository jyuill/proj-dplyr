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
# boxplot for monthly temprature range (fahrenheit)
qplot(month,tmpd,data=chitemp,geom="boxplot")

# convert fahrenheit to celsius = 5/9(f-32)
chitempc <- chitemp %>% mutate(tempc=5/9*(tmpd-32))
write.csv(chitempc,"chicagotempcelsius.csv", row.names = FALSE)
# boxplot by month -> celsius
qplot(month,tempc,data=chitempc,geom="boxplot")+theme_bw(base_size = 16) +
  xlab("Month of Year") +
  ylab("Temperature Range During Month") +
  geom_hline(yintercept=0, linetype=2) +
  scale_y_continuous(limits=c(-30,35),breaks=seq(-30,30,10)) +
  scale_x_discrete(breaks=seq(1,12,1))
qplot(month,tempc,data=chitempc,geom="boxplot")+ theme_classic(base_size=16) +
  xlab("Month of Year") +
  ylab("Temperature Range During Month") +
  geom_hline(yintercept=0, linetype=2) +
  scale_y_continuous(limits=c(-30,35),breaks=seq(-30,30,10)) +
  scale_x_discrete(breaks=seq(1,12,1))
qplot(month,tempc,data=chitempc,geom="boxplot")+ theme_grey(base_size=16) +
  xlab("Month of Year") +
  ylab("Temperature Range During Month") +
  geom_hline(yintercept=0, linetype=2) +
  scale_y_continuous(limits=c(-30,35),breaks=seq(-30,30,10)) +
  scale_x_discrete(breaks=seq(1,12,1))

qplot(month,tempc,data=chicagotempcelsius,geom="boxplot")+ theme_classic(base_size=16) +
  xlab("Month of Year") +
  ylab("Temperature Range During Month") +
  geom_hline(yintercept=0, linetype=2) +
  scale_y_continuous(limits=c(-30,35),breaks=seq(-30,30,10)) +
  scale_x_discrete(breaks=seq(1,12,1))

str(chicagotempcelsius)
chicagotempcelsius$month <- as.factor(chicagotempcelsius$month)

# daily line chart for all tempc data
qplot(date,tempc,data=chitempc,geom = "line")

# group daily data to get average for month
chicagomth <- group_by(chitempc, month) %>%
  summarize(avetempc=mean(tempc),
            mintempc=min(tempc),
            maxtempc=max(tempc))
write.csv(chicagomth,"chicagomthlytemp.csv")
# various ggplots showing ave mthly temp - bar works best
qplot(month,avetempc,data=chicagomth, geom="line", group=1) + theme_bw(base_size=16)
ggplot(data=chicagomth,aes(x=month,y=avetempc, group=1)) + geom_line()
ggplot(data=chicagomth,aes(x=month,y=avetempc),group=1) + geom_bar(stat="identity") + theme_bw(base_size=16)
# taking a look at min temps...
ggplot(data=chicagomth,aes(x=month,y=mintempc)) + geom_bar(stat="identity") + 
  theme_classic(base_size=16) +
  xlab("Month of the Year") +
  ylab("Lowest Temperate for the Month") +
  scale_x_discrete(breaks=seq(1,12,1))

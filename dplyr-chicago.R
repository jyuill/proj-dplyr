### DPLYR with Chicago Temperature Data
## Roger Peng lesson: https://www.youtube.com/watch?v=aywFompr1F4 
## data retrieved from: https://github.com/DataScienceSpecialization/courses/tree/master/03_GettingData/dplyr
chicago <- readRDS("chicago.rds")

str(chicago)
summary(chicago)
head(chicago)

# some things to do with dplyr:
# separate date out to year and month and maybe day
# group_by month and summarize 
# convert temps from fahrenheit to celsius (mutate)
# change column names to be more readable
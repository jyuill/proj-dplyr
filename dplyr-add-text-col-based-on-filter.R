### USING DPLYR TO FILTER FOR VARIABLE CRITERIA AND CREATE NEW COL WITH CORRESPONDING TAG
## Use case is categorizing diverse values in a variable
## example: list of page URLs that can be categorized by a folder name

## Case: tweet data with a bunch of hashtags where it is desired to categorized tags

# read in data from table and view to see content (table already in folder)
entity_hash <- read.csv("entity_hashtag.csv", sep=",")
View(entity_hash)

# dplyr!
library(dplyr)
# create separate tables for each item that you want to filter and apply appropriate tag category
# grepl is used for partial matching - would be simpler if you could do exact matches, but rarely works out that way
entity_hash1 <- filter(entity_hash,grepl("advanced",hashtag,ignore.case = TRUE)) %>% mutate(tagcat="cod")
entity_hash2 <- filter(entity_hash,grepl("day",hashtag, ignore.case = TRUE)) %>% mutate(tagcat="day")
entity_hash3 <- filter(entity_hash,grepl("des",hashtag,ignore.case=TRUE)) %>% mutate(tagcat="des")
entity_hash4 <- filter(entity_hash,grepl("ps",hashtag,ignore.case = TRUE)|grepl("xb",hashtag,ignore.case = TRUE)) %>% 
  mutate(tagcat="con")
entity_hash5 <- filter(entity_hash,grepl("cod",hashtag, ignore.case = TRUE)) %>% mutate(tagcat="cod")
# create table of rows that don't contain above search terms
entity_hashnot <- filter(entity_hash,!grepl("advanced",hashtag,ignore.case = TRUE),
                       !grepl("day",hashtag, ignore.case = TRUE),
                       !grepl("des",hashtag, ignore.case = TRUE),
                       !grepl("ps", hashtag, ignore.case = TRUE),
                       !grepl("xb", hashtag, ignore.case = TRUE),
                       !grepl("cod", hashtag, ignore.case = TRUE)
) %>% mutate(tagcat="oth")

# recombine all the separate tables -> should be same number of rows as original
entity_hashcat <- rbind(entity_hash1,
                      entity_hash2,
                      entity_hash3,
                      entity_hash4,
                      entity_hash5,
                      entity_hashnot)

### No doubt there are more efficient solutions...but this one works and is quite versatile,
#   if not super-scalable

######################################################
##         Web scrape college football data
#               Ryan Berger 1-15-18
# 
# This script scrapes data for the 2017 college football season
# from sports-reference.com.
#    
######################################################

library(rvest)
library(stringr)
library(tidyr)

# We use the read_html function to read a web page. This function is provided by the xml2 package, which was loaded automatically when we loaded rvest.
url <- 'https://www.sports-reference.com/cfb/years/2017-ratings.html'
webpage <- read_html(url)

# Next, we use the functions html_nodes and html_table (from rvest) to extract the HTML table element and convert it to a data frame.
ref_table <- html_nodes(webpage, 'table')
ref <- html_table(ref_table,header = TRUE, fill = TRUE, dec = '.',trim = TRUE)[[1]]
head(ref)

# Remove rows, fix header
ref <- ref[-c(22,23,44,45,66,67,88,89,110,111,132,133),]
colnames(ref) <- ref[1,]
ref<- ref[-1,]
colnames(ref)[c(7,9,11,13,8,10,12,14)] <- c('Scoring Off','Passing Off','Rushing Off','Total Off','Scoring Def','Passing Def','Rushing Def','Total Def')

# Convert data columns to numeric
ref[,4:14] <- lapply(ref[,4:14], as.numeric)

# Trying to separate conference divisions from conference but can't figure it out
# separate doesn't like working with parentheses and extract is giving error messages
# extract(ref, Conf, into = c('Conference'),regex =  "()")
# ?extract
# ref <- separate(ref, Conf, c('Conference','Division'),sep = '(',remove = TRUE)
# head(fpi)
# ?separate


# Look at distribution of team ratings
hist(ref$SRS,
     main = 'NCAA football team strength\n using sportsreference.com data',
     xlab = 'Simple Rating System',
     col = 'slategray')

# Look at scatterplot of team offense vs defense ratings
plot(ref$OSRS, ref$DSRS,
     main = 'NCAA football defense vs offense comparisons',
     xlab = 'Offense Rating',
     ylab = 'Defense rating',
     col = 'navyblue')



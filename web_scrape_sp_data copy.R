################################################################
#
#      Web scraping current SP+ data from footballoutsiders.com
#
#                          By Ryan Berger
#                            12-18-2017
#                         R version 3.3.2
#
#      Purpose: Scrape the most recent SP+ data, convert into a  
#               dataframe, and save as a csv file.
#     
#      Adapted from David Radcliffe (https://rpubs.com/Radcliffe/superbowl)
################################################################

install.packages('rvest')
install.packages('stringr')
install.packages('tidyr')

library(rvest)
library(stringr)
library(tidyr)

# We use the read_html function to read a web page. This function is provided by the xml2 package, which was loaded automatically when we loaded rvest.
url <- 'http://www.footballoutsiders.com/stats/ncaa'
webpage <- read_html(url)

# Next, we use the functions html_nodes and html_table (from rvest) to extract the HTML table element and convert it to a data frame.
sp_table <- html_nodes(webpage, 'table')
sp <- html_table(sp_table,header = TRUE)[[1]]
head(sp)

#Remove the extra column titles in the chart. These show up every 25 rows
sp <- sp[-c(26,52,78,104),]
sp[26,]

# 3 columns have same title (Rk). Change the names of the rank columns to prevent error 
colnames(sp)[6] <- 'sp rank'
colnames(sp)[8] <- 'off rank'
colnames(sp)[10] <- 'def rank'

# Separate wins and losses 
sp <- separate(sp, Rec., c('W','L'),sep = '-',remove = TRUE)
head(sp)

#Remove % sign from percentile
sp$`S&P+(Percentile)` <- as.numeric(sub('%', '', sp$`S&P+(Percentile)`))
class(sp$`S&P+(Percentile)`)

# Separate 2nd order wins and differential
# Rename column first
colnames(sp)[4] <- 'second_order_w'
sp <- separate(sp, second_order_w, c('second_order_w','Differential'),sep = ' ', remove = TRUE)
head(sp)

# Make all columns except team name numeric data instead of character
sp[,2:4] <- lapply(sp[,2:4], as.numeric)
?lapply
# Calculate 2nd order win differential. Do this before making column numeric or you'll get NA for everything 
sp$Differential <- sp$second_order_w - sp$W

# Continue making columns numeric
sp[,5:15] <- lapply(sp[,5:15], as.numeric)

# Save scrape as CSV file with date 
current_date <- Sys.Date()
csv_filename <- paste('/Users/rberger/Desktop/My files/College football analysis/SP data scrapes/SPdata',current_date,'.csv')
write.csv(sp, file = csv_filename, row.names = FALSE, na = "")

# Clean up
rm(sp_table,url,webpage,sp,csv_filename,current_date)

# Done


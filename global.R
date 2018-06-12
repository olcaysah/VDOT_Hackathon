# Author: Olcay Sahin
# Date: Tue Apr 17 12:36:59 2018
# Author: osahi001@odu.edu
# Project: Hackaton Toll
# Info: Download real time or historic toll data
# --------------

library(shiny)
library(leaflet)
library(jsonlite)
library(RCurl)
library(plyr)
library(readr)
library(data.table)

dest <- read_csv('entrypoints.csv')
keys <- read_csv('keys.csv')


tollParse <- function(origin = "Bishop O'Connell High School, Little Falls Road, Arlington, VA",
                      destination = "White house washington dc"){
  

url <- function(return.call = "json", origin = "White house washington dc", destinations = "Westlawn Elementary School", avoid = NULL, apikey = keys$key[1]) {
  units = 'imperial'
  root <- "https://maps.googleapis.com/maps/api/distancematrix/"
  u <- paste0(root, return.call, "?units=", units, "&origins=", origin, "&destinations=",destinations, "&key=", apikey, "&avoid=", avoid)
  return(URLencode(u))
}

ebEnter <- paste(dest$lat[dest$direction=='E'&dest$state=='entry'],dest$lng[dest$direction=='E' &dest$state=='entry'], sep = ' ', collapse = '|')
ebEnterid <- dest$id[dest$direction=='E'&dest$state=='entry']
ebEnterzoneid <- dest$zoneid2[dest$direction=='E'&dest$state=='entry']

step1 <- url(origin = origin, destinations = ebEnter, avoid = 'highways')
doc <- getURL(step1)
x <- fromJSON(doc, simplifyVector =  F)

dfEnter <- data.frame(id=NULL, zoneid=NULL,ori=NULL,dest = NULL, dist_text = NULL, dist_num = NULL, dur_text=NULL, dur_num=NULL, state=NULL)
# lazy version of extracting data from json
for (i in 1:length(x$destination_addresses)) {
  
  destin <- x$destination_addresses[[i]]
  dist_text <- x$rows[[1]]$elements[[i]]$distance$text
  dist_num <- x$rows[[1]]$elements[[i]]$distance$value
  dur_text <- x$rows[[1]]$elements[[i]]$duration$text
  dur_num <- x$rows[[1]]$elements[[i]]$duration$value
  dfEnter <- rbind(dfEnter, data.frame(id=ebEnterid[i],zoneid=ebEnterzoneid[i],ori=origin,dest = destin, dist_text = dist_text, dist_num = dist_num, dur_text=dur_text, dur_num=dur_num, state='Entry'))
}
zid <- dfEnter$zoneid[which.min(dfEnter$dist_num)]
ebExit <- paste(dest$lat[dest$direction=='E'&dest$state=='exit' & dest$zoneid2 >= zid],dest$lng[dest$direction=='E' &dest$state=='exit' & dest$zoneid2 >= zid], sep = ' ', collapse = '|')

step2 <- url(origin = ebExit, destinations = destination, avoid = 'highways')
ebExitid <- dest$id[dest$direction=='E'&dest$state=='exit'& dest$zoneid2 >= zid]
ebExitzoneid <- dest$zoneid2[dest$direction=='E'&dest$state=='exit'& dest$zoneid2 >= zid]
doc <- getURL(step2)
x <- fromJSON(doc, simplifyVector =  F)

dfExit <- data.frame(id=NULL, zoneid=NULL,ori=NULL,dest = NULL, dist_text = NULL, dist_num = NULL, dur_text=NULL, dur_num=NULL, state=NULL)
# I'm sure there's a more idiomatic way
for (i in 1:length(x$origin_addresses)) {
  
  ori <- x$origin_addresses[[i]]
  dist_text <- x$rows[[i]]$elements[[1]]$distance$text
  dist_num <- x$rows[[i]]$elements[[1]]$distance$value
  dur_text <- x$rows[[i]]$elements[[1]]$duration$text
  dur_num <- x$rows[[i]]$elements[[1]]$duration$value
  dfExit <- rbind(dfExit, data.frame(id=ebExitid[i],zoneid=ebExitzoneid[i],ori=ori,dest = destination, dist_text = dist_text, dist_num = dist_num, dur_text=dur_text, dur_num=dur_num, state='Exit'))
}

noTollTT <- url(origin = origin, destinations = destination, avoid = 'tolls')
doc <- getURL(noTollTT)
x <- fromJSON(doc, simplifyVector =  F)

dfNoToll <- data.frame(id=NULL, zoneid=NULL,ori=NULL,dest = NULL, dist_text = NULL, dist_num = NULL, dur_text=NULL, dur_num=NULL, state=NULL)
# I'm sure there's a more idiomatic way
for (i in 1:length(x$origin_addresses)) {
  
  destin <- destination
  ori <- origin
  dist_text <- x$rows[[i]]$elements[[1]]$distance$text
  dist_num <- x$rows[[i]]$elements[[1]]$distance$value
  dur_text <- x$rows[[i]]$elements[[1]]$duration$text
  dur_num <- x$rows[[i]]$elements[[1]]$duration$value
  dfNoToll <- rbind(dfNoToll, data.frame(id=0,zoneid=0,ori=ori,dest = destin, dist_text = dist_text, dist_num = dist_num, dur_text=dur_text, dur_num=dur_num,state='AvoidTollTT'))
}

allData <- rbindlist(list(dfEnter,dfExit,dfNoToll), fill = T)

return(allData)
}
dur <- tollParse()

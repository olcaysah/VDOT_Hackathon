# Author: Olcay Sahin
# Date: Tue Apr 17 12:36:59 2018
# Author: osahi001@odu.edu
# Project: Hackaton Toll
# Info: Smarterroads Toll Data Parse
# --------------

library(xml2)
library(dplyr)

keys <- read_csv('keys.csv')
token <- keys$key[2] #Get the token from smarterroads.org
link <- paste0('http://smarterroads.org/dataset/download/28?token=',token,'&file=TollingTripPricing/')
startTime <- as.POSIXct("2018-04-12 06:11")
endTime <- as.POSIXct("2018-04-26 18:06")
times <- seq.POSIXt(startTime,endTime,by = "5 min")
stringTime <- strftime(times, format = (paste0(link,"%Y/%m/%d/%H/%M/TollingTripPricing_%Y%m%d_%H%M.xml")))
dt <- bind_rows(lapply(stringTime, function(y) {
  tryCatch({
    
    print(y)
    toll <- read_xml(y)
    
    df <- bind_rows(lapply(xml_children(toll), function(x) as.list(xml_attrs(x))))
    df
  },error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
}))

#write_csv(dt, "historic_toll_data.csv")
toll_data <- read_csv('historic_toll_data.csv')
toll_data$CalculatedDateTime <- format(toll_data$CalculatedDateTime, tz = 'EST')
toll_data$IntervalDateTime <- format(toll_data$IntervalDateTime, tz = 'EST')
toll_data$IntervalEndDateTime <- format(toll_data$IntervalEndDateTime, tz = 'EST')
toll_data$hour <- as.POSIXlt(toll_data$CalculatedDateTime)$hour
wb <- toll_data[toll_data$CorridorName == "I-66 WB" & toll_data$hour %in% c(13:17),]
eb <- toll_data[toll_data$CorridorName == "I-66 EB" & toll_data$hour %in% c(4:10),]

glebeToLeesburg <- wb[wb$StartZoneID == 3200 & wb$EndZoneID == 3220,]

dt <- bind_rows(lapply(xml_children(toll), function(x) as.list(xml_attrs(x))))
# dt$CalculatedDateTime <- as.POSIXlt(dt$CalculatedDateTime)
toll <- read_xml(stringTime[1])

# Author: Olcay Sahin
# Date: Tue Apr 17 12:36:59 2018
# Author: osahi001@odu.edu
# Project: Hackaton Toll
# Info: Download real time or historic toll data
# --------------

function(input, output, session) {
  
  dat <- reactive({
    dt <- tollParse(origin = input$origin, destination = input$destination)
    minEntryDist <- min(dt$dist_num[dt$state == "Entry"]) + 1609 * 3
    minExitDist <- min(dt$dist_num[dt$state == "Exit"])
    minEntryDur <- min(dt$dur_num[dt$state == "Entry"]) + 600
    minExitDur <- min(dt$dur_num[dt$state == "Exit"])
    dur <- paste(round((minEntryDur + minExitDur) / 60,2),'mins')
    dist <- paste(round((minEntryDist + minExitDist) / 1609,2), 'miles')
    noTollDist <- paste(round(dt$dist_num[dt$id == 0] / 1609,2),'miles')
    noTollDur <- paste(round(dt$dur_num[dt$id == 0]/60,2), 'mins')
    data <- data.frame(TravelTime=c(dur,noTollDur), TravelDistance=c(dist,noTollDist), Toll=c('$7.45','$0'))
    data
  })
  output$results <- renderTable({
    dat()
  })
  output$rampmap <- renderLeaflet({
    ramps <- leaflet()%>%
      addProviderTiles("OpenStreetMap.DE", options = providerTileOptions(noWrap = TRUE))  %>% 
      setView(lng =  -77.095936, lat = 38.885211, zoom = 11)
    ramps %>% clearMarkers() %>% clearShapes()

  })
  
  })
  
}
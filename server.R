
function(input, output, session) {
  
  colPal <- colorNumeric("RdYlGn", c(1:105))
  
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
  #   for(i in 1:nrow(sgmdt)){
  #     json <- fromJSON(as.character(sgmdt$st_asgeojson[i]),simplifyVector = T)
  #     ramps <- addPolylines(ramps, lat = json$coordinates[,2], 
  #                           lng = json$coordinates[,1],
  #                           stroke = TRUE, color = colPal(i), weight = 5, opacity = 1,
  #                           popup = paste(sep = "<br/>",
  #                                         paste("SegmentID:", sgmdt$objectid[i])))
  #   }
  # ramps
  })
  
  #Observe changes when selecting the different location
  observe({
    rmap <- leafletProxy("rampmap")
    rmap %>% clearMarkers() %>% clearShapes()
    # if(input$variable == "All"){
    #   for(i in 1:nrow(sgmdt)){
    #     
    #     json <- fromJSON(as.character(sgmdt$st_asgeojson[i]),simplifyVector = T)
    #     rmap <- addPolylines(rmap, lat = json$coordinates[,2], 
    #                           lng = json$coordinates[,1],
    #                           stroke = TRUE, color = colPal(i), weight = 5, opacity = 1,
    #                           popup = paste(sep = "<br/>",
    #                                         paste("SegmentID:", sgmdt$objectid[i])))%>% 
    #       setView(lng = -76.39, lat = 36.90, zoom = 11)
    #   }
    #   rmap
    # }else{
    #   json <- fromJSON(as.character(sgmdt$st_asgeojson[sgmdt$objectid == input$variable]),simplifyVector = T)
    #   rmap <- addPolylines(rmap, lat = json$coordinates[,2], 
    #                         lng = json$coordinates[,1],
    #                         stroke = TRUE, color = colPal(1), weight = 5, opacity = 1,
    #                         popup = paste(sep = "<br/>",
    #                                       paste("SegmentID:", input$variable))) %>% 
    #     setView(lng = json$coordinates[,1][1], lat = json$coordinates[,2][1], zoom = 16)
    #   rmap
    #}
    
  })
  
}
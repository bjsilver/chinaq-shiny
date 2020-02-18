shinyServer(function (input, output, session) {
  

  
  output$map <- renderLeaflet({
    
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lng = 105.597190, lat = 33.193677, zoom = 4) %>%
      addProviderTiles(providers$Esri.WorldTopoMap, options = providerTileOptions(noWrap = FALSE)) %>%
      
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'bottomright' }).addTo(this)
    }") 
    
    
  })
  
  trends_subset <- reactive({
    # subset by pol
    a <- trends[trends$pol == input$pol,]
    # then subset by slope range
    min <- input$slopeslider[1]
    max <- input$slopeslider[2]
    a <- a[a$slope>min & a$slope<max, ]
    return(a)
  })
  
  trendBound <- reactive({
    # subset by pol
    a <- trends[trends$pol == input$pol,]
    return(na.omit(a$slope))
  })
  
  # pol input  reactive list of colours from palette 
  trendColors <- reactive({
    cuspal <- colorNumeric(
      palette = "RdBu",
      domain = trendBound(), reverse=TRUE)
    cuspal(trends_subset()$slope)
  })
  
  # react to change in pol or slope slider input
  observeEvent({
    input$pol
    }, {
               proxy <- leafletProxy("map")
               proxy %>% 
               addCircleMarkers(layerId=as.character(trends_subset()$station), 
                                lng=trends_subset()$lon,lat=trends_subset()$lat,
                                                 label=trends_subset()$station,
                                                 color=trendColors(), group = "circles",
                                                 fillOpacity=1,
                                                 stroke=FALSE,
                                                 radius=5,
                                                 # THIS IS NOT MATCHING
                                                 popup = paste0("<img src = http://homepages.see.leeds.ac.uk/~eebjs/station_svgs/",input$pol, "_", trends_subset()$station, ".svg>")
                                ) %>%
                 clearControls() %>%
                 
                 addLegend("bottomright",pal = pal, values = trendBound(), bins=10,
                           title = HTML("<font size=\"1\" color=\"black\">Trends &mu;g m<sup>-3</sup> </font>"), opacity = 1)
  })
  
  # react to change in pol or slope slider input
  observeEvent({
    input$slopeslider
  }, {
    pol <- input$pol
    proxy <- leafletProxy("map")
    proxy %>% clearGroup("circles") %>%
      addCircleMarkers(lng=trends_subset()$lon,lat=trends_subset()$lat,
                       label=trends_subset()$station,
                       color=trendColors(),
                       fillOpacity=1, group = "circles",
                       stroke=FALSE,
                       radius=5,
                       # THIS IS NOT MATCHING
                       popup = paste0("<img src = http://homepages.see.leeds.ac.uk/~eebjs/station_svgs/",input$pol, "_", trends_subset()$station, ".svg>")
      ) %>%
      clearControls() %>%

      addLegend("bottomright",pal = pal, values = trendBound(), bins=10,
                title = HTML("<font size=\"1\" color=\"black\">Trends &mu;g m<sup>-3</sup> </font>"), opacity = 1)
  })
  
  
  # update the slopeslider input based on selected pol
  observe({
    smin <- round(min(trendBound()))
    smax <- round(max(trendBound()))
    updateSliderInput(session, 'slopeslider', min = smin, max = smax, value = c(smin, smax)
                      )
  })
  
  # retreive stations in bound
  stationsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(trends[FALSE,])
    
    trends <- trends[trends$pol == input$pol,]
    min <- input$slopeslider[1]
    max <- input$slopeslider[2]
    trends <- trends[trends$slope>min & trends$slope<max, ]
    
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(trends,
           lat >= latRng[1] & lat <= latRng[2] &
             lon >= lngRng[1] & lon <= lngRng[2])
  })
  
  slopeBreaks <- hist(plot = FALSE, trends$slope, breaks = 40)$breaks
  
  output$histSlope <- renderPlot({
    # If no zipcodes are in view, don't plot
    if (nrow(stationsInBounds()) == 0)
      return(NULL)
    
    hist(trends_subset()$slope,
         main = "Trend Histogram (visible stations)",
         xlab = NULL,
         breaks = slopeBreaks,
         xlim = c(-10,10),
         ylim = c(0, 150),
         col = "lightgrey",
         border = 'white')
    
    hist(stationsInBounds()$slope,
         xlab = NULL,
         breaks = slopeBreaks,
         xlim = c(-10,10),
         ylim = c(0, 150),
         col = "darkgrey",
         border = 'white', add=T)
    box()
    
    
  })
  
  
  # function to return date string of slider
  sliderMonth <- reactiveValues()
  observe({
    full.date <- as.POSIXct(input$slider, tz="GMT")
    sliderMonth$Month <- as.character(monthStart(full.date))
  })
  
  means_subset <- reactive({
    # subset by pol
    a <- means[means$pol == input$meanpol,]
    # subset by month
    a <-a[, c('station', 'lat', 'lon', sliderMonth$Month)]
  })
  
  # function to return upper bound of pol selected
  polBound <- reactive({
    a <- means[means$pol == input$meanpol,]
    a <- a[, unlist(lapply(a, is.numeric))]
    return(a)
  })
  
  # pol input reactive list of colours from palette 
  polColors <- reactive({
    cuspal <- colorNumeric(
      palette = "YlOrRd",
      domain = polBound(), reverse=F, na.color = "transparent")
    cuspal(means_subset()[,4])
  })
  
  
  output$meanmap <- renderLeaflet({
    
    leaflet() %>%
      setView(lng = 105.597190, lat = 33.193677, zoom = 4) %>%
      addProviderTiles(providers$Esri.WorldTopoMap, options = providerTileOptions(noWrap = FALSE))
      
      
    
  })
  
  # react to change in pol or slope slider input
  observeEvent({
    input$slider
  }, {
    print(input$slider)
    proxy <- leafletProxy("meanmap")
    proxy %>% 
      addCircleMarkers(lng=means_subset()$lon,lat=means_subset()$lat,
                       color=polColors(), group = "meanpoints",
                       fillOpacity=1,
                       stroke=FALSE,
                       radius=5)  %>%
      clearControls() %>%
      
      addLegend("bottomright",pal = palmean, values = 0:quantile(polBound(), na.rm = T,  probs = c(.95)),
                title = HTML("<font size=\"1\" color=\"black\">Trends &mu;g m<sup>-3</sup> </font>"), opacity = 1)
  })
  
    
  
  
})

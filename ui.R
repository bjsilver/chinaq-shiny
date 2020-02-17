shinyUI(
  
  navbarPage("China air pollution trends", id="nav",
             # Interactive map tab
             tabPanel("Trends",
                      
                      div(class="outer",
                          
                          
                          
                          tags$style(type = "text/css", ".outer {position: fixed; top: 0px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                          leafletOutput("map", width = "100%", height = "100%"),
                          
                          
                          
                          absolutePanel(top = 60, right = 10, draggable=FALSE,id="controls",style="z-index:500;", fixed=TRUE,
                                        width = 200,
                                        class = "panel panel-default",
                                        
                                        
                                        div(
                                          selectInput("pol", "Pollutant",
                                                      c("PM2.5" = "PM2.5",
                                                        'PM10' = 'PM10',
                                                        "Ozone" = "O3",
                                                        "Nitrogen Dioxide" = "NO2",
                                                        "Sulphur Dioxide" = "SO2"))
                                          
                                        )

                          ),
                          
                          # hist panel
                          absolutePanel(left = 20, bottom = 20, draggable=FALSE,id="controls",style="z-index:500;", fixed=TRUE,
                                        width = 400,
                                        class = "panel panel-default",
                                        
                                        div(style = "padding-right: 15px",
                                            plotOutput("histSlope", height = 300)
                                        ),
                                        div(style = "font-size: 10px; padding-left: 62px; margin-top:-10.3em; max-width: 352px", 
                                            
                                            sliderInput("slopeslider", label = NULL, min = -10, 
                                                        max = 10, value = c(-10, 10), ticks=FALSE)
                                        )   
                          )
                      )
             ),
             tabPanel("Means",
                      h3("slider with changing aqi points through time"),
                      absolutePanel(left = 20, bottom = 20, draggable=FALSE,id="controls",style="z-index:500;", fixed=TRUE,
                                    width = 400,
                                    class = "panel panel-default",
                                    sliderInput("slider", "Time", min = as.Date("2014-11-01"),max =as.Date("2019-07-01"),
                                                value=as.Date("2014-11-01"),timeFormat="%b %Y",
                                                animate = animationOptions(loop=T, interval=1))),
                      div(class="outer",
                          
                          
                          
                          tags$style(type = "text/css", ".outer {position: fixed; top: 0px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
                          leafletOutput("meanmap", width = "100%", height = "100%"),
                          
                          
                          
                          
                          absolutePanel(top = 60, right = 10, draggable=FALSE,id="controls",style="z-index:500;", fixed=TRUE,
                                        width = 200,
                                        class = "panel panel-default",
                                        div(
                                          selectInput("meanpol", "Pollutant",
                                                      c("PM2.5" = "PM2.5",
                                                        'PM10' = 'PM10',
                                                        "Ozone" = "O3",
                                                        "Nitrogen Dioxide" = "NO2",
                                                        "Sulphur Dioxide" = "SO2"))
                                          
                                        )
                                        
                                        
                          )
                      )
                      
             )
  )
  
  
)
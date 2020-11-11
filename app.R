library(tidygeocoder)
library(leaflet)
library(shiny)
library(shinythemes)

ui <- fluidPage(
  title = "Geocoder",
  theme = shinytheme("cyborg"),
  h1("Geocoder"),
  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "address",
        label = "Address",
        value = "",
        placeholder = "Insert a valid address..."
      ),
      actionButton(inputId = "geocode", label = "Geocode"),
      tableOutput(outputId = "table")
    ),
    mainPanel(
      leafletOutput(outputId = "map")
    )
  )
  
)

server <- function(input, output, session) {
  coords = eventReactive(input$geocode, {
    geo_osm(input$address)
  })
  
  output$table = renderTable({
    coords()
  })
  
  output$map = renderLeaflet({
    coords = tryCatch({
      coords()
    }, error = function(e)
      NULL)
    
    map = leaflet() %>%
      addTiles(urlTemplate = "http://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&s=Ga")
    
    if (is.null(coords)) {
      
      coords = geo_osm("london, uk")
      
    }
    
    map = map %>%
      addMarkers(lng = coords$long,
                 lat = coords$lat,
                 label = coords$address)
    
    map
  })
  
}

shinyApp(ui, server)
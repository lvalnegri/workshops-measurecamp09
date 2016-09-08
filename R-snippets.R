# If you want to play with maps background and colors:
#   - Leaflet-providers preview: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#   - Color Bewer Palettes: http://colorbrewer2.org/

# QUICK MAP OF LONDON SANTANDER CYCLES
lapply(c('data.table', 'jsonlite', 'leaflet'), require, character.only = TRUE)
stations <- data.table(fromJSON(txt = 'https://api.tfl.gov.uk/bikepoint'), key = 'id')
m <- stations %>% 
    leaflet() %>% 
    addTiles(
        'http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
        attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    ) %>%
    setView(lng = mean(stations$lon), lat = mean(stations$lat), zoom = 12) %>% 
    addCircleMarkers(stroke = FALSE, radius = 4, color = '#ffa500', weight = 3, fillOpacity = 0.8, popup = ~commonName) %>%
    addLegend('bottomright', colors = '#ffa500', labels = 'Station (click on any dot for more info)', title = 'LONDON SANTANDER CYCLES HIRE')

m

##############################################################################################################

# MAP OF LONDON SANTANDER CYCLES PLUS STATS 
# Leaflet-providers preview: http://leaflet-extras.github.io/leaflet-providers/preview/index.html

lapply(c('data.table', 'DT', 'leaflet'), require, character.only = TRUE)
stations <- data.table(dbGetQuery(db_conn, 'SELECT * FROM stations WHERE is_active') )
datatable(stations,
   rownames = FALSE,
   class = 'display',
   extensions = c('Scroller'),
   options = list(
       scrollX = TRUE,
       scrollY = 400,
       scroller = TRUE,
       searchHighlight = TRUE,
       dom = 'frtip'
   )
)
stations %>% leaflet() %>% 
    addProviderTiles("CartoDB.Positron") %>%
    setView(lng = mean(stations$X_lon), lat = mean(stations$Y_lat), zoom = 12) %>%
    addCircleMarkers(~X_lon, ~Y_lat, stroke = FALSE, radius = stations[, hires_started]/10000, fillOpacity = 0.6, popup = ~address)

##############################################################################################################

# QUICK THEMATIC MAP ABOUT LAST EU REFERENDUM
# Color Bewer Palettes: http://colorbrewer2.org/
# command to test whether the GeoJSON driver works: "GeoJSON" %in% ogrDrivers()$name

lapply(c('data.table', 'leaflet', 'rgdal'), require, character.only = TRUE)
results <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/EU-ref.csv')
results[, turnout := Cast/Electorate]
results[, pctLeave := Leave/Valid]
boundaries <- readOGR("https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/administrative/gb/lad.json", "OGRGeoJSON")
boundaries$pctLeave <- results$Leave/results$Valid
pal <- colorNumeric(palette = "BrBG", domain = boundaries$pctLeave )
m <- leaflet(boundaries) %>% 
        addProviderTiles("CartoDB.Positron") %>%
        setView(lng = -2.547855, lat = 54.00366, zoom = 5) %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1, color = ~pal(pctLeave) )    
        addPolygons(weight = 1, color = '#444444', fill = FALSE)



##############################################################################################################

# SCATTERPLOTS TO ANALYZE POSSIBLE CORRELATIONS BETWEEN
 



##############################################################################################################

# BASIC SHINY APP ADDING SOME INTERACTIVITY TO PREVIOUS MAP

lapply(c('data.table', 'DT', 'leaflet', 'RMySQL', 'shiny'), require, character.only = TRUE)



# If you want to play with maps background and colors:
#   - Leaflet-providers preview: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#   - Color Bewer Palettes: http://colorbrewer2.org/

lapply(c('data.table', 'DT', 'jsonlite', 'leaflet'), require, character.only = TRUE)

# EX 1, simple location maps using TFL Santander Cycle hire schema datapoints
stations <- data.table(fromJSON(txt = 'https://api.tfl.gov.uk/bikepoint'), key = 'id')
stations %>% 
    leaflet() %>% 
    addTiles(
        'http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
        attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    ) %>%
    setView(lng = mean(stations$lon), lat = mean(stations$lat), zoom = 12) %>% 
    addCircleMarkers(stroke = FALSE, radius = 4, color = '#ffa500', weight = 3, fillOpacity = 0.8, popup = ~commonName) %>%
    addLegend('bottomright', colors = '#ffa500', labels = 'Station (click on any dot for more info)', title = 'LONDON SANTANDER CYCLES HIRE')

##############################################################################################################

# MAP OF LONDON SANTANDER CYCLES PLUS STATS 
# Leaflet-providers preview: http://leaflet-extras.github.io/leaflet-providers/preview/index.html

stations <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/londonCycleHire-stations.csv')
stations[, started := as.Date(as.character(started), '%Y%m%d') ]
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
    setView(lng = mean(stations$X_lon), lat = mean(stations$Y_lat), zoom = 13) %>%
    addCircleMarkers(~X_lon, ~Y_lat, 
                     radius = stations[, hires]/10000, 
                     stroke = TRUE, 
                     weight = 1,
                     fillOpacity = 0.6, 
                     popup = ~paste(
                         paste('<b>', address, '</b><br />'), 
                         postcode, place, area, '',
                         paste('Total docks:', docks),
                         paste('Started:', format(started, format = '%d %b %Y')),
                         sep = '<br />'
                     )
    )

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



# If you want to play with maps background and colors:
#   - Leaflet-providers preview: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
#   - Color Bewer Palettes: http://colorbrewer2.org/

lapply(c('data.table', 'DT', 'ggplot2', 'jsonlite', 'leaflet'), require, character.only = TRUE)

##############################################################################################################
# EX.1 - location maps using API from TFL Santander Cycle hire schema datapoints
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
# EX.2 - SCATTERPLOTS TO ANALYZE EU-REF RESULTS

results <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/EU-ref.csv')
results[, turnout := Cast / Electorate * 100]
results[, pctLeave := Leave / Valid * 100]

geo_locations <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/geo_locations_uk.csv')
geo_lookups <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/geo_lookups_uk.csv')
results <- merge(results, unique(geo_lookups[, .(LAD_id, RGN_id)]), by = 'LAD_id')
results <- merge(results, geo_locations[type == 'LAD', .(id, name)], by.x = 'LAD_id', by.y = 'id')
results[, name := as.factor(name)]
setnames(results, 'name', 'district')
results <- merge(results, geo_locations[type == 'RGN', .(id, name)], by.x = 'RGN_id', by.y = 'id')
results[, name := as.factor(name)]
setnames(results, 'name', 'region')

g <- ggplot(data = results, aes(x = pctLeave, y = turnout, fill = pctLeave))
g <- g + geom_vline(xintercept = 50, color = 'red', size = 0.25)
g <- g + geom_point(colour = 'black', pch = 23, size = 3)
g <- g + scale_fill_gradient(low = "yellow", high = "blue")
g <- g + theme_classic() 
g <- g + theme(axis.text.x = element_blank(), axis.title.x=element_blank(), axis.ticks=element_blank(), legend.position = 'none')
g <- g + labs(title = 'EU Referendum Results', x = '')
g <- g + facet_wrap(~region)
g <- g + geom_hline(data = results[, .(median(turnout)), region], aes(group = region, yintercept = V1), color = 'gray', linetype="dotted") 
g


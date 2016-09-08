# Quick way to install all packages needed for the demo (R code)

dep.pkg <- c('devtools', 'data.table', 'dplyr', 'DT', 'dygraphs',  'forecast', 'funModeling', 'geojsonio', 'ggmap', 'ggplot2', 'ggvis', 
             'htmlwidgets', 'jsonlite', 'leaflet', 'lubridate', 'maptools', 'rgdal', 'RMySQL')
# dep.pkg <- c('devtools', 'data.table', 'DT', 'ggplot2', 'jsonlite', 'leaflet')
pkgs.not.installed <- dep.pkg[!sapply(dep.pkg, function(p) require(p, character.only = TRUE))]
if( length(pkgs.not.installed) > 0 ) install.packages(pkgs.not.installed, dependencies = TRUE)


# How to create a  copy your hard job done in Rstudio (Linux code)

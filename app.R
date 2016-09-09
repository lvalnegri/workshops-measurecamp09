# to copy to the shiny directory run in terminal: sudo cp -R /home/<user>/presentations-measurecamp09 /srv/shiny-server/
lapply(c('data.table', 'DT', 'leaflet', 'shiny', 'shinythemes'), require, character.only = TRUE)

stations <- fread('https://raw.githubusercontent.com/lvalnegri/datasets/master/londonCycleHire-stations.csv')
stations[, started := as.Date(as.character(started), '%Y%m%d') ]
    
ui <- navbarPage('London Cycle hire', theme = shinytheme('united'),
    tabPanel('table', dataTableOutput('tDT') ),
    tabPanel('map', leafletOutput('mLF', height = '800px') )
)

server <- function(input, output) {
    output$tDT <- renderDataTable(
        datatable(stations,
            rownames = FALSE,
            class = 'display',
            selection = 'single',
            extensions = c('Scroller'),
            options = list(
               scrollX = TRUE,
               scrollY = 600,
               scroller = TRUE,
               searchHighlight = TRUE,
               columnDefs = list( list(targets = 1:3, visible = FALSE) ),
               dom = 'frtip'
            )
        ) %>% formatCurrency(10:12, '', digits = 0)
    )
    output$mLF <- renderLeaflet({
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
    })  
}

shinyApp(ui = ui, server = server)

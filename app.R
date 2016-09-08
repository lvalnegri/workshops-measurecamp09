# need a *pull* from github datasets repository

lapply(c('data.table', 'ggplot2', 'shiny'), require, character.only = TRUE)

results <- fread('~/datasets/EU-ref.csv')
results[, turnout := Cast / Electorate]
results[, pctLeave := Leave / Valid]

geo_locations <- fread('~/datasets/geo_locations_uk.csv')
geo_lookups <- fread('~/datasets/geo_lookups_uk.csv')
results <- merge(results, unique(geo_lookups[, .(LAD_id, RGN_id)]), by = 'LAD_id')
results <- merge(results, geo_locations[type == 'LAD', .(id, name)], by.x = 'LAD_id', by.y = 'id')
results[, name := as.factor(name)]
setnames(results, 'name', 'district')
results <- merge(results, geo_locations[type == 'RGN', .(id, name)], by.x = 'RGN_id', by.y = 'id')
results[, name := as.factor(name)]
setnames(results, 'name', 'region')

# g <- ggplot(data = results, aes(x = pctLeave, y = turnout, color = region))
# g <- g + geom_point()
# g <- g + facet_wrap(~region)
# g

ui <- fluidPage(
    
    selectInput('cboRegion', 'REGION:', choices = c('TOTAL', levels(results$region)) ),
    
    plotOutput('ggp')
    
)

server <- function(input, output, session) {
    
    output$ggp <- renderPlot({
        if(input$cboRegion == 'TOTAL'){
            g <- ggplot(data = results, aes(x = pctLeave, y = turnout))
            g <- g + geom_point(aes(color = region))
            g <- g + facet_wrap(~region)
        } else {
            g <- ggplot(data = results[region == input$cboRegion], aes(x = pctLeave, y = turnout))
            g <- g + geom_point(aes(color = district))
        }
        g
    })  
    
}

shinyApp(ui = ui, server = server)

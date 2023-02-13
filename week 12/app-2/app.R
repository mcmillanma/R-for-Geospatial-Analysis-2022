library(shiny)
library(raster)
library(mapview)
dem<-raster('dem1.tif')

# Define UI for app that display a map
ui <- fluidPage(
  # App title ----
  titlePanel("Demo_Geog5984!"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "thresh_value",
                  label = "threshold:",
                  min = 300,
                  max = 1200,
                  value = 500)
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      # Output: Map ----
      plotOutput(outputId = "distPlot"),
      tableOutput("table")
    )
  )
)
  

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  output$distPlot <- renderPlot({
    r<-dem
    r[r<input$thresh_value]<-0
    r[r>0]<-1
    plot(r)
  })
  
  output$table <- renderTable(
    length(dem[dem>input$thresh_value])*900/1000000,colnames=F,caption = "Total Area (km2)",caption.placement = getOption("xtable.caption.placement", "top"))
}

shinyApp(ui = ui, server = server)


    
    
    
library(shiny)

shinyServer(
    function(input, output) {
        output$text1 <- renderText({input$text1})
    }
)
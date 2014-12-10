library(shiny)

paste_it <- function(intext, word){
    paste(intext,word,sep = " ")
}

shinyServer(
    function(input, output) {
        word1 <- "fuck"
        word2 <- "shit"
        
        intext <- reactive({input$text1})
        output$text1 <- renderText(intext()) ## no comma here
        output$text2 <- renderText({
            if (input$word1but == 0) "You haven't pressed the button." 
            else if (input$word1but == 1) word1 
            else if (input$word1but == 2) word2             
            else "OK quit pressing it."
        }) 
        output$text3 <- renderText({
            if (input$word1but == 0) "You haven't pressed the button." 
            else if (input$word1but == 1) paste_it(intext(),word1)
            else if (input$word1but == 2) paste_it(intext(),word2)          
            else "OK quit pressing it."
        }) 
    }
)
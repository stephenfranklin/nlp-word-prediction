library(shiny)

source("paste_it.R")
source("word_prediction.R")
### This function predicts the next word from a trigram input.
### arguments:  1) input_text, char;
###             2) ngram4.dt,, data.table of 4grams and their frequencies.
### 1) processes the input text,
### 2) makes a data.table from the last 3 words of the input text,
### 3) selects from an existing data.table of 4grams
###     those that match the input trigram, and
### 4) returns a list `tops` of the 4th words ordered by most frequent.
load("tot.freqs70fmin05w4cull.RData")
### That loads the data.table of 4grams and frequencies
### `tot.freqs_70_fmin05_w4_culled`

#paste_it <- function(intext, word){
#    paste(intext,word,sep = " ")
#}

shinyServer(
    function(input, output) {
        word1 <- "fuck"
        word2 <- "shit"
        stuff <- reactive(tot.freqs_70_fmin05_w4_culled$ngrams[1])
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
            else if (input$word1but %%2 == 1 ) paste_it(intext(),word1)
            else paste_it(intext(),word2)
        }) 
        output$text4 <- renderText(stuff()) ## no comma here
    }
)
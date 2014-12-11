library(shiny)

source("word_prediction.R")
### Function `predict_w4(input_text, ngram4.dt)`
### predicts the next word from a trigram input.
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

shinyServer(
    function(input, output) {
        stuff <- reactive(tot.freqs_70_fmin05_w4_culled$ngrams[200])
        intext <- reactive({input$text1})
        output$text1 <- renderText(intext()) ## no comma here
        output$text2 <- renderText({
                word <- predict_w4(intext(),tot.freqs_70_fmin05_w4_culled)
                word[1]
        })
        output$text4 <- renderText(stuff()) ## no comma here
    }
)
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
load("tot.freqs_100_10w.RData")
### That loads the data.table of 4grams and frequencies
### `tot.freqs`

random_4gram <- function(){
    n_tot <- nrow(tot.freqs)
    randnum<-round(runif(1,1,n_tot),0)
    r4gram <- tot.freqs$ngrams[randnum]
    r4gram
}

shinyServer(
    function(input, output) {
        intext <- reactive({input$text1})
        output$text1 <- renderText({
            word <- predict_w4(intext(),tot.freqs)
            word[1]
        })
        output$text2 <- renderText({
                word <- predict_w4(intext(),tot.freqs)
                word[2]
        })
        output$text3 <- renderText({
            word <- predict_w4(intext(),tot.freqs)
            word[3]
        })
        output$text4 <- renderText({
            word <- predict_w4(intext(),tot.freqs)
            word[4]
        })
        output$text5 <- renderText({
            word <- predict_w4(intext(),tot.freqs)
            word[5]
        })
        output$text6 <- renderText({
            word <- predict_w4(intext(),tot.freqs)
            word[6]
        })
        output$text7 <- renderText({
            if (input$random.btn==0) random_4gram()
            else random_4gram()
        })
    }
)
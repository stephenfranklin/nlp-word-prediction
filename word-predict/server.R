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
    function(input, output, session) {
        output$text7 <- renderText({
            if (input$random.btn==0) random_4gram()
            else random_4gram()
        })
        
        intext <- reactive({input$text1})
        word <- reactive(predict_w4(intext(),tot.freqs))
        
        output$text1 <- renderText({word()[1]})      
        output$text2 <- renderText({word()[2]})
        output$text3 <- renderText({word()[3]})
        output$text4 <- renderText({word()[4]})
        output$text5 <- renderText({word()[5]})
        output$text6 <- renderText({word()[6]})
    
insert_word <- function(word){
    wordN <- ifelse(grepl("'",word),sub("'", "\\\\'",word,fixed=T),word)
    wordN
}
#iw <- function(word){
#    ## N is the index in 'word()[N]'
#    wN <- ifelse(grepl("'",word),sub("'", "\\\\'",word, fixed=T),word)
#    wN
#}

        
    output$uiOutputPanel <- renderUI({
        button1Click <- paste("$('#text1').val($('#text1').val() + '",
                              insert_word(word()[1]), " ", "').trigger('change'); var input =
                          $('#text1'); input[0].selectionStart =
                          input[0].selectionEnd = input.val().length;",
                              sep='')
        button2Click <- paste("$('#text1').val($('#text1').val() + '",
                              word()[2], " ", "').trigger('change'); var input =
                          $('#text1'); input[0].selectionStart =
                          input[0].selectionEnd = input.val().length;",
                              sep='')
        button3Click <- paste("$('#text1').val($('#text1').val() + '",
                              word()[3], " ", "').trigger('change'); var input =
                          $('#text1'); input[0].selectionStart =
                          input[0].selectionEnd = input.val().length;",
                              sep='')
        
        tags$div(
            tags$button(type="button", id="word()[1]", word()[1],
                        class="btn action-button shiny-bound-input",
                        onclick=button1Click, accesskey="Ctrl + 1")
            ,tags$button(type="button", id="word()[2]", word()[2],
                         class="btn action-button shiny-bound-input",
                         onclick=button2Click)
            ,tags$button(type="button", id="word()[3]", word()[3],
                         class="btn action-button shiny-bound-input",
                         onclick=button3Click)
        )
    })
    }    
)
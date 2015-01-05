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

fix_apo <- function(word){
    ## fix the apostrophe in contractions.
    wordN <- ifelse(grepl("'",word),gsub("'", "\\'",word,fixed=T),word)
    wordN
}

na2commons <- function(word){
    ## `word` is a list of words.
    commons <- c("the", "be", "to", "of", "and", "a")
    if(length(word)==1){
        if(is.na(word) | grepl("^na$",word, ignore.case=T))
            word <- commons[round(runif(1,1,6),0)]
    } else{
        for(i in 1:length(word))
            if(is.na(word[i]) | grepl("^na$",word[i], ignore.case=T))
                word[i] <- commons[i]
    }
    word
}

insert_choice <- function(word, end_space){
    ## amends the input text with the chosen word.
    ## `text1` is the input text field (see file 'ui.R').
    ## `end_space` is boolean, and is defined in the shinyServer function.
    paste("$('#text1').val($('#text1').val() + '",
        ifelse(end_space, ""," "),
        word, " ", "').trigger('change'); var input =
        $('#text1'); input[0].selectionStart =
        input[0].selectionEnd = input.val().length;",
        sep='')
}

babble<-function(intext,N=1,top=TRUE){
    phrase <- ""
    for(i in 1:N){
        ifelse(top,
               wordnext <- na2commons(predict_w4(intext,tot.freqs)[1]),
               wordnext <- na2commons(predict_w4(intext,tot.freqs)[round(runif(1,1,3),0)])
        )
        phrase <- ifelse(phrase == "", wordnext, paste(phrase,wordnext))
        intext <- paste(intext,phrase)
    }
    phrase
}

clear <- "$('#text1').val('');
        var input = $('#text1');
        input[0].selectionStart = input[0].selectionEnd = input.val().length;"

shinyServer(
    function(input, output, session) {

        intext <- reactive({input$text1})
        word <- reactive(predict_w4(intext(),tot.freqs)[1:3])
        worda <- reactive( na2commons(word()) )
        end_space <- reactive( grepl(" $", intext()) )
        
        output$topPanel <- renderUI({
            tags$script(src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js")
    
            button1Click <- insert_choice(fix_apo(worda()[1]),end_space())
            button2Click <- insert_choice(fix_apo(worda()[2]),end_space())
            button3Click <- insert_choice(fix_apo(worda()[3]),end_space())

            tags$div(
                tags$button(type="button", id="word1but", worda()[1],
                            class="btn action-button shiny-bound-input",
                            onclick=button1Click)
                ,tags$button(type="button", id="word2but", worda()[2],
                             class="btn action-button shiny-bound-input",
                             onclick=button2Click)
                ,tags$button(type="button", id="word3but", worda()[3],
                             class="btn action-button shiny-bound-input",
                             onclick=button3Click)
            )

        })
        output$bottomPanel <- renderUI({
            buttonRClick <- insert_choice(fix_apo(babble(intext(),
                                input$num_bab,input$rand_bab)),end_space())
            tags$div(
                tags$button(type="button", id="randombut", "Babble",
                             class="btn action-button shiny-bound-input",
                             onclick=buttonRClick)
                ,tags$button(type="button", id="clearbut", "Clear",
                             class="btn action-button shiny-bound-input",
                             onclick=clear)
            )
        })
    }    
)
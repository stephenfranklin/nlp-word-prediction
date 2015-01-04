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

fix_apo <- function(word){
    ## fix the apostrophe in contractions.
    wordN <- ifelse(grepl("'",word),gsub("'", "\\'",word,fixed=T),word)
    wordN
}

na2commons <- function(word){
    commons <- c("the", "be", "to", "of", "and", "a")
    for(i in 1:length(word))
        if(is.na(word[i]) | grepl("^na$",word[i], ignore.case=T))
            word[i] <- commons[i]
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

babble<-function(intext,N,top){
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
        r4gram <- reactive(random_4gram())
        output$text7 <- renderText({
            if (input$random.btn==0) r4gram()
            else random_4gram()
        })
        
        intext <- reactive({input$text1})
        word <- reactive(predict_w4(intext(),tot.freqs)[1:3])
        worda <- reactive( na2commons(word()) )
        end_space <- reactive( grepl(" $", intext()) )
        
        output$uiOutputPanel <- renderUI({
            button1Click <- insert_choice(fix_apo(worda()[1]),end_space())
            button2Click <- insert_choice(fix_apo(worda()[2]),end_space())
            button3Click <- insert_choice(fix_apo(worda()[3]),end_space())
            buttonRClick <- insert_choice(fix_apo(babble(intext(),
                             input$num_bab,input$rand_bab)),end_space())
            
            tags$div(
                tags$button(type="button", id="word1but", worda()[1],
                            class="btn action-button shiny-bound-input",
                            onclick=button1Click, accesskey="Ctrl + 1")
                ,tags$button(type="button", id="word2but", worda()[2],
                             class="btn action-button shiny-bound-input",
                             onclick=button2Click)
                ,tags$button(type="button", id="word3but", worda()[3],
                             class="btn action-button shiny-bound-input",
                             onclick=button3Click)
                ,tags$button(type="button", id="randombut", "babble",
                             class="btn action-button shiny-bound-input",
                             onclick=buttonRClick)
                ,tags$button(type="button", id="clearbut", "Clear",
                             class="btn action-button shiny-bound-input",
                             onclick=clear)
            )
        })
    }    
)
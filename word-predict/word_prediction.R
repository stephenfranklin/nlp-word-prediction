# word_prediction.R
# author: Stephen Franklin
# 2014-12-10

library(data.table)

### This function predicts the next word from a trigram input.
### arguments:  1) input_text, char;
###             2) ngram4.dt, data.table of 4grams and their frequencies.
### 1) processes the input text,
### 2) makes a data.table from the last 3 words of the input text,
### 3) selects from an existing data.table of 4grams
###     those that match the input trigram, and
### 4) returns a list `tops` of the 4th words ordered by most frequent.

### The most recent data.table of 4grams is
### `tot.freqs_70_fmin05_w4_culled`
### It can be loaded with:
#load("~/coursera/ds4_capstone_nlp/data2/tot.freqs70fmin05w4cull.RData")
### Or from within the shiny app `word-predict` with
#source("tot.freqs70fmin05w4cull.RData")

predict_w4 <- function(input_text, ngram4.dt){
    ### Preprocess input trigram
    #input_text <-" 4:37PM :-} I didn’t want to go."
    #input_text <- "at the end"
    input_apo <- gsub("’", "'", input_text)
    input_dot <- gsub("[^[:alpha:] ']"," ",input_apo, perl=T)
    input_tol <- tolower(input_dot)
    input_whi <- gsub("\\s+"," ",input_tol)
    input_wht <- gsub("^ | $","",input_whi)
    input_text <- input_wht
    
    ### Convert input_text to data.table
    lli <- unlist(strsplit(input_text, " ", fixed=TRUE))
    lli3<- lli[(length(lli)-2):length(lli)]
    input.dt <- data.table(w1 = lli3[1], w2 = lli3[2], w3 = lli3[3])
    
    ### Take the input trigram (last 3 words) and compare it to the
    ### list of trigrams (first 3 columns).
    setkey(ngram4.dt,w1,w2,w3)
    top3grams <- ngram4.dt[.(input.dt$w1,input.dt$w2,input.dt$w3)]
    ### Return the top 6 words (from column 4) of the highest frequencies that match.
    tops<-top3grams[order(-tots)]$w4
    tops
} 
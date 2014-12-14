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

process_input <- function(input_text){
    ### 1. Preprocesses text.
    ### 2. Checks for number of words.
    ### Returns as data.table, NAs for missing words.
    input_apo <- gsub("’", "'", input_text)
    input_dot <- gsub("[^[:alpha:] ']"," ",input_apo, perl=T)
    input_tol <- tolower(input_dot)
    input_whi <- gsub("\\s+"," ",input_tol)
    input_wht <- gsub("^ | $","",input_whi)
    input <- input_wht
    ### Convert input to data.table ###
    inp_v <- unlist(strsplit(input, " ", fixed=TRUE))
    ### Deal with unigram and bigrams ###
    n <- length(inp_v)
    if(n==1){
        input.dt <- data.table(w1 = NA, w2 = NA, w3 = inp_v[1])
    } else if(n==2){
        input.dt <- data.table(w1 = NA, w2 = inp_v[1], w3 = inp_v[2])
    } else if(n>=3){
        inp_v3<- inp_v[(length(inp_v)-2):length(inp_v)]
        input.dt <- data.table(w1 = inp_v3[1], w2 = inp_v3[2], w3 = inp_v3[3])
    }
    input.dt
}

predict_trigrams <- function(input.dt, ngram4.dt){
    ### Returns top3grams, column w4 by frequency.
setkey(ngram4.dt,w1,w2,w3)
top3grams <- ngram4.dt[.(input.dt$w1,input.dt$w2,input.dt$w3)]
top3grams <- top3grams[order(-tots)]
top3grams$w4
}

predict_bigrams <- function(input.dt, ngram4.dt){
    ### Compare the input bigram (last two words) 
    ### to every combo of bigrams: columns 1:2, 1:3, 2:3.
    ### Returns top_bigrams, w3 & w4 by frequency (w3 renamed to w4).

    ### bigrams input w2 & w3 to w1 & w2, returning w3 ###
    setkey(ngram4.dt,w1,w2)
    ### binary search .() is alias for list()
    top12grams <- ngram4.dt[.(input.dt$w2,input.dt$w3)]
    top12grams <- top12grams[,ngrams:=NULL]
    top12grams <- top12grams[,w4:=NULL]
    setkey(top12grams,w1,w2,w3)
    top12s <- top12grams[,sum(tots),by=w3]
    top12s <- top12s[order(-V1)]
    
    ### bigrams input w2 & w3 to w2 & w3, returning w4 ###
    setkey(ngram4.dt,w2,w3)
    ### binary search .() is alias for list()
    top23grams <- ngram4.dt[.(input.dt$w2,input.dt$w3)]
    top23grams <- top23grams[,ngrams:=NULL]
    top23grams <- top23grams[,w1:=NULL]
    setkey(top23grams,w2,w3,w4)
    top23s <- top23grams[,sum(tots),by=w4]
    top23s <- top23s[order(-V1)]
    
    ### Combine results ###
    setnames(top12s, "w3", "w4")
    top_bigrams <- rbind(top12s,top23s)
    top_bigrams <- top_bigrams[,sum(V1),by=w4]
    top_bigrams <- top_bigrams[order(-V1)]
    top_bigrams$w4
}

pred1 <- function(w,input.dt,ngram4.dt){
    ### To be used within `predict_unigrams()`.
    ### w is the column to predict from: "w1", "w2", or "w3"
    ### the subsequent column will be returned by frequency.
    setkeyv(ngram4.dt,w)  ## setkeyv() for variables
    ### binary search .() is alias for list()
    top1grams <- ngram4.dt[.(input.dt[,w3])]
    top1grams <- top1grams[,ngrams:=NULL]
    if(w=="w3"){
        ww <- "w4"
        top1grams <- top1grams[,w1:=NULL]
        top1grams <- top1grams[,w2:=NULL]
    }
    if(w=="w2"){
        ww <- "w3"
        top1grams <- top1grams[,w1:=NULL]
        top1grams <- top1grams[,w4:=NULL]
    }
    if(w=="w1"){
        ww <- "w2"
        top1grams <- top1grams[,w3:=NULL]
        top1grams <- top1grams[,w4:=NULL]
    }
    top1s <- top1grams[,sum(tots),by=ww]
    top1s <- top1s[order(-V1)]
    setnames(top1s, ww, "w4")
    top1s  
}

predict_unigrams <- function(input.dt, ngram4.dt){
    ### Requires function `pred1()`.
    ### Compare the input unigram (last word) 
    ### to every combo of unigrams: columns 1, 2, & 3.
    ### Returns top_unigrams: w2, w3, w4 by frequency (w2 & w3 renamed to w4).
    
    ### predict w4 from w3 ###
    top1s4 <- pred1("w3",input.dt,ngram4.dt)
    #head(top1s4)
    ### predict w3 from w2 ###
    top1s3 <- pred1("w2",input.dt,ngram4.dt)
    #head(top1s3)
    ### predict w2 from w1 ###
    top1s2 <- pred1("w1",input.dt,ngram4.dt)
    #head(top1s2)
    ### Combine results ###
    top_unigrams <- rbind(top1s4,top1s3)
    top_unigrams <- rbind(top_unigrams,top1s2)
    top_unigrams <- top_unigrams[,sum(V1),by=(w4)]
    top_unigrams <- top_unigrams[order(-V1)]
    top_unigrams$w4
}

predict_w4 <- function(input_text, ngram4.dt){
    input.dt <- data.table(w1="",w2="",w3="")
    input.dt <- process_input(input_text)
    ## predict for 1, 2, or 3+ input words ##
    if(is.na(input.dt$w2)){
        tops <- predict_unigrams(input.dt, ngram4.dt)
    } else if(is.na(input.dt$w1)){
        tops <- predict_bigrams(input.dt, ngram4.dt)
        ## back off if empty ##
        if(is.na(tops[1])) tops <- predict_unigrams(input.dt, ngram4.dt)
    } else {
        tops <- predict_trigrams(input.dt, ngram4.dt)
        ## back off if empty ##
        if(is.na(tops[1])) {
            tops <- predict_bigrams(input.dt, ngram4.dt)  
            if(is.na(tops[1])) tops <- predict_unigrams(input.dt, ngram4.dt)
        }
    }
    tops
}
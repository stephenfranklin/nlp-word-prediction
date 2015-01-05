### task_2.5
### Stephen Franklin 2014-11-26
### This R script processes chunks of a text corpus iteratively
### into a data.table that contains these variables:
### V1 - V4: char: 4-gram separated accross 4 columns.
### twit, news, blog: int: frequency of each 4-gram in each source.
### Source: factor (t, n, b): source identifier.
### (optionally) Total: int: total frequency of 4-gram

### Libraries
rm(list=ls(all.names = T))  ## clear the environment
library(stylo)
library(data.table)
library(Revobase)

### Setup
setMKLthreads(16)
getMKLthreads()
setwd("~/en_USx/")
options(stringsAsFactors = FALSE) ## for readline()
docs<-list.files(getwd())
n <- 4  ## ngram
tot.freqs <- data.table(ngrams=character(0),twit=integer(0),
                        blog=integer(0),news=integer(0))

### Preprocess the data chunks
##### Sizes: Each chunk has 20k lines.
#####        Twitter chunks are 14 MB Blogs and News are 16 MB.
#####        The entire corpus is 557 MB.
##### Remove unwanted characters, i.e. non-printable, numbers, emoticons.
##### We'd like to keep apostrophes for now.
##### Apostrophes form contractions and the genitive (possessive) case.
##### We also want to keep carriage returns to keep the lines separated.
##### We're going lowercase.
######## Let's try with 47 MB of data.
system.time(
for(i in docs){
    apostrophe<-paste0("sed \"y/’/'/\" < ",i," > ",i,".apo")
    system(apostrophe)
    ### For OS X, use "sed -E" instead of "sed -r":
    dothis<-paste0("sed -r \"s/[^[:alpha:] \\r\\n']/ /g\" < ", i,".apo > ",i,".dot")
    system(dothis)
    tolower <- paste0("tr \"[:upper:]\" \"[:lower:]\" < ", i,".dot > ",i,".tol")
    system(tolower)
    rewrite_og <- paste0("mv ",i,".tol ",i)
    system(rewrite_og)
    system("rm *.apo")
    system("rm *.dot")
}
)

### FUNCTION: Use `stylo` to make 4-grams.
##### Returns a character list of 4-gram strings.
to_ngrams <- function(textchunk,n){
    require(stylo)
    gramn <- unlist( lapply( textchunk[grep(
        "[^ ]*[aeiouyAEIOUY]+[^ ]* [^ ]*[aeiouyAEIOUY]+[^ ]* [^ ]*[aeiouyAEIOUY]+[^ ]* [^ ]*[aeiouyAEIOUY]+[^ ]*", textchunk)],
        function(store) make.ngrams(txt.to.words(
            store, splitting.rule = "[ \t\n]+"), ngram.size = n) ) )
    gramn
}

### FUNCTION: Sort by frequency.
##### Returns a data.table of 2 variables:
#####   ngrams: char: 4-gram
#####   `sourcename`: int: frequency
#####   `sourcename` can be "twit","news", or "blog")
sort_freqs <- function(ngrams,sourcename){
    require(data.table)
    freqs <- as.data.table(table(ngrams))
    freqs <- freqs[order(-freqs$N),]
    ### Change variable N to source ###
    setnames(freqs,"N",sourcename)
    freqs
}

### FUNCTION: Add other sources' columns.
##### Returns a data.table of 4 variables:
#####   ngrams: char: 4-gram
#####   twit, news, blog: int: frequency
add_cols <- function(x.freq){
    if(!"twit" %in% names(x.freq))
        x.freq[,twit:=0]
    if(!"blog" %in% names(x.freq))
        x.freq[,blog:=0]
    if(!"news" %in% names(x.freq))
        x.freq[,news:=0]
    x.freq
}

### FUNCTION: Accumulate frequency counts.
##### Returns a data.table of 4 variables:
#####   ngrams: char: 4-gram
#####   twit, news, blog: int: frequency
accum_freqs <- function (freqs,new_freqs){
    require(data.table)
    cf <- rbind(freqs,new_freqs) ## combined freqs
    cf <- cf[, lapply(.SD, sum), by = c("ngrams")]
    ### See section 2.1 of http://cran.r-project.org/web/packages/data.table/vignettes/datatable-faq.pdf
    cf
}

### 
system.time(
for(i in docs){    
    sourcename<-unlist(strsplit(i, "_"))[2]
    text.l <- readLines(i,skipNul = T)
    text.n <- to_ngrams(text.l,n)
    freq.s <- sort_freqs(text.n,sourcename)
    freq.t <- add_cols(freq.s)
    tot.freqs <- accum_freqs(tot.freqs,freq.t)
}
)

save(tot.freqs, file="tot.freqs.RData")

### 3 files totaling 2.4 MB: 16 s
### 3 files, 10 MB, tot.freqs = 13 MB, 54 s

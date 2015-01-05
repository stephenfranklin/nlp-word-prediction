### obtain_corpus.R
### Stephen Franklin 2014-11-20
### This R script downloads the corpus 
### and splits the data into smaller files
### in order to alleviate frustration.

### We'll download `Coursera-SwiftKey.zip`.
### Expanding that will yield the directory `final`, 
### in which are directories for four locales 
### en_US, de_DE, ru_RU and fi_FI. 
### The data is from a corpus called HC Corpora 
### (http://www.corpora.heliohost.org/).

rm(list=ls(all.names = T))
setwd("~/")
options(stringsAsFactors = FALSE)
URL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
download.file(URL,destfile = "Coursera-SwiftKey.zip", method = "curl")
unzip("Coursera-SwiftKey.zip")

### Split the files into smaller chunks.
system("mkdir en_USx")
setwd("en_USx")
system("split -l 20000 ~/final/en_US/en_US.twitter.txt en_twit_")
system("split -l 20000 ~/final/en_US/en_US.news.txt en_news_")
system("split -l 20000 ~/final/en_US/en_US.blogs.txt en_blog_")
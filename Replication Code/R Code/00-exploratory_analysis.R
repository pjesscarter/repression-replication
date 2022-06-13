#Load packages for data exploration
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)

fnl <- data[[1]]

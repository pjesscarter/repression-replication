#Load packages for data exploration
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,sf,stargazer)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
shp <- read_sf("Map/cl_comunas_geo/Paper Replication/Data/Map/cl_comunas_geo.shp")
fnl <- data[[1]] 

fnl <- fnl %>% mutate(dist = exp(LnDistMilitaryBase),
               cutoff3 = as.numeric(dist<3),
               cutoff4 = as.numeric(dist<4),
               cutoff5 = as.numeric(dist<5),
               cutoff10 = as.numeric(dist<10),
               cutoff20 = as.numeric(dist<20),
               IDProv = as.factor(IDProv)
               )
makeform <- function(treat,outcome){
  #Edit to change baseline controls
  controls <- c("share_allende70",
                "share_alessandri70",
                "lnDistStgo",
                "lnDistRegCapital",
                "Pop70_pthousands",
                "sh_rural_70",
                "IDProv")
  f <- as.formula(
    paste(outcome, 
          paste(c(treat,controls), collapse = " + "), 
          sep = " ~ "))
}
#Sample options are 'main', 'nona', 'all'
#weights argument controls whether weighted regression is used
fitlm <- function(treat,outcome,sample="main",weights=T){
  
  if(sample=="nona"){
    mdat <- fnl %>% filter(!is.na(IDProv))
  } else if(sample=="all"){
    mdat <- fnl
  } else{
    mdat <- fnl %>% filter(MainSample==1)
  }
  
  if(weights){
    return(lm(makeform(treat,outcome),data=mdat,weights=Pop70))
  } else{
    return(lm(makeform(treat,outcome),data=mdat))
  }
}

#Victimization results, robustness to binary linear regression
#main result holds for cutoffs <5 miles
models<-list()
cutoffs <- c(3:5,10,20)
for(i in seq_along(cutoffs)){
  models[[i]]<-fitlm(treat = paste("cutoff",cutoffs[i],sep=""),
                     outcome = "shVictims_70",
                     sample = "main",
                     weights= T)
}
stargazer(models,
          style="apsr",paste0(cutoffs, " Miles"),
          keep=paste0("cutoff",cutoffs),
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Victimization"),
          keep.stat = c("n"))
#Repeat with a censored fuzzy RD design


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

fnl <- fnl %>% filter(!is.na(IDProv)) %>% mutate(dist = exp(LnDistMilitaryBase),
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

#Victimization results, robustness to binary linear regression
#main result holds for cutoffs <5 miles
models<-list()
cutoffs <- c(3:5,10,20)
for(i in seq_along(cutoffs)){
  models[[i]]<-lm(makeform(paste("cutoff",cutoffs[i],sep=""),"shVictims_70"),data=fnl,weights=Pop70)
  
}
stargazer(models,
          style="apsr",paste0(cutoffs, " Miles"),
          keep=paste0("cutoff",cutoffs),
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Victimization"),
          keep.stat = c("n"))
#Repeat with a censored fuzzy RD design


#Load packages for data exploration
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,sf,stargazer,rdrobust)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
shp <- read_sf("Map/cl_comunas_geo/Paper Replication/Data/Map/cl_comunas_geo.shp")
fnl <- data[[1]] 
#Note that 2 is the smallest integer cutoff such that any non-treated
#observations are included, but there are only 2 obs 1<d<2 and only 5: 2<d<3, so start with 3

fnl <- fnl %>% mutate(dist = exp(LnDistMilitaryBase),
               cutoff2 = as.numeric(dist<2),
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

#Voter registration
for(i in seq_along(cutoffs)){
  models[[i]]<-fitlm(treat = paste("cutoff",cutoffs[i],sep=""),
                     outcome = "Share_reg70_w2",
                     sample = "main",
                     weights= T)
}
stargazer(models,
          style="apsr",paste0(cutoffs, " Miles"),
          keep=paste0("cutoff",cutoffs),
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Voter Registration"),
          keep.stat = c("n"))
#Voter registration
for(i in seq_along(cutoffs)){
  models[[i]]<-fitlm(treat = paste("cutoff",cutoffs[i],sep=""),
                     outcome = "VoteShareNo",
                     sample = "main",
                     weights= T)
}
stargazer(models,
          style="apsr",paste0(cutoffs, " Miles"),
          keep=paste0("cutoff",cutoffs),
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("NO Vote Share"),
          keep.stat = c("n"))
#Recreate coefficient plots for Concertacion support


#Repeat with a latent fuzzy RD design - treatment variable is victims above the 75th
#percentile
#Compute bandwidth using rdbwselect, use default values for other variables for now

cutoffs <- seq(2,20,0.1)
#Store point estimate along with robust SE and p-value, plus cutoff
store <- matrix(nrow = length(cutoffs),ncol=4)
for(i in seq_along(cutoffs)){
  m <-tryCatch({rdrobust(y=fnl$shVictims_70,x=fnl$dist,fuzzy = fnl$DVictims_p75,
                 deriv =0,
                 c=cutoffs[i],
                 p=1,
                 q=2,
                 kernel = "epanechnikov",
                 masspoints="adjust",
                 subset = !is.na(fnl$IDProv),
                 covs = cbind(fnl$share_allende70,
                          fnl$share_alessandri70,
                          fnl$lnDistStgo,
                          fnl$lnDistRegCapital,
                          fnl$Pop70_pthousands,
                          fnl$sh_rural_70))},
               error = function(e) NA
               )
  if(!is.na(m)){
    store[i,] <- c(m$coef[3],m$se[3],m$pv[3],cutoffs[i])
  }
}
store[which(store[,3]<0.05),]

#Load packages for data exploration
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(lmtest,parallel,haven,data.table,stringr,dplyr,ggplot2,sf,stargazer,rdrobust,conleyreg,lfe,geosphere,Rcpp,RcppArmadillo)
setwd("../../conley-code/")
source("code/conley.R")
setwd("../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
shp <- read_sf("Map/cl_comunas_geo/Paper Replication/Data/Map/cl_comunas_geo.shp")
fnl <- data[[1]] 
setwd("../../conley-code/")
#Note that 2 is the smallest integer cutoff such that any non-treated
#observations are included, but there are only 2 obs 1<d<2 and only 5: 2<d<3, so start with 3

fnl <- fnl %>% mutate(dist = exp(LnDistMilitaryBase),
               IDProv = as.factor(IDProv),
               year = as.factor(1)
               )
makeform <- function(outcome){
  #Edit to change baseline controls
  controls <- c("share_allende70",
                "share_alessandri70",
                "lnDistStgo",
                "lnDistRegCapital",
                "Pop70_pthousands",
                "sh_rural_70")
  f <- as.formula(
    paste(paste(outcome, 
          paste(c("D",controls), collapse = " + "), 
          sep = " ~ "), "| year+ IDProv | 0 | longitud + latitud",sep=" "))
}
#Sample options are 'main', 'nona', 'all'
#weights argument controls whether weighted regression is used
fitlm <- function(treat,outcome,sample="main",weights=T,dc=3.11){
  mdat <- fnl %>% mutate(D = as.numeric(dist<treat))
  if(sample=="nona"){
    mdat <- mdat %>% filter(!is.na(IDProv))
  } else if(sample=="all"){
    mdat <- mdat
  } else{
    mdat <- mdat %>% filter(MainSample==1)
  }
  
  if(weights){
    mdat <- mdat %>% filter(!is.na(Pop70))
    m <- felm(makeform(outcome),
              data=mdat,weights = mdat$Pop70,keepCX=TRUE)
    SE <- ConleySEs(reg = m,
                    unit = "IDProv",
                    time = "year",
                    lat = "latitud", lon = "longitud",
                    dist_fn = "SH", dist_cutoff = dc,
                    cores = 1,
                    verbose = F)
    return(list(m,SE))
  } else{
    m <- felm(makeform(outcome),
              data=mdat,keepCX=TRUE)
    SE <- ConleySEs(reg = m,
                    unit = "IDProv",
                    time = "year",
                    lat = "latitud", lon = "longitud",
                    dist_fn = "SH", dist_cutoff = dc,
                    cores = 1,
                    verbose = F)
    return(list(m,SE))
  }
}

#Victimization results, robustness to binary linear regression
#Note that the largest comuna (Natales) has an area of approx 50 km^2, so 
#a military base within 30 miles is potentially still equivalent to being in the same county
cutoffs <- c(3:5,10,20,30,50,100)
cutoffrobust <- function(outcome,sample="main",weights=T){
  models<-list()
  ps <- list()
  ses <- list()

  for(i in seq_along(cutoffs)){
    m <-fitlm(treat = cutoffs[i],
                       outcome = outcome,
                       sample = sample,
                       weights= weights)
    models[[i]] <- m[[1]]
    ses[[i]] <- sqrt(diag(m[[2]]$Spatial_HAC))
    ps[[i]] <- coeftest(m[[1]],vcov=m[[2]]$Spatial_HAC)[,4]
  }
  return(list(models,ses,ps))
}
vct <- cutoffrobust("shVictims_70")
stargazer(vct[[1]],
          style="apsr",column.labels =  paste0(cutoffs, " Miles"),
          keep=1,
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Victimization"),
          keep.stat = c("n"), se =vct[[2]], p =vct[[3]])
#p values
stargazer(vct[[1]],
          style="apsr",column.labels =  paste0(cutoffs, " Miles"),
          keep=1,
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Victimization"),
          keep.stat = c("n"), se =vct[[2]], p =vct[[3]], report=('vc*p'))

#Voter registration
reg <- cutoffrobust("Share_reg70_w2")
stargazer(reg[[1]],
          style="apsr",column.labels =  paste0(cutoffs, " Miles"),
          keep=1,
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("Voter Registration"),
          keep.stat = c("n"), se =reg[[2]], p =reg[[3]])
#Vote share NO
nov <- cutoffrobust("VoteShareNo")
stargazer(nov[[1]],
          style="apsr",column.labels =  paste0(cutoffs, " Miles"),
          keep=1,
          covariate.labels = c("Treatment Indicator"),
          dep.var.labels = c("NO Vote Share"),
          keep.stat = c("n"),se =nov[[2]], p =nov[[3]])
#Recreate coefficient plots for Concertacion support
outcomes <- c("share_aylwin89",
              "share_frei93",
              "share_lagos99",
              "share_bachelet05",
              "share_frei09")

outcomenames <- c("Vote Share Aylwin 1989",
                  "Vote Share Frei 1993",
                  "Vote Share Lagos 1999",
                  "Vote Share Bachelet 2005",
                  "Vote Share Frei 2009")
voteshares <- list()
for(i in seq_along(outcomes)){
  voteshares[[i]] <- cutoffrobust(outcomes[i])
  }

for(i in seq_along(outcomes)){
  stargazer(voteshares[[i]][[1]],
            style="apsr",column.labels =  paste0(cutoffs, " Miles"),
            keep=1,
            covariate.labels = c("Treatment Indicator"),
            dep.var.labels = outcomenames[i],
            keep.stat = c("n"),se =voteshares[[i]][[2]], p =voteshares[[i]][[3]])
}
#Repeat with a latent fuzzy RD design - treatment variable is victims above the 75th
#percentile
#Compute bandwidth using rdbwselect, use default values for other variables for now

cutoffs <- seq(2,20,0.1)
#Store point estimate along with robust SE and p-value, plus cutoff
store <- matrix(nrow = length(cutoffs),ncol=4)
for(i in seq_along(cutoffs)){
  m <-tryCatch({rdrobust(y=fnl$Share_reg70_w2,x=fnl$dist,fuzzy = fnl$DVictims_p75,
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

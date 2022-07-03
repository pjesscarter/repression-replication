if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,sf,stargazer,rdrobust,randomForest,Matching)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
shp <- read_sf("Map/cl_comunas_geo/Paper Replication/Data/Map/cl_comunas_geo.shp")
fnl <- data[[1]] 
makeform <- function(outcome,extracontrols = NULL){
  #Edit to change baseline controls
  controls <- c("share_allende70",
                "share_alessandri70",
                "lnDistStgo",
                "lnDistRegCapital",
                "Pop70_pthousands",
                "sh_rural_70",
                "IDProv",extracontrols)
  f <- as.formula(
    paste(outcome, 
          paste(controls, collapse = " + "), 
          sep = " ~ "))
}
fnl_rf <- fnl %>% filter(!is.na(IDProv),!is.na(share_allende70),!!is.na(Pop70_pthousands)) %>% mutate(DMilitaryPresence = as.factor(DMilitaryPresence), IDProv = as.factor(IDProv))
rf_out <- randomForest(makeform("DMilitaryPresence"),data= fnl_rf,ntree=1000)
ps <- rf_out$votes[,2]
fnl_rf$propscore <- ps
#Decent overlap, but only for a small subset of treated observations
ggplot(fnl_rf,aes(x=ps,fill=DMilitaryPresence)) + geom_density(alpha=0.4)

fnl_rf_vict <- fnl_rf %>% filter(!is.na(shVictims_70)) %>% mutate(D = fnl_rf_vict$DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights
matched <- Match(Y=fnl_rf_vict$shVictims_70,
                 Tr=fnl_rf_vict$D,
                 X=fnl_rf_vict$propscore,
                 M=1,
                 weights = fnl_rf_vict$Pop70)
#ATT = 2.8983, SE = 1.5668, not significant at 95% level
#Dramatic improvement in covariate balance
mb <- MatchBalance(makeform("D"),data=fnl_rf_vict,match.out = matched,nboots=1000)

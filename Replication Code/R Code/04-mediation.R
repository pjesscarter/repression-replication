remove(list = ls())
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,mediation)

setwd("../../Extracted Files/Data")
#load("../../Replication Code/R Code/mediation.RData")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
fnl <- data[[1]] 
set.seed(08540)
dat <- fnl %>% filter(MainSample==1,!is.na(shVictims_70),!is.na(DMilitaryPresence),!is.na(Pop70)) %>% mutate(IDProv = as.factor(IDProv))
dat<- bind_cols(dat,model.matrix( ~ IDProv - 1, data=dat))
medform <- formula(paste("shVictims_70 ~ DMilitaryPresence + share_allende70 +share_alessandri70+lnDistStgo+lnDistRegCapital+Pop70_pthousands+sh_rural_70",paste0("IDProv",2:length(levels(dat$IDProv)),collapse = " + "),sep=" + "))
makeform <- function(outcome){
  outform <- formula(paste(paste(outcome, "~ DMilitaryPresence + shVictims_70 + share_allende70 +share_alessandri70+lnDistStgo+lnDistRegCapital+Pop70_pthousands+sh_rural_70"),paste0("IDProv",2:length(levels(dat$IDProv)),collapse = " + "),sep=" + "))
  return(outform)
}


  


outcomes <- c("VoteShareNo",
              "Share_reg70_w2",
              "share_aylwin89",
              "share_frei93",
              "share_lagos99",
              "share_bachelet05",
              "share_frei09")
medmods <- list()
m1 <-  lm(medform,data=dat,weights = dat$Pop70)
for(i in seq_along(outcomes)){
  form <- makeform(outcome=outcomes[i])
  m2 <-  lm(form,data=dat,weights = dat$Pop70)
  medmods[[i]] <- mediate(m1,m2,treat = 'DMilitaryPresence',mediator='shVictims_70',boot=T,sims=1000)
  
}
lapply(medmods,function(x){summary(x)})
save(medmods,file = "mediation.RData")

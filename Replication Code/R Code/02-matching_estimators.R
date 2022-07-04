if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,randomForest,Matching)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
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
fnl_rf <- fnl %>% dplyr::filter(!is.na(IDProv),!is.na(share_allende70),!is.na(Pop70_pthousands)) %>% mutate(DMilitaryPresence = as.factor(DMilitaryPresence), IDProv = as.factor(IDProv))
rf_out <- randomForest(makeform("DMilitaryPresence"),data= fnl_rf,ntree=1000)
ps <- rf_out$votes[,2]
fnl_rf$propscore <- ps
#Decent overlap, but only for a small subset of treated observations
ggplot(fnl_rf,aes(x=ps,fill=DMilitaryPresence)) + geom_density(alpha=0.4)

#Victimization
fnl_rf_vict <- fnl_rf %>% filter(!is.na(shVictims_70)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_rf_vict$shVictims_70,
                 Tr=fnl_rf_vict$D,
                 X=fnl_rf_vict$propscore,
                 M=1,
                 weights = fnl_rf_vict$Pop70,
                 estimand = "ATE",
                 caliper = 0.2) #optimal caliper per Austin 2011
#ATE = -0.42452 , SE = 0.48469, p = 0.3811 - sign swap!
#Dramatic improvement in covariate balance but 0 obvs in many provinces
#Note also that KS tests still have p-values close to 0 for most covariates
mb <- MatchBalance(makeform("D"),data=fnl_rf_vict,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_rf_vict[matched$index.treated,],fnl_rf_vict[matched$index.control,])


#NO Votes
fnl_rf_no <- fnl_rf %>% filter(!is.na(VoteShareNo)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_rf_no$VoteShareNo,
                 Tr=fnl_rf_no$D,
                 X=fnl_rf_no$propscore,
                 M=1,
                 weights = fnl_rf_no$Pop70,
                 estimand = "ATE",
                 caliper = 0.2) #optimal caliper per Austin 2011
#ATE = 0.46155, SE = 0.38294 , p = 0.22809  - not significant at conventional levels
#Dramatic improvement in covariate balance but 0 obvs in many provinces
#Note also that KS tests still have p-values close to 0 for most covariates
mb <- MatchBalance(makeform("D"),data=fnl_rf_no,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_rf_no[matched$index.treated,],fnl_rf_no[matched$index.control,])


#Registration
fnl_rf_reg <- fnl_rf %>% filter(!is.na(Share_reg70_w2)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_rf_reg$Share_reg70_w2,
                 Tr=fnl_rf_reg$D,
                 X=fnl_rf_reg$propscore,
                 M=1,
                 weights = fnl_rf_reg$Pop70,
                 estimand = "ATE",
                 caliper = 0.2) #optimal caliper per Austin 2011
#ATE = 56.021, SE = 1.1366  , p = 0 - very large and significant effect
#Dramatic improvement in covariate balance but 0 obvs in many provinces
#Note also that KS tests still have p-values close to 0 for most covariates
mb <- MatchBalance(makeform("D"),data=fnl_rf_reg,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_rf_reg[matched$index.treated,],fnl_rf_reg[matched$index.control,])


if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,randomForest,Matching,sf,ggmap,glmnet,glmnetUtils)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
fnl <- data[[1]] 
set.seed(08540)
#option to change propensity score estimation method - change to 'logit' for logit
psmodel <- "rf"
#Use all controls with ML estimation
controlset <- c("share_allende70",
                "share_alessandri70",
                "lnDistStgo",
                "lnDistRegCapital",
                "Pop70_pthousands",
                "sh_rural_70",
                "IDProv",
                "share_up71_local",
                "mayor_up71",
                "share_up73_congress",
                "landlocked",
                "Houses_pc",
                "ari_1973",
                "index1b",
                "SocialOrg_pop70",
                "sh_educ_12more",
                "densidad_1970",
                "sh_econactivepop_70")
makeform <- function(outcome,extracontrols = NULL){
  #Edit to change baseline controls
  controls <- unique(c("share_allende70",
                "share_alessandri70",
                "lnDistStgo",
                "lnDistRegCapital",
                "Pop70_pthousands",
                "sh_rural_70",
                "IDProv",extracontrols))
  f <- as.formula(
    paste(outcome, 
          paste(controls, collapse = " + "), 
          sep = " ~ "))
}

fnl_ps <- fnl %>% dplyr::select(longitud,latitud,all_of(controlset),DMilitaryPresence,Pop70,shVictims_70,Share_reg70_w2,VoteShareNo,all_of(c("share_aylwin89",
                                "share_frei93",
                                "share_lagos99",
                                "share_bachelet05",
                                "share_frei09"))) %>% mutate(DMilitaryPresence = as.factor(DMilitaryPresence), IDProv = as.factor(IDProv)) %>% na.omit()

if(psmodel == "rf"){
  rf_out <- randomForest(makeform("DMilitaryPresence",controlset),data= fnl_ps,ntree=1000)
  ps <- rf_out$votes[,2]
  fnl_ps$propscore <- ps
} else if (psmodel == "logit"){
  #prediction with elnet - model performs poorly with unregularized logit or pure lasso, but changes in alpha do not affect results
  #Use 3-fold cv due to small sample size
  foldids <- sample(1:3,nrow(fnl_ps),replace = T)
  logout <- cv.glmnet(model.matrix(makeform("DMilitaryPresence",controlset),fnl_ps),fnl_ps$DMilitaryPresence,family=binomial(),alpha=0.4,foldids=foldids)
  ps <- predict(logout,model.matrix(makeform("DMilitaryPresence",controlset),fnl_ps),s=logout$lambda.min,type="response")
  fnl_ps$propscore <- ps
}

#Decent overlap, but only for a small subset of treated observations
#Even worse if logit is used
ggplot(fnl_ps,aes(x=ps,fill=DMilitaryPresence)) + geom_density(alpha=0.4)

#Victimization
fnl_ps_vict <- fnl_ps %>% filter(!is.na(shVictims_70)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_ps_vict$shVictims_70,
                 Tr=fnl_ps_vict$D,
                 X=fnl_ps_vict$propscore,
                 M=1,
                 weights = fnl_ps_vict$Pop70,
                 estimand = "ATE",
                 caliper = 1) 
#ATE = 1.3547, SE = 0.10632, p < 2.22e-16 
#Dramatic improvement in covariate balance but 0 obvs in many provinces
#Note also that KS tests still have p-values close to 0 for most covariates
mb <- MatchBalance(makeform("D"),data=fnl_ps_vict,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_ps_vict[matched$index.treated,],fnl_ps_vict[matched$index.control,])
matchedunits$pair <- factor(rep(matched$index.treated, 2))
matchedunits$Treatment <- as.factor(ifelse(matchedunits$D,"Treatment","Control"))
shp <- read_sf("Map/cl_comunas_geo/Paper Replication/Data/Map/cl_comunas_geo.shp")
ggplot() + geom_sf(data = shp) + geom_point(data=matchedunits,aes(x=longitud,y=latitud,shape=pair,col = Treatment))
#NO Votes
fnl_ps_no <- fnl_ps %>% filter(!is.na(VoteShareNo)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_ps_no$VoteShareNo,
                 Tr=fnl_ps_no$D,
                 X=fnl_ps_no$propscore,
                 M=1,
                 weights = fnl_ps_no$Pop70,
                 estimand = "ATE",
                 caliper = 1) 
#ATE = -4.7927 , SE = 0.32414 , p < 2.22e-16
mb <- MatchBalance(makeform("D"),data=fnl_ps_no,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_ps_no[matched$index.treated,],fnl_ps_no[matched$index.control,])
matchedunits$pair <- factor(rep(M$index.treated, 2))

#Registration
fnl_ps_reg <- fnl_ps %>% filter(!is.na(Share_reg70_w2)) %>% mutate(D = DMilitaryPresence ==1)
#1:1 matching with replacement, using pop weights - authors do not specify estimand but
#can infer that it is the ATE
matched <- Match(Y=fnl_ps_reg$Share_reg70_w2,
                 Tr=fnl_ps_reg$D,
                 X=fnl_ps_reg$propscore,
                 M=1,
                 weights = fnl_ps_reg$Pop70,
                 estimand = "ATE",
                 caliper = 1) 
#ATE = 28.217, SE = 1.1573   , p < 2.22e-16 - very large and significant effect
#Dramatic improvement in covariate balance but 0 obvs in many provinces
#Note also that KS tests still have p-values close to 0 for most covariates
mb <- MatchBalance(makeform("D"),data=fnl_ps_reg,match.out = matched,nboots=1000)
#Examine matched outcomes - if we get the map we can plot these
matchedunits <- bind_rows(fnl_ps_reg[matched$index.treated,],fnl_ps_reg[matched$index.control,])
matchedunits$pair <- factor(rep(M$index.treated, 2))

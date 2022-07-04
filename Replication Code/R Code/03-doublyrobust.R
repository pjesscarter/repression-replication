rm(rm(list = ls()))
if(!require(pacman)){
  install.packages("pacman")
  library(pacman)
}
p_load(haven,stringr,dplyr,ggplot2,drtmle,nloptr,polspline)
setwd("../../Extracted Files/Data")
toload <- str_subset(list.files(),".dta")
data <- lapply(toload, read_dta)
fnl <- data[[1]] 
set.seed(08540)
fnl <- fnl  %>% filter(!is.na(IDProv)) %>% mutate(D = DMilitaryPresence, IDProv = as.factor(IDProv))
fnl<- bind_cols(fnl,model.matrix( ~ IDProv - 1, data=fnl ))
controls <- c("share_allende70",
              "share_alessandri70",
              "lnDistStgo",
              "lnDistRegCapital",
              "Pop70_pthousands",
              "sh_rural_70",
              paste0("IDProv",2:length(levels(fnl$IDProv))))
SL_library <- c("SL.randomForest", "SL.gam", "SL.mean","SL.npreg")
#Note - currently no consistent way to implement weighting in this method, so using population scaled
#outcomes where appropriate
#Victimization
fnl_vict <- fnl %>% dplyr::select(shVictims_70,all_of(controls),D) %>% na.omit()
#Use superleaner for OR and average over multiple calls
drobust <- drtmle(W = fnl_vict[,controls], A = fnl_vict$D, Y = fnl_vict$shVictims_70,
                    SL_g = SL_library, SL_Q = SL_library,
                    SL_gr = SL_library, SL_Qr = SL_library,
                    cvFolds=2,
                    avg_ovver= c("drtmle", "SL"),
                    n_SL = 10)
ci(drobust, contrast = c(-1,1))

#NO Votes
fnl_no <- fnl %>% dplyr::select(VoteShareNo_pop70,all_of(controls),D) %>% na.omit()
#Use superleaner for OR and average over multiple calls
drobust <- drtmle(W = fnl_no[,controls], A = fnl_no$D, Y = fnl_no$VoteShareNo_pop70,
                  SL_g = SL_library, SL_Q = SL_library,
                  SL_gr = SL_library, SL_Qr = SL_library,
                  cvFolds=2,
                  avg_ovver= c("drtmle", "SL"),
                  n_SL = 10)
ci(drobust, contrast = c(-1,1))

#Registration
fnl_reg <- fnl %>% dplyr::select(Share_reg70_w2,all_of(controls),D) %>% na.omit()
#Use superleaner for OR and average over multiple calls
drobust <- drtmle(W = fnl_reg[,controls], A = fnl_reg$D, Y = fnl_reg$Share_reg70_w2,
                  SL_g = SL_library, SL_Q = SL_library,
                  SL_gr = SL_library, SL_Qr = SL_library,
                  cvFolds=2,
                  avg_ovver= c("drtmle", "SL"),
                  n_SL = 10)
ci(drobust, contrast = c(-1,1))
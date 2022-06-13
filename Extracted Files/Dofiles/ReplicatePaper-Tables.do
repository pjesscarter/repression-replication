clear all
set more off
set seed 10001

*Required packages:
ssc install plausexog, replace
ssc install ivreg2, replace
ssc install ranktest, replace
ssc install latab, replace
ssc install parmest, replace
ssc install binscatter, replace
ssc install psacalc, replace

/////////////////////////////////////////////////////////////////////////////
////////Instructions:

// 1. Set the path to the "Paper Replication" folder
global path "xxx"

//2. Make sure "Paper Replication" folder contains:

*i) "Data" sub-folder with 4 files ("FinalDatasetForReplication", "LB_Analysis", "MilitaryBasesByYear", "VictimsByYear") and a "Temporary" sub-folder
*ii) "Logs", "Figures" and "Tables" sub-folders

//3. Make sure to have installed the following .ado files from the "Ado" folder: acreg, lassoShooting, x_ols, xmerge

/////////////////////////////////////////////////////////////////////////////

//Begin log
cap log using "${path}/Logs/log_Tables.smcl",replace

// Paths within the replication folder
	global DATA  	"${path}/Data/"
	global TABLES 	"${path}/Tables/"	
	global FIGURES 	"${path}/Figures/"	
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
// Folder
	cd "${TABLES}"
	
// Main globals	
	** Controls
	global C "share_allende70 share_alessandri70 lnDistStgo lnDistRegCapital Pop70_pthousands sh_rural_70"	
	** Weights
	global W "Pop70"

********************************************************************************
** MAIN PAPER
********************************************************************************	
	
**********	
** Table 1: Differences by military presence before the dictatorship	
**********
    global Mainvars "share_allende70 share_alessandri70 Turnout70 share_up71_local mayor_up71 share_up73_congress lnDistStgo lnDistRegCapital landlocked Pop70_pthousands Houses_pc SocialOrg_pop70 churches_pop70 sh_educ_12more densidad_1970 sh_rural_70 sh_econactivepop_70 sh_women_70 TV ari_1973 index1b"
	
	file open holder using PaperVersion_T1.tex, write replace text
	file write holder "\begin{tabular}{l c c c c } \toprule\toprule" _n
	file write holder "& (1) & (2) & (3) & (4)  \\" _n
	file write holder "& & \multicolumn{3}{c}{Projection on military presence (N=276)}\\\cmidrule(lr){3-5}" _n
	file write holder "& \begin{tabular}{c} Avg without \\ military presence \end{tabular}& \begin{tabular}{c} No Controls \end{tabular} &\begin{tabular}{c} Province FE &\begin{tabular}{c} Province FE + controls \end{tabular} &\begin{tabular}{c} With\\ Province FE \end{tabular}\\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}" _n
	file write holder "&\\" _n
	
		foreach i in $Mainvars {
		
		** Column 1: Average without military presence
		sum `i' [aw = Pop70] if DMilitaryPresence==0
		global m_`i': di %9.2f `= r(mean)'
		global sd_`i': di %9.2f `= r(sd)'
		
		** Column 2: No controls	
		reg `i' DMilitaryPresence [aw = $W], r 
		local b: di %9.2f `= _b[DMilitaryPresence]'	
		global se1_`i': di %9.2f `= _se[DMilitaryPresence]'	
		local t=_b[DMilitaryPresence]/_se[DMilitaryPresence]
		local p=2*ttail(`e(df_r)',abs(`t'))
		
		if `p'<=0.01 {
			global b1_`i' "`b'**"
		}

		if `p'<=0.05 & `p'>0.01 {
			global b1_`i' "`b'*"
		}
		
		if `p'>0.05  {
			global b1_`i' "`b'"
		}
		
		** Column 3: Province FE
		areg `i' DMilitaryPresence [aw = $W], r abs(IDProv)
		local b: di %9.2f `= _b[DMilitaryPresence]'	
		global se2_`i': di %9.2f `= _se[DMilitaryPresence]'	
		local t=_b[DMilitaryPresence]/_se[DMilitaryPresence]
		local p=2*ttail(`e(df_r)',abs(`t'))
		
		if `p'<=0.01 {
			global b2_`i' "`b'**"
		}

		if `p'<=0.05 & `p'>0.01 {
			global b2_`i' "`b'*"
		}

		if `p'>0.05  {
			global b2_`i' "`b'"
		}
		
		** Column 4: Province FE + controls
		areg `i' DMilitaryPresence $C [aw = $W], r abs(IDProv)
		local b: di %9.2f `= _b[DMilitaryPresence]'	
		global se3_`i': di %9.2f `= _se[DMilitaryPresence]'	
		local t=_b[DMilitaryPresence]/_se[DMilitaryPresence]
		local p=2*ttail(`e(df_r)',abs(`t'))
		
		if `p'<=0.01 {
			global b3_`i' "`b'**"
		}

		if `p'<=0.05 & `p'>0.01 {
			global b3_`i' "`b'*"
		}
		
		if `p'>0.05  {
			global b3_`i' "`b'"
		}
	
		local lab: variable label `i'
	
		file write holder "`lab' & ${m_`i'} & ${b1_`i'} & ${b2_`i'} & ${b3_`i'}  \\" _n
		file write holder "    & (${sd_`i'}) & (${se1_`i'}) & (${se2_`i'}) & (${se3_`i'}) \\" _n
		
	}
	file write holder "\toprule\toprule" _n	
	file write holder "\end{tabular} " _n
	file close holder
	
***********		
** TABLE 2: Impact of military presence on repression
***********		
	* Panel A
	global out outreg2 using PaperVersion_T2_PA, keep(DMilitaryPresence LnDistMilitaryBase) tex(frag)  label nocons sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x) alpha(0.01, 0.05) symbol(**, *)
	
	reghdfe shVictims_70 			DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
	sum shVictims_70 if e(sample)==1 [aw=$W]
	${out} ctitle(Victims) replace adds(DV mean, r(mean))

	reghdfe DVictims 				DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
	sum DVictims if e(sample)==1 [aw=$W]
	${out} ctitle(Dummy) append adds(DV mean, r(mean))

	reghdfe DVictims_p75 			DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
	sum DVictims_p75 if e(sample)==1 [aw=$W]
	${out} ctitle(Dummy75) append adds(DV mean, r(mean))

	reghdfe shVictims_residence_70 	DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
	sum shVictims_residence_70 if e(sample)==1 [aw=$W]
	${out} ctitle(Residence) append adds(DV mean, r(mean))

	reghdfe DetentionCenter 		DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
	sum DetentionCenter if e(sample)==1 [aw=$W]
	${out} ctitle(Detention) append adds(DV mean, r(mean))

	
	* Panel B	
	global out outreg2 using PaperVersion_T2_PB, keep(DMilitaryPresence LnDistMilitaryBase) label tex(frag)  nocons sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x) alpha(0.01, 0.05) symbol(**, *)
	
	reghdfe shVictims_70 			LnDistMilitaryBase $C [aw=$W], absorb(IDProv) vce(robust)
	sum shVictims_70 if e(sample)==1 [aw=$W]
	${out} ctitle(Victims) replace adds(DV mean, r(mean))

	reghdfe DVictims 				LnDistMilitaryBase $C [aw=$W], absorb(IDProv) vce(robust)
	sum DVictims if e(sample)==1 [aw=$W]
	${out} ctitle(Dummy) append adds(DV mean, r(mean))

	reghdfe DVictims_p75 			LnDistMilitaryBase $C [aw=$W], absorb(IDProv) vce(robust)
	sum DVictims_p75 if e(sample)==1 [aw=$W]
	${out} ctitle(Dummy75) append adds(DV mean, r(mean))

	reghdfe shVictims_residence_70 	LnDistMilitaryBase $C [aw=$W], absorb(IDProv) vce(robust)
	sum shVictims_residence_70 if e(sample)==1 [aw=$W]
	${out} ctitle(Residence) append adds(DV mean, r(mean))

	reghdfe DetentionCenter 		LnDistMilitaryBase $C [aw=$W], absorb(IDProv) vce(robust)
	sum DetentionCenter if e(sample)==1 [aw=$W]
	${out} ctitle(Detention) append adds(DV mean, r(mean))

	
	**** Adding p-values from Conley SE 		
	* Residuals from province FE
	foreach i in Share_reg70_w2 VoteShareNo VoteShareNo_pop70 shVictims_70 DetentionCenter shVictims_residence_70 DVictims_p75 DVictims {
		reg `i' i.IDProv [aw = $W]
		predict R`i', res
	}
	
	* Variable creation for weighted regression
	gen const   = 1	
	foreach i in const RShare_reg70_w2 RVoteShareNo RVoteShareNo_pop70 RshVictims_70 shVictims_70 RDetentionCenter RshVictims_residence_70 RDVictims_p75 RDVictims DMilitaryPresence LnDistMilitaryBase $C {
		g `i'W = `i' * sqrt(Pop70)
	}
	
	global CW "share_alessandri70W share_allende70W lnDistStgoW lnDistRegCapitalW Pop70_pthousandsW sh_rural_70W"
	gen cutoff1 = 3.11
	gen cutoff2 = 3.11	
	
	** Panel A
	* Column 1
	x_ols latitud longitud cutoff1 cutoff2 RshVictims_70W constW DMilitaryPresenceW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=2.085556/.23452032
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */
	
	x_ols latitud longitud cutoff1 cutoff2 RDVictimsW constW DMilitaryPresenceW 			$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.0766349/.04113821
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.064 */

	x_ols latitud longitud cutoff1 cutoff2 RDVictims_p75W constW DMilitaryPresenceW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.3947417/.05709914
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	x_ols latitud longitud cutoff1 cutoff2 RshVictims_residence_70W constW DMilitaryPresenceW 	$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=1.197009/.27844575
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	x_ols latitud longitud cutoff1 cutoff2 RDetentionCenterW constW DMilitaryPresenceW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=4.035368/.83574837
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	
	* Panel B	
	x_ols latitud longitud cutoff1 cutoff2 RshVictims_70W constW LnDistMilitaryBaseW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.6234139/.08261144
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	x_ols latitud longitud cutoff1 cutoff2 RDVictimsW constW LnDistMilitaryBaseW 			$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.0246181/.01424655
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.085 */

	x_ols latitud longitud cutoff1 cutoff2 RDVictims_p75W constW LnDistMilitaryBaseW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.1421476/.01954747
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	x_ols latitud longitud cutoff1 cutoff2 RshVictims_residence_70W constW LnDistMilitaryBaseW 	$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.35025/.09009801
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */

	x_ols latitud longitud cutoff1 cutoff2 RDetentionCenterW constW LnDistMilitaryBaseW 	$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.8742677/.25670844
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.001 */
	
***********		
** TABLE 3: Impact of military presence on the 1988 plebiscite	
***********		
	** PANEL A: REDUCED FORM
	global out outreg2 using PaperVersion_T3_PA, keep(DMilitaryPresence LnDistMilitaryBase) label nocons sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *)
	
	reghdfe Share_reg70_w2 		DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum Share_reg70_w2 if e(sample)==1 [aw=$W]
	${out} ctitle(reg) replace adds(DV mean, r(mean))

	reghdfe Share_reg70_w2 		LnDistMilitaryBase 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum Share_reg70_w2 if e(sample)==1 [aw=$W]
	${out} ctitle(reg) tex(frag) adds(DV mean, r(mean))

	reghdfe VoteShareNo 		DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum VoteShareNo if e(sample)==1 [aw=$W]
	${out} ctitle(No) tex(frag) adds(DV mean, r(mean))

	reghdfe VoteShareNo_pop70 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum VoteShareNo_pop70 if e(sample)==1 [aw=$W]
	${out} ctitle(No) tex(frag) adds(DV mean, r(mean))	

	reghdfe VoteShareNo 		LnDistMilitaryBase 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum VoteShareNo if e(sample)==1 [aw=$W]
	${out} ctitle(No) tex(frag) adds(DV mean, r(mean))

			
	**** Adding p-values from Conley SE 			
	x_ols latitud longitud cutoff1 cutoff2 RShare_reg70_w2W constW DMilitaryPresenceW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=9.254647/4.5721512
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.044 */
	
	x_ols latitud longitud cutoff1 cutoff2 RShare_reg70_w2W constW LnDistMilitaryBaseW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=2.980028/1.1865848
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.013 */
		
	x_ols latitud longitud cutoff1 cutoff2 RVoteShareNoW constW DMilitaryPresenceW 			$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=2.242306/1.2075711
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.064 */
		
	x_ols latitud longitud cutoff1 cutoff2 RVoteShareNo_pop70W constW DMilitaryPresenceW 	$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=6.214463/1.6334963
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.000 */
		
	x_ols latitud longitud cutoff1 cutoff2 RVoteShareNoW constW LnDistMilitaryBaseW 		$CW, xreg(8) coord(2)
	drop epsilon window dis1 dis2	
	local t=.7919693/.34786355
	local p=2*ttail(244,abs(`t'))
	di `p' /* 0.024 */

	** PANEL B: 2SLS
	global out outreg2 using PaperVersion_T3_PB, keep(shVictims_70) tex(frag) label nocons nor2 sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)
 
	xi: ivreg2 Share_reg70_w2 		$C  i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first
	${out} ctitle(IV-Registration) replace adds(Kleibergen Paap F-stat., `e(widstat)')

	xi: ivreg2 Share_reg70_w2 		$C  i.IDProv (shVictims_70 = LnDistMilitaryBase) [aw=$W], robust first  
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)')
		
	xi: ivreg2 VoteShareNo 			$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  	
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)')
		
	xi: ivreg2 VoteShareNo_pop70 	$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  	
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)')

	xi: ivreg2 VoteShareNo 			$C i.IDProv (shVictims_70 = LnDistMilitaryBase) [aw=$W], robust first
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)')

		
	**** Adding p-values from Conley SE 			
	acreg RShare_reg70_w2W $CW 		(shVictims_70W = DMilitaryPresenceW), ///
			spatial latitude(latitud) longitude(longitud) distcutoff(345.79) 
	* 0.128
	
	acreg RShare_reg70_w2W $CW 		(shVictims_70W = LnDistMilitaryBaseW), ///
			spatial latitude(latitud) longitude(longitud) distcutoff(345.79)
	* 0.103
	
	acreg RVoteShareNoW $CW 		(shVictims_70W = DMilitaryPresenceW), ///
			spatial latitude(latitud) longitude(longitud) distcutoff(345.79)
	* 0.075
	
	acreg RVoteShareNo_pop70W $CW 	(shVictims_70W = DMilitaryPresenceW), ///
			spatial latitude(latitud) longitude(longitud) distcutoff(345.79)
	* 0.000
	
	acreg RVoteShareNoW $CW 		(shVictims_70W = LnDistMilitaryBaseW), ///
			spatial latitude(latitud) longitude(longitud) distcutoff(345.79)
	* 0.057
	
***********		
** Table 4: Alternative mechanisms: public goods, unemployment and migration		
***********	
	
	global out outreg2 using PaperVersion_T4, tex(frag) keep(DMilitaryPresence) label nocons sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *)
		
	reghdfe publicgoods 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum publicgoods if e(sample)==1 [aw=$W]
	${out} ctitle(All) replace addstat(DV mean, `r(mean)') 

	reghdfe visible_pg 		DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum visible_pg if e(sample)==1 [aw=$W]
	${out} ctitle(More Visible)  addstat(DV mean, `r(mean)') 
		
	reghdfe lessvisible_pg 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum lessvisible_pg if e(sample)==1 [aw=$W]
	${out} ctitle(Less Visible) addstat(DV mean, `r(mean)') 

	reghdfe sh_unemp_82 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum sh_unemp_82 if e(sample)==1 [aw=$W]
	${out} ctitle(Unemp) addstat(DV mean, `r(mean)') 
		
	reghdfe sh_outmig_82 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum sh_outmig_82 if e(sample)==1 [aw=$W]
	${out} ctitle(OutMigrBirth) addstat(DV mean, `r(mean)') 
		
	reghdfe sh_outmig_82_77 DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum sh_outmig_82_77 if e(sample)==1 [aw=$W]
	${out} ctitle(OutMigr77) addstat(DV mean, `r(mean)') 
		
********************************************************************************	
********************************************************************************
** APPENDIX
********************************************************************************	
********************************************************************************	
	
********************************************************************************
** APPENDIX B: Further information about the data
********************************************************************************	

***********		
** Table B1: Descriptive statistics	
***********			

	** Column 1: Unweighted
	* Panel A
	latabstat DMilitaryPresence Share_reg70_w2 VoteShareNo shVictims_70  , c(s) s(mean) format(%9.2f)
	* Panel B
	latabstat share_alessandri70 share_allende70 lnDistStgo lnDistRegCapital sh_rural_70 Pop70_pthousands , c(s) s(mean) format(%9.2f)

	** Columns 2-5: weighted
	* Panel A
	latabstat DMilitaryPresence Share_reg70_w2 VoteShareNo shVictims_70 [aw = $W], c(s) s(mean sd min max) format(%9.2f)
	* Panel B
	latabstat share_alessandri70 share_allende70 lnDistStgo lnDistRegCapital sh_rural_70 Pop70_pthousands [aw = $W], c(s) s(mean sd min max) format(%9.2f)
	
	
********************************************************************************
** APPENDIX C: Additional Figures and Tables
********************************************************************************	


************	
** Table C1: Impact of military presence on repression by year
************
 	
	global out outreg2 using PaperVersion_TC1, keep(DMilitaryPresence LnDistMilitaryBase) label tex(frag)  nocons sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x) alpha(0.01, 0.05) symbol(**, *)  
	
	reghdfe shvictimas_until74_70 DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum shvictimas_until74_70 if e(sample)==1 [aw=$W]
	${out} ctitle([1973-1974]) replace adds(DV mean, r(mean))

	reghdfe shvictimas_75_plus_70 DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum shvictimas_75_plus_70 if e(sample)==1 [aw=$W]
	${out} ctitle([1975-1990]) append adds(DV mean, r(mean))

	reghdfe shvictimas_until74_70 LnDistMilitaryBase 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum shvictimas_until74_70 if e(sample)==1 [aw=$W]
	${out} ctitle([1973-1974]) append adds(DV mean, r(mean))

	reghdfe shvictimas_75_plus_70 LnDistMilitaryBase 	$C [aw=$W], absorb(IDProv) vce(robust)
	sum shvictimas_75_plus_70 if e(sample)==1 [aw=$W]
	${out} ctitle([1975-1990]) append adds(DV mean, r(mean))
	
************	
** Table C2: Impact of repression on the 1988 plebiscite: OLS vs IV
************

 	global out outreg2 using PaperVersion_TC2, tex(frag) label nocons keep(shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)

	reghdfe Share_reg70_w2 shVictims_70 $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(OLS-Registration) replace 

	reghdfe VoteShareNo shVictims_70 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(OLS-NO) 

	xi: ivreg2 Share_reg70_w2 			$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first  
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
	xi: ivreg2 VoteShareNo 				$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first 
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
	
	
************	
** Table C4: Characterization of compliers
************
	global Vars "Houses_pc giniunf ari_1973 LeftWing RightWing Share_reg70_w2 VoteShareNo Year73 Year74 YearPost75 Laborer Farmer Military Bureaucrat Student PartyMember StudentAge WorkingAge Retired"

	sum shVictims_70, d
	g T = (shVictims_70>r(p75))
	sum shVictims_70 if T == 1, d
	g T2 = 1-T
	
	sum share_alessandri70, d
	g RightWing = (share_alessandri70>=r(p75))

	sum share_allende70, d
	g LeftWing = (share_allende70>=r(p75))
	
	**** Treated	
	foreach k in $Vars {
		g X = `k' * T
		display("** `k' **")
		xi: ivreg2 X $C  i.IDProv (T = DMilitaryPresence) [aw=$W]	, robust    
		global b1_`k': di %9.2f `= _b[T]'	
		drop X
	}

	***** Non treated
	foreach k in $Vars {
		g X = `k' * T2
		display("** `k' **")
		xi: ivreg2 X $C  i.IDProv (T2 = DMilitaryPresence) [aw=$W]	, robust    
		global b2_`k': di %9.2f `= _b[T2]'	
		drop X
	}
		
	** Full sample
	foreach i in $Vars {
		sum `i' [aw = $W]
		global m_`i': di %9.2f `= r(mean)'		
	}
	
	** Table	
	file open holder using PaperVersion_TC4.tex, write replace text
	file write holder "\begin{tabular}{l c c c c} \toprule\toprule" _n
	file write holder "& (1) & (2) & (3) \\" _n
	file write holder "& Treated & Untreated & Full sample\\" _n
	file write holder "&\\" _n
	file write holder "Houses per capita in 1970 & $b1_Houses_pc & $b2_Houses_pc    & $m_Houses_pc \\" _n
	file write holder "Land inequality 1965 \small{(Gini)} & $b1_giniunf & $b2_giniunf    & $m_giniunf \\" _n	
	file write holder "Agrarian reform intensity & $b1_ari_1973 & $b2_ari_1973    & $m_ari_1973 \\" _n
	file write holder "Vote share Allende 1970 & $b1_LeftWing & $b2_LeftWing  & $m_LeftWing \\" _n
	file write holder "Vote share Alessandri 1970 & $b1_RightWing & $b2_RightWing   & $m_RightWing \\" _n	
	file write holder "Registration & $b1_Share_reg70_w2 & $b2_Share_reg70_w2    & $m_Share_reg70_w2 \\" _n
	file write holder "Vote share ``No''  & $b1_VoteShareNo & $b2_VoteShareNo    & $m_VoteShareNo \\" _n
	file write holder "In 1973 &   $b1_Year73 &   $b2_Year73 & $m_Year73   \\" _n
	file write holder "In 1974   &   $b1_Year74 &   $b2_Year74 & $m_Year74   \\" _n
	file write holder "$\geq$1975 &   $b1_YearPost75 &   $b2_YearPost75   & $m_YearPost75   \\" _n
	file write holder "Laborer &   $b1_Laborer &   $b2_Laborer & $m_Laborer   \\" _n
	file write holder "Farmer & $b1_Farmer & $b2_Farmer   & $m_Farmer \\" _n
	file write holder "Military &   $b1_Military &   $b2_Military  & $m_Military   \\" _n
	file write holder "Bureaucrat &   $b1_Bureaucrat &   $b2_Bureaucrat & $m_Bureaucrat   \\" _n
	file write holder "Student & $b1_Student & $b2_Student    & $m_Student \\" _n
	file write holder "Affiliated to political party & $b1_PartyMember & $b2_PartyMember & $m_PartyMember\\" _n
	file write holder "$\in[18,25]$ & $b1_StudentAge & $b2_StudentAge    & $m_StudentAge \\" _n
	file write holder "$\in[25,60]$ & $b1_WorkingAge & $b2_WorkingAge    & $m_WorkingAge \\" _n
	file write holder "$\geq 60$ & $b1_Retired & $b2_Retired    & $m_Retired \\" _n
	file write holder "\toprule\toprule" _n	
	file write holder "\end{tabular} " _n
	file close holder	
	
	
	
********************************************************************************
** APPENDIX D: Robustness checks 
********************************************************************************	

***********		
** Table D1: Robustness of results to different sets of controls
***********	

// Panel A: All controls
	global out outreg2 using PaperVersion_TD1_PA, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x) alpha(0.01, 0.05) symbol(**, *)  
	
    global vars "share_allende70 share_alessandri70 share_up71_local mayor_up71 share_up73_congress lnDistStgo lnDistRegCapital Pop70_pthousands landlocked Houses_pc ari_1973 index1b SocialOrg_pop70 sh_educ_12more densidad_1970 sh_rural_70 sh_econactivepop_70 "
	
	reghdfe shVictims_70 	DMilitaryPresence $vars [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) noobs replace 

	reghdfe Share_reg70_w2 	DMilitaryPresence $vars [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration) noobs 

	reghdfe VoteShareNo 	DMilitaryPresence $vars [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO) noobs

	xi: ivreg2 Share_reg70_w2 	$vars  i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first  		
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
		
	xi: ivreg2 VoteShareNo 		$vars  i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first  
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs

// Panel B: LASSO controls
	global out outreg2 using PaperVersion_TD1_PB, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 
	
	** Outcome RF
	xi: lassoShooting VoteShareNo 	$vars i.IDProv, lasiter(100) verbose(0) fdisplay(0)					
	local NORF `r(selected)' 

	di "`NORF'" 

	xi: lassoShooting Share_reg70_w2 $vars i.IDProv, lasiter(100) verbose(0) fdisplay(0)					
	local RegRF `r(selected)' 

	di "`RegRF'" 
	
	** Endogenous RF
	xi: lassoShooting shVictims_70 $vars i.IDProv, lasiter(100) verbose(0) fdisplay(0)					
	local ENDRF `r(selected)' 

	di "`ENDRF'" 
		
	** IV RF
	xi: lassoShooting DMilitaryPresence $vars i.IDProv, lasiter(100) verbose(0) fdisplay(0)					
	local IVRF `r(selected)' 

	di "`IVRF'" 
	
	** Group variables
	local NoC : list IVRF | ENDRF 
	local NoC : list NoC | NORF
	
	di "`NoC'" 

	local RegC : list IVRF | ENDRF 
	local RegC : list RegC | RegRF
	di "`RegC'" 
	
	local TotC : list NoC | RegC
	di "`TotC'" 
	
	reghdfe shVictims_70 	DMilitaryPresence `TotC' [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) replace 

	reghdfe Share_reg70_w2 	DMilitaryPresence `TotC' [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration)  

	reghdfe VoteShareNo 	DMilitaryPresence `TotC' [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO)  
		
	xi: ivreg2 Share_reg70_w2 	`TotC' i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  		
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
	xi: ivreg2 VoteShareNo 		`TotC' i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
	
	
************	
** Table D2: Robustness of results to spatial controls
************

// Panel A: Latitude/longitude polynomial
	global out outreg2 using PaperVersion_TD2_PA, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

	global DC "longitud latitud longitud_2 latitud_2"	
	
	reghdfe shVictims_70 	DMilitaryPresence $DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) replace 

	reghdfe Share_reg70_w2 	DMilitaryPresence $DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration) 

	reghdfe VoteShareNo 	DMilitaryPresence $DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO) 

	xi: ivreg2 Share_reg70_w2 	$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  		
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
		
	xi: ivreg2 VoteShareNo 	  	$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  		
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
		
// Panel B: Centrality
	global out outreg2 using PaperVersion_TD2_PB, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

	global DC "ln_AvgDistance"	
	
	reghdfe shVictims_70 DMilitaryPresence 		$DC $C[aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence 	$DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration) 

	reghdfe VoteShareNo DMilitaryPresence 		$DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO) 

	xi: ivreg2 Share_reg70_w2 	$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first  		
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
		
	xi: ivreg2 VoteShareNo 		$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust  first  		
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
		
// Panel C: Moran eigenvectors

	global out outreg2 using PaperVersion_TD2_PC, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

	global DC "mev1 mev2 mev3 mev4 mev5 mev6 mev7 mev8 mev9"	
	
	reghdfe shVictims_70 DMilitaryPresence 		$DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence 	$DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration) 

	reghdfe VoteShareNo DMilitaryPresence 		$DC $C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO) 

	xi: ivreg2 Share_reg70_w2 	$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) $R [aw=$W], robust first  		
	${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
	xi: ivreg2 VoteShareNo 		$DC $C i.IDProv (shVictims_70 = DMilitaryPresence) $R [aw=$W], robust first	
	${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
************
** Table D3: Robustness: Military presence and other facilities/institutions
************
	global out outreg2 using PaperVersion_TD3_PA, tex(frag) label nocons keep(DMilitaryPresence facility) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)

// PANEL A: REGISTRATION
	** MAIN
	gen facility = ports 
	reghdfe Share_reg70_w2 DMilitaryPresence 			$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Main) replace 
	
	** PORT	
	label var facility "Indicator other institution"
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Port) 
	
	** AIRPORTS
	replace facility = airports 	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Airport) 
	
	** ENTRY POINT
	replace facility = EntryPoint 	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Entry point) 
	
	** POWER PLANT
	replace facility = powerplant1970 	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Power plant) 
	
	** PROVINCE CAPITAL
	replace facility = ProvCapital	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Provincial capital) 
	
	** REGONAL CAPITAL
	replace facility = RegCapital	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Regional capital) 

	** CHURCH
	replace facility = churches_pop70	
	reghdfe Share_reg70_w2 DMilitaryPresence facility 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Church) 
	drop facility
	

// PANEL B: NO
	global out outreg2 using PaperVersion_TD3_PB, tex(frag) label nocons keep(DMilitaryPresence facility) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 
	
	** MAIN
	gen facility = ports 
	reghdfe VoteShareNo DMilitaryPresence 				$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Main) replace 
	
	** PORTS
	label var facility "Indicator other institution"
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Port) 
	
	** AIRPORTS
	replace facility = airports 	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Airport) 
	
	** ENTRY POINT
	replace facility = EntryPoint 	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Entry point) 
	
	** POWER PLANT
	replace facility = powerplant1970 	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Power plant) 
	
	** PROVINCE CAPITAL
	replace facility = ProvCapital	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Provincial capital) 
	
	** REGONAL CAPITAL
	replace facility = RegCapital	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Regional capital) 

	** CHURCH
	replace facility = churches_pop70	
	reghdfe VoteShareNo DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Church) 
	drop facility
	
// PANEL C: VICTIMIZATION	
	global out outreg2 using PaperVersion_TD3_PC, tex(frag) label nocons keep(DMilitaryPresence facility) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)
	
	** MAIN
	gen facility = ports	
	reghdfe shVictims_70 DMilitaryPresence 					$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Main) replace 
	
	** PORTS 	
	label var facility "Indicator other institution"
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Port) 
	
	** AIRPORTS
	replace facility = airports 	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Airport) 
	
	** ENTRY POINT
	replace facility = EntryPoint 	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Entry point) 
	
	** POWER PLANT
	replace facility = powerplant1970 	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Power plant) 
	
	** PROVINCE CAPITAL
	replace facility = ProvCapital	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Provincial capital) 
	
	** REGONAL CAPITAL
	replace facility = RegCapital	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Regional capital) 

	** CHURCH
	replace facility = churches_pop70	
	reghdfe shVictims_70 DMilitaryPresence facility 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Church) 
	drop facility
	
		
************	
** Table D4: Robustness to different cut-off years for military base construction	
************	
	global out outreg2 using PaperVersion_TD4_PA, tex(frag) label nocons keep(shVictims_70 DMilitaryPresence_pre1960) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

// PANEL A: Pre 1960
	reghdfe shVictims_70 DMilitaryPresence_pre1960 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence_pre1960 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Registration) 

	reghdfe VoteShareNo DMilitaryPresence_pre1960 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(NO) 
	
	xi: ivreg2 Share_reg70_w2	$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1960) [aw=$W], robust  first	
	${out} ctitle(IV-Registration)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
	
	xi: ivreg2 VoteShareNo		$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1960) [aw=$W], robust  first	
	${out} ctitle(IV-NO)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs

// PANEL B: Pre 1950
	global out outreg2 using PaperVersion_TD4_PB, tex(frag) label nocons keep(shVictims_70 DMilitaryPresence_pre1950) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

	reghdfe shVictims_70 DMilitaryPresence_pre1950 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence_pre1950 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Registration) 

	reghdfe VoteShareNo DMilitaryPresence_pre1950 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(NO) 

	xi: ivreg2 Share_reg70_w2	$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1950) [aw=$W], robust  first	
	${out} ctitle(IV-Registration)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
	
	xi: ivreg2 VoteShareNo		$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1950) [aw=$W]	, robust  first	
	${out} ctitle(IV-NO)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2 noobs
	
// PANEL C: Pre 1940
	global out outreg2 using PaperVersion_TD4_PC, tex(frag) label nocons keep(shVictims_70 DMilitaryPresence_pre1940) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)

	reghdfe shVictims_70 DMilitaryPresence_pre1940 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence_pre1940 	$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(Registration) 

	reghdfe VoteShareNo DMilitaryPresence_pre1940 		$C [aw=$W], absorb(IDProv) vce(robust)
	${out} ctitle(NO) 
	
	xi: ivreg2 Share_reg70_w2	$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1940) [aw=$W], robust  first	
	${out} ctitle(IV-Reg)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2
	
	xi: ivreg2 VoteShareNo		$C i.IDProv (shVictims_70 = DMilitaryPresence_pre1940) [aw=$W], robust  first	
	${out} ctitle(IV-NO)  adds(Kleibergen Paap F-stat., `e(widstat)') nor2
	
************		
** Table D5: Robustness of results to inclusion of outliers	
************		
	preserve
// PANEL A: Inclusion of outliers	
	use "${DATA}FinalDatasetForReplication.dta", clear
		
		global out outreg2 using PaperVersion_TD5_PA, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)

		reghdfe shVictims_70 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(FS-Victims) replace 

		reghdfe Share_reg70_w2 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-Registration) 

		reghdfe VoteShareNo 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-NO) 

		xi: ivreg2 Share_reg70_w2 	$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  		
		${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
			
		xi: ivreg2 VoteShareNo 		$C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first  		
		${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
	
// PANEL B: Winsorize victimization	
		sum shVictims_70, d
		g shVictims_70W = shVictims_70
		replace shVictims_70W = 11.48 if shVictims_70 > 12
		
		global out outreg2 using PaperVersion_TD5_PB, tex(frag) label nocons keep(DMilitaryPresence shVictims_70W) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  alpha(0.01, 0.05) symbol(**, *) 

		reghdfe shVictims_70W 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(FS-Victims) replace 

		reghdfe Share_reg70_w2 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-Registration) 

		reghdfe VoteShareNo 	DMilitaryPresence 	$C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-NO) 

		xi: ivreg2 Share_reg70_w2 	$C i.IDProv (shVictims_70W = DMilitaryPresence) [aw=$W], robust first  		
		${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
			
		xi: ivreg2 VoteShareNo 		$C i.IDProv (shVictims_70W = DMilitaryPresence) [aw=$W], robust first  		
		${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
		
// PANEL C: Add a dummy for outliers
		reghdfe shVictims_70 DMilitaryPresence 		$C2 	[aw=$W], absorb(IDProv) vce(robust)
		g outlier = 1 if e(sample) == 1
		reghdfe shVictims_70 DMilitaryPresence 		$C2 if MainSample == 1 	[aw=$W], absorb(IDProv) vce(robust)
		replace outlier = 0 if e(sample) == 1
		
		global out outreg2 using PaperVersion_TD5_PC, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)  

		reghdfe shVictims_70 DMilitaryPresence 		outlier $C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(FS-Victims) replace 

		reghdfe Share_reg70_w2 DMilitaryPresence 	outlier $C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-Registration) 

		reghdfe VoteShareNo DMilitaryPresence 		outlier $C [aw=$W], absorb(IDProv) vce(robust)
		${out} ctitle(RF-NO) 

		xi: ivreg2 Share_reg70_w2 	outlier $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first 
		${out} ctitle(IV-Registration) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
			
		xi: ivreg2 VoteShareNo 		outlier $C i.IDProv (shVictims_70 = DMilitaryPresence) [aw=$W], robust first 
		${out} ctitle(IV-NO) adds(Kleibergen Paap F-stat., `e(widstat)') nor2
		
	restore		

	
************	
** Table D6: Robustness of results to exclusion of population weights
************

	global out outreg2 using PaperVersion_TD6, tex(frag) label nocons keep(DMilitaryPresence shVictims_70) sdec(3) bdec(3) addtext(Province fixed effects, x, Controls, x)   alpha(0.01, 0.05) symbol(**, *)

	reghdfe shVictims_70 DMilitaryPresence 		$C , absorb(IDProv) vce(robust)
	${out} ctitle(FS-Victims) replace 

	reghdfe Share_reg70_w2 DMilitaryPresence 	$C , absorb(IDProv) vce(robust)
	${out} ctitle(RF-Registration) 

	reghdfe VoteShareNo DMilitaryPresence 		$C , absorb(IDProv) vce(robust)
	${out} ctitle(RF-NO) 

	xi: ivreg2 Share_reg70_w2 	$C i.IDProv (shVictims_70 = DMilitaryPresence) , robust first  		
	${out} ctitle(IV-Registration) adds(F excl inst, `e(widstat)') nor2
		
	xi: ivreg2 VoteShareNo 		$C i.IDProv (shVictims_70 = DMilitaryPresence) , robust first 		
	${out} ctitle(IV-NO) adds(F excl inst, `e(widstat)') nor2	
	

	
********************************************************************************
** APPENDIX E: Political ideology in Latinobarómetro
********************************************************************************	
	
************	
** Table E1: Impact of the military coup on expressed political ideology	
************
	
use "${DATA}LB_Analysis.dta", clear

	// Comuna numerical ID
	egen idcom = group(id_comuna)

	// Define Exposure to Dictatorship
	gen birth_year=year-Age
	gen edad73=1973-birth_year	 
	gen Exposed=(edad73>=10)
	gen DregExposed=DMilitaryPresence*Exposed

*************
*** TABLE ***
*************

	global Survey DemocracyPreferable DictUnderSomeCirc DemocracyBestFormAgree DemocracySolves NoPolPartNoDemo NeverSupportMilitaryGov None Left Center Right ScaleLeftRight 

// ALL YEARS

	file open holder using PaperVersion_TE1.tex, write replace text
			file write holder "\begin{tabular}{l c c c c} \toprule\toprule" _n
			file write holder "& (1) & (2) & (3) & (4) \\" _n
			file write holder "& $\beta$ & Std error & Mean Dep Var & Obs \\ \cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}"
			file write holder "&\\" _n
			
	foreach i in $Survey{
			
		reghdfe `i' DregExposed, absorb(i.year i.idcom i.birth_year i.Sex) cluster(idcom)

		sum `i' if e(sample)==1
		global m_`i': di %9.3f `= r(mean)'
		local b: di %9.3f `=_b[DregExposed]'	
		global N_`i': di %9.0f `=e(N)'	
		global se1_`i': di %9.3f `=_se[DregExposed]'	
		local t=_b[DregExposed]/_se[DregExposed]	
		
		reghdfe `i' DregExposed, absorb(i.year i.idcom i.birth_year i.Sex) cluster(idcom)
		
		local p=2*ttail(`e(df_r)',abs(`t'))
				
		if `p'<=0.01 {
			global b1_`i' "`b'**"
		}
		if `p'<=0.05 & `p'>0.01 {
			global b1_`i' "`b'*"
		}
		if `p'>0.05  {
			global b1_`i' "`b'"
		}

	label var `i' "`i'"
	local lab: variable label `i'
	file write holder "`lab' & ${b1_`i'} & (${se1_`i'} ) & ${m_`i'} & ${N_`i'}  \\" _n
				
	}

	file write holder "\toprule\toprule" _n	
	file write holder "\end{tabular} " _n
	file close holder	

	log close
	
**********************************************************************************	
// 	END
**********************************************************************************
	

	

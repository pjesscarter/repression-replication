clear all
set more off
set seed 11111

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

//4. This local reduces the amount of output (i.e. smaller log file) but can be removed to get the full results
local qui qui

//5. This local generates a pause in the do-file and helps resolve issues in saving (i.e. increase if "Write-only file" error appears, decrease to improve speed)
local sleep 1000

/////////////////////////////////////////////////////////////////////////////

//Begin log
cap log using "${path}\Logs\log_Figures.log",replace

// Paths within the replication folder
	global DATA  	"${path}/Data/"
	global TEMP  	"${path}/Data/Temporary/"
	global TABLES 	"${path}/Tables/"	
	global FIGURES 	"${path}/Figures/"	
	
// Folder
	cd "${FIGURES}"
	
// Main globals	
	** Controls
	global C "share_allende70 share_alessandri70 lnDistStgo lnDistRegCapital Pop70_pthousands sh_rural_70"	
	** Weights
	global W "Pop70"

********************************************************************************
** MAIN PAPER
********************************************************************************	

**************************************************************************************
**************************************************************************************	
**  Figure 1: Military presence and repressionFigure 1: Military presence and repression
**************************************************************************************
**************************************************************************************	

/*
The subfolder Map inside the Data folder provides all the data for the construction of the maps. Detailed instructions available in the README file in that folder.
*/

**************************************************************************************
**************************************************************************************	
** Figure 2: Military presence and Allende or UP vote share before 1973
**************************************************************************************
**************************************************************************************	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1

	
	** Controls: Excluding political
	global C1 	"lnDistStgo lnDistRegCapital  Pop70_pthousands sh_rural_70"	/* CONTROLS */

	`qui' reghdfe share_allende52 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp", replace) idstr("none") idnum(1952)
	`qui' reghdfe share_allende52 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp1", replace) idstr("muni") idnum(1952)
	`qui' reghdfe share_allende52 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp2", replace) idstr("full") idnum(1952)
	
	`qui' reghdfe share_allende58 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp3", replace) idstr("none") idnum(1958)
	`qui' reghdfe share_allende58 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp4", replace) idstr("muni") idnum(1958)
	`qui' reghdfe share_allende58 DMilitaryPresence $C1 share_allende52 share_ibanez52 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp5", replace) idstr("full") idnum(1958)
	
	`qui' reghdfe share_allende64 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp6", replace) idstr("none") idnum(1964)
	`qui' reghdfe share_allende64 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp7", replace) idstr("muni") idnum(1964)
	`qui' reghdfe share_allende64 DMilitaryPresence $C1 share_alessandri58 share_allende58 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp8", replace) idstr("full") idnum(1964)
	
	`qui' reghdfe share_allende70 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp9", replace)	 idstr("none") idnum(1970)
	`qui' reghdfe share_allende70 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp10", replace)	 idstr("muni") idnum(1970)
	`qui' reghdfe share_allende70 DMilitaryPresence $C1 share_allende64 share_frei64 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp11", replace)	 idstr("full") idnum(1970)

	`qui' reghdfe share_up71_local DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp12", replace) idstr("none") idnum(1971)
	`qui' reghdfe share_up71_local DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp13", replace) idstr("muni") idnum(1971)
	`qui' reghdfe share_up71_local DMilitaryPresence $C1 share_alessandri70 share_allende70 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp14", replace) idstr("full") idnum(1971)

	`qui' reghdfe share_up73_congress DMilitaryPresence   		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp15", replace) idstr("none") idnum(1973)
	`qui' reghdfe share_up73_congress DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp16", replace) idstr("muni") idnum(1973)
	`qui' reghdfe share_up73_congress DMilitaryPresence $C1 share_alessandri70 share_allende70 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp17", replace) idstr("full") idnum(1973)
	
	preserve
		use "${TEMP}temp", clear
		keep in 1
		forvalues x =1/17{
			local y = 1+`x'
			append using "${TEMP}temp`x'"
			keep in 1/`y'
		}
		gen time =1 if _n==2
		replace time=3 if _n==5
		replace time=5 if _n==8
		replace time=7 if _n==11
		replace time=9 if _n==14
		replace time=11 if _n==17
		replace time=time[_n+1]-0.4 if time==.&time[_n+1]!=.
		replace time=time[_n-1]+0.4 if time==.&time[_n-1]!=.
		
		
		twoway (scatter estimate time if idstr=="none") (scatter estimate time if idstr=="muni", msymbol(triangle)) (scatter estimate time if idstr=="full", msymbol(square)) (rcap min95 max95 time), ytitle(Impact of military presence on vote share) ylabel(, angle(horizontal)) xtitle(Election) xlabel(1 "1952" 3 "1958" 5 "1964" 7 "1970" 9 "1971" 11 "1973") legend(order(1 "Prov. FE" 2 "Prov. FE + econ. controls" 3 "Prov. FE + all controls") rows(1)) yline(0, lcolor(gs10)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_F2.pdf", replace
	restore	
	
*****************************************************************
*****************************************************************	
** Figure 3: Military presence, repression and plebiscite outcomes
*****************************************************************
*****************************************************************	
* Change a bit
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1

	binscatter shVictims_70 	LnDistMilitaryBase  [aw=${W}], nq(100) linetype(lfit) ///
	controls($C) absorb(IDProv)  ytitle("Victims per 10,000 inh.") ylabel(,angle(horizontal)) xtitle("Log distance closest military base") scale(1.6) plotr(style(none)) color(black)		
	graph export "PaperVersion_F3_PA.pdf", replace
	
	binscatter Share_reg70_w2 	LnDistMilitaryBase [aw=${W}], nq(100) linetype(lfit) ///
	controls($C) absorb(IDProv) ytitle("Voter registration rate (%)") ylabel(,angle(horizontal)) xtitle("Log distance closest military base") scale(1.6) plotr(style(none)) color(black)
	graph export "PaperVersion_F3_PB.pdf", replace
	
	binscatter VoteShareNo 		LnDistMilitaryBase [aw=${W}], nq(100) linetype(lfit) ///
	controls($C) absorb(IDProv) ytitle("NO Vote share (%)") ylabel(,angle(horizontal)) xtitle("Log distance closest military base") scale(1.6) plotr(style(none)) color(black)
	graph export "PaperVersion_F3_PC.pdf", replace
	
	
************************************************************************
************************************************************************	
** Figure 4: Military presence and “Concertación” vote share after 1988
************************************************************************
************************************************************************	
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
	`qui' reghdfe share_aylwin89 		DMilitaryPresence $C [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp", replace)
	`qui' reghdfe share_frei93 		DMilitaryPresence 	$C [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp1", replace)
	`qui' reghdfe share_lagos99 		DMilitaryPresence $C [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp2", replace)
	`qui' reghdfe share_bachelet05 	DMilitaryPresence $C [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp3", replace)
	`qui' reghdfe share_frei09 		DMilitaryPresence 	$C [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp4", replace)


	preserve
		use "${TEMP}temp", clear
		keep in 1
		forvalues x = 1/4{
			local y = 1+`x'
			append using "${TEMP}temp`x'"
			keep in 1/`y'
		}
		gen id =_n
		label define election 1 "Aylwin-1989" 2 "Frei-1993" 3 "Lagos-1999" 4 "Bachelet-2005" 5 "Frei-2009" 
		label values id election
		twoway (scatter estimate id) (rcap min95 max95 id,lcolor(gray)) , ///
		ytitle(Impact of military presence on vote share) ylabel(, angle(horizontal)) yline(0, lcolor(gs10)) xtitle("") xscale(range(0.5 5.5)) xlabel(1(1)5,valuelabel angle(45)) ///
		legend(off) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) name(concert,replace)
		graph export "PaperVersion_F4.pdf", replace
	restore
	
	
********************************************************************************
********************************************************************************
** APPENDIX
********************************************************************************
********************************************************************************	

********************************************************************************
** APPENDIX B: Further information about the data
********************************************************************************

*****************************************************************
*****************************************************************	
** Figure B1: Characterization of sample attrition
*****************************************************************
*****************************************************************	

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
			
** Sample attrition
	codebook comuna if VoteShareNo != .
	g N1 = 340
	label var N1 "Sample: Full NO"
	
	codebook comuna if Pop70 !=. & Pop70 > 0 & VoteShareNo != .
	g N2 = 293 
	label var N2 "Sample: Full NO + Pop 70"
	
	codebook comuna if Pop70 !=. & Pop70 > 0 & VoteShareNo != . ///
					& share_alessandri70 != . & share_allende70 != .
	g N3 = 289
	label var N3 "Sample: Full NO + Pop 70 + Votes in '70"

	codebook comuna if Pop70 !=. & Pop70 > 0 & VoteShareNo != . ///
					& share_alessandri70 != . & share_allende70 != . & shVictims_70 <= 12
	g N4 = 276
	label var N4 "Sample: Full NO + Pop 70 + Votes in '70 + Drop outliers"

** Dataset for figure
	clear
	set obs 4
	g N = 340 if _n == 1
	replace N = 293 if _n == 2
	replace N = 289 if _n == 3
	replace N = 276 if _n == 4
	
	g t = _n
	
	two (spike N t, lw(10)), ///
		xlabel(.5 " " 1 "All" 2 "1970 pop." 3 "1970 votes" 4 "Outliers" 4.5 " ", noticks) ///
		ylabel(0(50)350) ytitle("Number of counties") xtitle(" ") ///
		plotr(style(none)) scale(1.2)
	
	graph export "PaperVersion_FB1.pdf", replace
	
********************************************************************************
********************************************************************************
** APPENDIX C: Further information about the data
********************************************************************************
********************************************************************************
	
*****************************************************************
*****************************************************************	
** Figure C1: Number of dictatorship victims by year
*****************************************************************
*****************************************************************	
	
// Open dataset
	use "${DATA}VictimsByYear.dta", clear
	
	two (connected Victims year), ///
		scale(1.2) xlabel(1973(3)1988) ///
		ytitle("Number of victims") xtitle("Year")
		
	graph export "PaperVersion_FC1.pdf", replace
	
*****************************************************************
*****************************************************************	
** Figure C2: Number of new military bases per year
*****************************************************************
*****************************************************************	

// Open dataset
	use "${DATA}MilitaryBasesByYear.dta", clear
		
	histogram year, freq xtitle("Year of foundation") ///
		scale(1.2) ytitle("") xlabel(1810(20)1970) ///
		legend(off) plotr(style(none))  width(11) 
		
	graph export "PaperVersion_FC2.pdf", replace
	
*****************************************************************
*****************************************************************	
** Figure C3: Military presence and additional electoral outcomes before 1973
*****************************************************************
*****************************************************************	
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
			
	** Controls: Excluding political
	global C1 	"lnDistStgo lnDistRegCapital  Pop70_pthousands sh_rural_70"	/* CONTROLS */
			
	**Panel A: Winner’s vote share
	`qui' reghdfe share_ibanez52 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp", replace) idstr("none") idnum(1952)
	`qui' reghdfe share_ibanez52 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp1", replace) idstr("muni") idnum(1952)
	`qui' reghdfe share_ibanez52 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp2", replace) idstr("full") idnum(1952)
	
	`qui' reghdfe share_alessandri58 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp3", replace) idstr("none") idnum(1958)
	`qui' reghdfe share_alessandri58 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp4", replace) idstr("muni") idnum(1958)
	`qui' reghdfe share_alessandri58 DMilitaryPresence $C1 share_allende52 share_ibanez52 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp5", replace) idstr("full") idnum(1958)
	
	`qui' reghdfe share_frei64 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp6", replace) idstr("none") idnum(1964)
	`qui' reghdfe share_frei64 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp7", replace) idstr("muni") idnum(1964)
	`qui' reghdfe share_frei64 DMilitaryPresence $C1 share_alessandri58 share_allende58 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp8", replace) idstr("full") idnum(1964)
	
	`qui' reghdfe share_alessandri70 DMilitaryPresence 		[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp9", replace)	 idstr("none") idnum(1970)
	`qui' reghdfe share_alessandri70 DMilitaryPresence $C1 	[aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp10", replace)	 idstr("muni") idnum(1970)
	`qui' reghdfe share_alessandri70 DMilitaryPresence $C1 share_allende64 share_frei64 [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp11", replace)	 idstr("full") idnum(1970)
	
	preserve
		use "${TEMP}temp", clear
		keep in 1
		forvalues x =1/11{
			local y = 1+`x'
			append using "${TEMP}temp`x'"
			keep in 1/`y'
		}
		gen time =1 if _n==2
		replace time=3 if _n==5
		replace time=5 if _n==8
		replace time=7 if _n==11
		replace time=time[_n+1]-0.4 if time==.&time[_n+1]!=.
		replace time=time[_n-1]+0.4 if time==.&time[_n-1]!=.
		
		
		twoway (scatter estimate time if idstr=="none") (scatter estimate time if idstr=="muni", msymbol(triangle)) (scatter estimate time if idstr=="full", msymbol(square)) (rcap min95 max95 time), ytitle(Effect of military presence on Winner's vote share) ylabel(, angle(horizontal)) xtitle(Election) xlabel(1 "1952" 3 "1958" 5 "1964" 7 "1970") legend(order(1 "Prov. FE" 2 "Prov. FE + econ. controls" 3 "Prov. FE + all controls") rows(1)) yline(0, lcolor(gs10)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FC3_PA.pdf", replace
	restore	
	
	**Panel B: Voter turnout

	`qui' reghdfe Turnout52 DMilitaryPresence $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp", replace) idstr("none") idnum(1952)
	`qui' reghdfe Turnout52 DMilitaryPresence $C1 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp1", replace) idstr("muni") idnum(1952)
	`qui' reghdfe Turnout52 DMilitaryPresence $C1 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp2", replace) idstr("full") idnum(1952)
	
	`qui' reghdfe Turnout58 DMilitaryPresence $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp3", replace) idstr("none") idnum(1958)
	`qui' reghdfe Turnout58 DMilitaryPresence $C1 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp4", replace) idstr("muni") idnum(1958)
	`qui' reghdfe Turnout58 DMilitaryPresence $C1 Turnout52 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp5", replace) idstr("full") idnum(1958)
	
	`qui' reghdfe Turnout64 DMilitaryPresence $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp6", replace) idstr("none") idnum(1964)
	`qui' reghdfe Turnout64 DMilitaryPresence $C1 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp7", replace) idstr("muni") idnum(1964)
	`qui' reghdfe Turnout64 DMilitaryPresence $C1 Turnout58 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp8", replace) idstr("full") idnum(1964)
	
	`qui' reghdfe Turnout70 DMilitaryPresence $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp9", replace)	 idstr("none") idnum(1970)
	`qui' reghdfe Turnout70 DMilitaryPresence $C1 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp10", replace)	 idstr("muni") idnum(1970)
	`qui' reghdfe Turnout70 DMilitaryPresence $C1 Turnout64 $R  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp11", replace)	 idstr("full") idnum(1970)
	
	preserve
		use "${TEMP}temp", clear
		keep in 1
		forvalues x =1/11{
			local y = 1+`x'
			append using "${TEMP}temp`x'"
			keep in 1/`y'
		}
		gen time =1 if _n==2
		replace time=3 if _n==5
		replace time=5 if _n==8
		replace time=7 if _n==11
		replace time=time[_n+1]-0.4 if time==.&time[_n+1]!=.
		replace time=time[_n-1]+0.4 if time==.&time[_n-1]!=.
		
		
		twoway (scatter estimate time if idstr=="none") (scatter estimate time if idstr=="muni", msymbol(triangle)) (scatter estimate time if idstr=="full", msymbol(square)) (rcap min95 max95 time), ytitle(Effect of military presence on voter turnout) ylabel(, angle(horizontal)) xtitle(Election) xlabel(1 "1952" 3 "1958" 5 "1964" 7 "1970") legend(order(1 "Prov. FE" 2 "Prov. FE + econ. controls" 3 "Prov. FE + all controls") rows(1)) yline(0, lcolor(gs10)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FC3_PB.pdf", replace
	restore	
	
	
*******************************************************************
*******************************************************************	
** Figure C4: Difference-in-difference estimations (Military presence)
*******************************************************************
*******************************************************************
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1

// Panel A: Allende vote share (1958-1970)
	preserve
		keep comuna DMilitaryPresence share_ibanez52 share_allende52 share_alessandri58 ///
			share_allende58 share_frei64 share_allende64 share_alessandri70 share_allende70 ///
			IDProv $C
			
		rename share_ibanez52 		vs_right1952
		rename share_allende52 		vs_left1952
		rename share_alessandri58 	vs_right1958
		rename share_allende58 		vs_left1958
		rename share_frei64 		vs_right1964
		rename share_allende64 		vs_left1964
		rename share_alessandri70 	vs_right1970
		rename share_allende70 		vs_left1970
		
		reshape long vs_right vs_left, i(comuna) j(year)

		egen id = group(comuna)
		
		g Dreg_1952 = DMilitaryPresence * (year == 1952)
		g Dreg_1958 = DMilitaryPresence * (year == 1958)
		g Dreg_1964 = DMilitaryPresence * (year == 1964)
		g Dreg_1970 = DMilitaryPresence * (year == 1970)

		`qui' reghdfe vs_left Dreg_1970 Dreg_1964 Dreg_1958, abs(id year) vce(cluster id)
		
		parmest, norestore
		split parm, p("_")
		rename parm2 year
		drop if parm == "_cons"
		set obs 4
		destring year,replace
		replace year = 1952 if year == .
		replace estimate = 0 if year == 1952
		replace min95 = 0 if year == 1952
		replace max95 = 0 if year == 1952
		
		twoway (scatter estimate year) (rcap min95 max95 year), ytitle(Allende vote share (DD estimate)) yline(0, lcolor(gs10)) ylabel(, angle(horizontal)) xtitle("") xlabel(1952(6)1970) legend(order(1 "Point estimate" 2 "95% confidence interval")) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FC4_PA.pdf", replace
	restore	
	
// Panel B: “Concertación” vote share (1989-2009)
	preserve
		rename share_aylwin89 		vs_LEFT_1989
		rename share_buchi89 		vs_RIGHT_1989
		rename vs_LEFT_93 			vs_LEFT_1993
		rename vs_LEFT_99 			vs_LEFT_1999 
		rename vs_LEFT_05 			vs_LEFT_2005 
		rename vs_LEFT_09 			vs_LEFT_2009 
		rename vs_RIGHT_93 			vs_RIGHT_1993
		rename vs_RIGHT_99 			vs_RIGHT_1999 
		rename vs_RIGHT_05 			vs_RIGHT_2005 
		rename vs_RIGHT_09 			vs_RIGHT_2009 
			
	** Pre-trends and democracy effects
		keep comuna DMilitaryPresence  vs_LEFT_1989 vs_LEFT_1993 vs_LEFT_1999 vs_LEFT_2005 vs_LEFT_2009  ///
			vs_RIGHT_1989 vs_RIGHT_1993 vs_RIGHT_1999 vs_RIGHT_2005 vs_RIGHT_2009 IDProv $C
			
		reshape long vs_LEFT_ vs_RIGHT_, i(comuna) j(year)
		
		rename vs_LEFT_ vs_left

		egen id = group(comuna)
		
		g Dreg_1989 = DMilitaryPresence * (year == 1989)
		g Dreg_1993 = DMilitaryPresence * (year == 1993)
		g Dreg_1999 = DMilitaryPresence * (year == 1999)
		g Dreg_2005 = DMilitaryPresence * (year == 2005)
		g Dreg_2009 = DMilitaryPresence * (year == 2009)
		
		`qui' reghdfe vs_left Dreg_2009 Dreg_2005 Dreg_1999 Dreg_1993 , abs(id year) vce(cluster id)
		
		parmest, norestore
		split parm, p("_")
		rename parm2 year
		drop if parm == "_cons"
		set obs 5
		destring year,replace
		replace year = 1989 if year == .
		replace estimate = 0 if year == 1989
		replace min95 = 0 if year == 1989
		replace max95 = 0 if year == 1989
		
		twoway (scatter estimate year) (rcap min95 max95 year), ytitle(Concertación vote share (DD estimate)) yline(0, lcolor(gs10)) ylabel(, angle(horizontal)) xtitle("") xlabel(1989 1993 1999 2005 2009) legend(order(1 "Point estimate" 2 "95% confidence interval")) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FC4_PB.pdf", replace
	restore	
	
*******************************************************************
*******************************************************************	
** Figure C5: Military presence and “Concertación” vote share in local elections
*******************************************************************
*******************************************************************

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
	`qui' reghdfe vs_local_Concert_1992 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp", replace)
	`qui' reghdfe vs_local_Concert_1996 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp1", replace)
	`qui' reghdfe vs_local_Concert_2000 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp2", replace)
	`qui' reghdfe vs_local_Concert_2004 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp3", replace)
	`qui' reghdfe vs_local_Concert_2008 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp4", replace)
	`qui' reghdfe vs_local_Concert_2012 DMilitaryPresence $C  [aw=${W}],absorb(IDProv) vce(robust)
	parmest,saving("${TEMP}temp5", replace)

	preserve
		use "${TEMP}temp", clear
		keep in 1
		forvalues x =1/5{
			local y = 1+`x'
			append using "${TEMP}temp`x'"
			keep in 1/`y'
		}
		gen id =_n
		label define election 1 "1992" 2 "1996" 3 "2000" 4 "2004" 5 "2008" 6 "2012" 7 "2016"
		label values id election
		gen type=1 if id!=5
		replace type=2 if id==5
		twoway (scatter estimate id if type==1,msymbol(circle)) (scatter estimate id if type==2,msymbol(triangle)) (rcap min95 max95 id,lcolor(gray)) , ///
		ytitle(Impact of military presence on vote share) ylabel(, angle(horizontal)) yline(0, lcolor(gs10)) xtitle("") xscale(range(0.5 6.5)) xlabel(1(1)6,valuelabel) ///
		legend(order(1 "Concertación Democrática" 2 "Concertación Democrática/Progresista")) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) name(concert,replace)
		graph export "PaperVersion_FC5.pdf", replace
	restore
		
	
********************************************************************************
********************************************************************************
** APPENDIX D: Robustness checks
********************************************************************************
********************************************************************************
	
*****************************************************************
*****************************************************************	
** Figure D1: Coefficient stability to randomly added controls	
*****************************************************************
*****************************************************************	

clear all

set rmsg on
set more off
set trace on
set tracedepth 2
set matsize 5000
set maxvar 5000

cap program drop takefromglobal
program define takefromglobal
 
  * To hold initial values of the global
  local temp ${`1'}
 
  * Empty the global
  global `1'
 
  * Loop through each of the old values
  foreach v of local temp {
   
 * Start counting at 0
    local i = 0

 * Create a local that indicates that this value should be skipped (initially assume no skipping)
    local skip = 0
 
 * Loop through all of the user specified inputs `0'
    foreach vv in `0' {
 
 * We will skip the first one since we know it is just the global specified
      local i = `i' + 1
  
   * If we are past the first input in the local and one our values to exclude matches the value in the global skip that value
   if `i' > 1 & "`vv'"=="`v'" local skip = 1
    }
 
 * If the current value is not to be skipped then add it to the new global list
 if `skip' == 0 global `1' ${`1'} `v'
  }
end

*****************************************************************************************
*Program to get a random draw of covariates* July 21, 2017. Built based on takefromglobal
*****************************************************************************************

cap program drop randomdraw
program define randomdraw
syntax, glo_var(string) n_rem(string)

************************************
*Randomize the list of variables in the global
************************************

local num_vars: list sizeof global(`glo_var')
matrix define G=J(`num_vars',1,.)	     // matrix w/ `num_vars' random numbers

matrix G[1,1]=floor((`num_vars')*runiform() + 1) // 1st random number

forval g=2(1)`num_vars'{
if (G[`g'-1,1]+1)/`num_vars'<1{
matrix G[`g',1]=G[`g'-1,1]+1
}
if (G[`g'-1,1]+1)/`num_vars'==1{
matrix G[`g',1]=`num_vars'
}
else{
matrix G[`g',1]=mod(G[`g'-1,1]+1,`num_vars')
}

}

matrix list G

tokenize "${`glo_var'}"

glo vars2 
local t=1
while `t'<=`num_vars'{
local A=G[`t',1]
glo vars2 ${vars2} ``A''
local t=`t'+1
}

glo glo_var2 "${vars2}"
di  "${glo_var2}"

************************************
*Randomly removes `C' vars from global
************************************

local num_glo: list sizeof global(glo_var2) // number of vars in global
matrix define L=J(`num_glo',1,.)	     // matrix w/ `num_glo' random numbers
forval j=1(1)`num_glo'{
matrix L[`j',1]=runiform()
}

local e=0

*1st loop to remove globals
local k=1
foreach cov of global glo_var2{

local crit=runiform()+`e'

if L[`k',1]>`crit'{
di "`cov' removed; `n' vars removed"
global extra_removed "${extra_removed} `cov'"
glo n=${n}+1
}
local k=`k'+1

if ${n}>=`n_rem'{
local e=100
}

}

di "${n} removed vars in loop 1"

takefromglobal extra_all ${extra_removed}

di "Updated list: ${extra_all}"

*1st loop to remove globals
if ${n}<`n_rem'{

local k=1
foreach cov of global extra_all{

local crit=runiform()+`e'

if L[`k',1]>0.5*`crit'{
di "`cov' removed; `n' vars removed"
global extra_removed "${extra_removed} `cov'"
glo n=${n}+1
}
local k=`k'+1

if ${n}>=`n_rem'{
local e=100
}
}

di "${n} removed vars in loop 2"

takefromglobal extra_all ${extra_removed}

}

*3rd loop to remove globals
if ${n}<`n_rem'{

local k=1
foreach cov of global extra_all{

local crit=runiform()+`e'

if L[`k',1]>0.1*`crit'{
di "`cov' removed; `n' vars removed"
global extra_removed "${extra_removed} `cov'"
glo n=${n}+1
}
local k=`k'+1

if ${n}>=`n_rem'{
local e=100
}
}

di "${n} removed vars in loop 2"

takefromglobal extra_all ${extra_removed}

}

*4th loop to remove globals
if ${n}<`n_rem'{

local k=1
foreach cov of global extra_all{

local crit=runiform()+`e'

if L[`k',1]>0{
di "`cov' removed; `n' vars removed"
global extra_removed "${extra_removed} `cov'"
glo n=${n}+1
}
local k=`k'+1

if ${n}>=`n_rem'{
local e=100
}
}

di "${n} removed vars in loop 2"

takefromglobal extra_all ${extra_removed}

}

end

*****************
** Run program **
*****************

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	set seed 11111

	global C "share_allende70 share_alessandri70 lnDistStgo lnDistRegCapital Pop70_pthousands sh_rural_70"		
    global ExtraC "share_up71_local mayor_up71 share_up73_congress landlocked Houses_pc SocialOrg_pop70 sh_educ_12more densidad_1970 sh_econactivepop_70 sh_women_70 ari_1973 index1b"
	
	** Main outcomes
	rename Share_reg70_w2 reg
	rename VoteShareNo no
	
	foreach numC of numlist 10 8 6 4 2 {
		** Clean datasets
		preserve
			clear 
			g rand = .
			g b_reg`numC' = .
			g b_no`numC' = .
		
			save "${TEMP}COEF_STAB_FIGURE_r`numC'.dta", replace
			sleep `sleep'
		restore

		forval i=1(1)150{

			glo n=0
			local C=`numC' // Choose number of variables that will be removed
			global extra_all $ExtraC
			global extra_removed ""
		
			randomdraw, ///
					glo_var("extra_all")  ///
					n_rem("`C'")	///
					
			di "${extra_all}"
			di "${extra_removed}"

			local controls`i' "${X0}"
			local controls`i' "`controls`i'' $extra_all"
			
			preserve
				`qui' reghdfe reg DMilitaryPresence $C `controls`i'' [aw=Pop70], absorb(IDProv) vce(robust)
				g b_reg`numC' = _b[DMilitaryPresence]
				
				`qui' reghdfe no DMilitaryPresence $C `controls`i'' [aw=Pop70], absorb(IDProv) vce(robust)
				g b_no`numC' = _b[DMilitaryPresence]
							
				g rand = `i'
				keep rand b_reg`numC' b_no`numC'
				duplicates drop 
				
				append using "${TEMP}COEF_STAB_FIGURE_r`numC'.dta"
				
				compress
				save "${TEMP}COEF_STAB_FIGURE_r`numC'.dta", replace
				sleep `sleep'
			restore
			
			*matrix B`numC'[`i',1]=_b[Dregimientos_Revised1]

		}	
	}
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1

	** Controls
	global C "share_allende70 share_alessandri70 lnDistStgo lnDistRegCapital Pop70_pthousands sh_rural_70"		
    global ExtraC "share_up71_local mayor_up71 share_up73_congress landlocked Houses_pc SocialOrg_pop70 sh_educ_12more densidad_1970 sh_econactivepop_70 sh_women_70 ari_1973 index1b"
	
	rename Share_reg70_w2 reg
	rename VoteShareNo no
	
	** Sample
	`qui' reghdfe reg DMilitaryPresence $C [aw=Pop70], absorb(IDProv) vce(robust)
	local b_reg0 = _b[DMilitaryPresence]

	`qui' reghdfe no DMilitaryPresence $C [aw=Pop70], absorb(IDProv) vce(robust)
	local b_no0 = _b[DMilitaryPresence]
	
	`qui' reghdfe reg DMilitaryPresence $C $ExtraC [aw=Pop70], absorb(IDProv) vce(robust)
	local b_reg12 = _b[DMilitaryPresence]

	`qui' reghdfe no DMilitaryPresence $C $ExtraC [aw=Pop70], absorb(IDProv) vce(robust)
	local b_no12 = _b[DMilitaryPresence]

	
	**** MERGE ALL DATASETS
	cd "${TEMP}"
	xmerge rand using COEF_STAB_FIGURE_r2.dta COEF_STAB_FIGURE_r4.dta COEF_STAB_FIGURE_r6.dta COEF_STAB_FIGURE_r8.dta COEF_STAB_FIGURE_r10.dta

	g b_reg0 = `b_reg0'
	g b_no0 = `b_no0'
	g b_reg12 = `b_reg12'
	g b_no12 = `b_no12'
	
	foreach c in 0 2 4 6 8 10 12 {
		foreach x in reg no {
		sum b_`x'`c', d
		gen mean_b_`x'`c' = r(mean)
		gen max_b_`x'`c' 	= r(max)
		gen min_b_`x'`c' 	= r(min)
		gen med_b_`x'`c' 	= r(p50)
		gen p5_b_`x'`c' 	= r(p95)
		gen p95_b_`x'`c' 	= r(p5)
		
		}
	}	
	
	keep mean_b_reg* max_b_reg* min_b_reg* med_b_reg* p5_b_reg* p95_b_reg* mean_b_no* max_b_no* min_b_no* med_b_no* p5_b_no* p95_b_no*
	duplicates drop 
	g c = 1
	reshape long mean_b_reg max_b_reg min_b_reg med_b_reg p5_b_reg p95_b_reg mean_b_no max_b_no min_b_no med_b_no p5_b_no p95_b_no, i(c) j(controls)
	label define lab 0 "base" 2 "2" 4 "4" 6 "6" 8 "8" 10 "10" 12 "all"
	label values controls lab
	 
	cd "${FIGURES}" 
	two (scatter mean_b_reg controls, connect(l) lp(solid) mc(black) ms(0)) (scatter med_b_reg controls, connect(l) lp(solid) ms(D)) ///
		(scatter p5_b_reg controls, connect(l) lp(solid) ms(T)) (scatter p95_b_reg controls, connect(l) lp(solid) ms(S)), ///
		xtitle("Number of randomly added covariates") xlabel(0(2)12) legend(label(1 "Mean") label(2 "Median") label(3 "5th pctile") label(4 "95th pctile"))
		
	graph export "PaperVersion_FD1_PA.pdf", replace
	
	two (scatter mean_b_no controls, connect(l) lp(solid) mc(black) ms(0)) (scatter med_b_no controls, connect(l) lp(solid) ms(D)) ///
		(scatter p5_b_no controls, connect(l) lp(solid) ms(T)) (scatter p95_b_no controls, connect(l) lp(solid) ms(S)), ///
		xtitle("Number of randomly added covariates") xlabel(0(2)12) legend(label(1 "Mean") label(2 "Median") label(3 "5th pctile") label(4 "95th pctile")) ///
		ylabel(1(1)5)
		
	graph export "PaperVersion_FD1_PB.pdf", replace	
	
	
*******************************************************************
*******************************************************************	
** Figure D2: Robustness of results to exclusion of random counties	
*******************************************************************
*******************************************************************

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
** Drop x observations
	local o 27 /* Number of observations to drop */	
	local X 50 /* Number of replications */
	
*********
** Loop: Estimation
*********	
	preserve
		// Empty datasets
		g beta1_sf = .
		g se1_sf = .
		g beta2_sf = .
		g se2_sf = .

		g beta1_no = .
		g se1_no = .
		g beta2_no = .
		g se2_no = .
		
		g F1 = .
		g F2 = .

		g Draw = .
		
		save "${TEMP}Rob_ExclRndCounties_v3.dta", replace
		sleep `sleep'
	restore
	forval i = 1/`X' {
		preserve
			g rnd = runiform()
			sort rnd
			g n = _n
			drop if n < `o'
			drop n
			
		* Regist.	
			`qui' reghdfe Share_reg70_w2 DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)

			g beta1_sh = _b[DMilitaryPresence]
			g se1_sh = _se[DMilitaryPresence]
			
		* NO
			`qui' reghdfe VoteShareNo DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)

			g beta1_no = _b[DMilitaryPresence]
			g se1_no = _se[DMilitaryPresence]
			
			keep beta1_sh se1_sh beta1_no se1_no
			g Draw = `i'
			
			order Draw beta1_sh se1_sh beta1_no se1_no 
			duplicates drop
			append using "${TEMP}Rob_ExclRndCounties_v3.dta"
			
			compress
			save "${TEMP}Rob_ExclRndCounties_v3.dta", replace
			sleep `sleep'
		restore
	}
	
** Figure	
	preserve
		use "${TEMP}Rob_ExclRndCounties_v3.dta" , clear
	
		foreach i in sh no {
			g min95_1_`i' = beta1_`i' - se1_`i'*1.96
			g max95_1_`i' = beta1_`i' + se1_`i'*1.96
		}	

		sort Draw	
		cap destring Draw, replace
		
		* Registration
		two (scatter beta1_sh   		Draw )  /// 
			(rspike min95_1_sh max95_1_sh Draw, lc(gs0)),  /// 
			yline(0, lc(gray)) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.6) ///
			legend(off) xtitle("") ytitle("Coefficient") 
			
		graph export "PaperVersion_FD2_PA.pdf"	, replace
					
		* NO	
		two (scatter beta1_no   		Draw )  /// 
			(rspike min95_1_no max95_1_no Draw, lc(gs0)),  /// 
			yline(0, lc(gray)) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.6) ///
			legend(off) xtitle("") ytitle("Coefficient") 
			
		graph export "PaperVersion_FD2_PB.pdf"	, replace	
	restore
		
		
*******************************************************************
*******************************************************************
** Figure D3: Random assignment of military bases	
*******************************************************************
*******************************************************************

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
** Randomizations	
	global B 1000			
	
**** V1: Randomize regimientos at country label
*** Randomization	
preserve
	clear	
	g b_no = .
	g se_no = .
	g b_reg = .
	g se_reg = .
	g Draw = .
	
	save "${TEMP}PlaceboRegimientos_RF_v1.dta", replace
restore	
	
forval b = 1/$B {
	g rnd = uniform()
	sort rnd
	g t = _n
	g DRegimientos_Placebo = (t <= 36)
	
	`qui' reg Share_reg70_w2 DRegimientos_Placebo $C i.IDProv [aw=$W], robust
	g b_reg = _b[DRegimientos_Placebo]
	g se_reg = _se[DRegimientos_Placebo]
	
	`qui' reg VoteShareNo DRegimientos_Placebo 	$C i.IDProv [aw=$W], robust
	g b_no = _b[DRegimientos_Placebo]
	g se_no = _se[DRegimientos_Placebo]
	
	g Draw = `b'
	preserve
		keep Draw b_no se_no b_reg se_reg
		duplicates drop
		
		append using "${TEMP}PlaceboRegimientos_RF_v1.dta"
		
		compress
		sleep 500
		save "${TEMP}PlaceboRegimientos_RF_v1.dta", replace
	restore

	drop t DRegimientos_Placebo Draw b* se* t rnd
}
	
** Figures	
preserve
	use "${TEMP}PlaceboRegimientos_RF_v1.dta", clear
		
	g pval1 = (b_no<2.24)
	sum pval1
	** .981 

	g pval2 = (b_reg<9.26)
	sum pval2
	** .963

// Folder
	cd "${FIGURES}"
	
	kdensity b_reg, ///
		xline(9.25, lc(gray)) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-12(2)12) ///
		legend(off) title("") ///
		xtitle("Coefficient") 
	
	graph export "PaperVersion_FD3_PA.pdf"	, replace
	
	kdensity b_no, ///
		xline(2.24, lc(gray)) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-4(2)4) ///
		legend(off) title("") ///
		xtitle("Coefficient") 
	
	graph export "PaperVersion_FD3_PB.pdf"	, replace
	
restore	
	
**** V2: Randomize regimientos at province level label
	
bys IDProv: egen aux = total(DMilitaryPresence)
	
*** Randomization	
preserve
	clear	
	g b_no = .
	g se_no = .
	g b_reg = .
	g se_reg = .
	g Draw = .
	
	save "${TEMP}PlaceboRegimientos_RF_v2.dta", replace
restore	
	
forval b = 1/$B {
	g rnd = uniform()
	sort IDProv rnd
	bys IDProv: g t = _n
	bys IDProv: g DRegimientos_Placebo = (t <= aux)
	
	`qui' reg Share_reg70_w2 DRegimientos_Placebo $C i.IDProv [aw=$W], robust
	g b_reg = _b[DRegimientos_Placebo]
	g se_reg = _se[DRegimientos_Placebo]
	
	`qui' reg VoteShareNo DRegimientos_Placebo 	$C i.IDProv [aw=$W], robust
	g b_no = _b[DRegimientos_Placebo]
	g se_no = _se[DRegimientos_Placebo]
	
	g Draw = `b'
	preserve
		keep Draw b_no se_no b_reg se_reg
		duplicates drop
		
		append using "${TEMP}PlaceboRegimientos_RF_v2.dta"
		
		compress
		sleep `sleep'
		save "${TEMP}PlaceboRegimientos_RF_v2.dta", replace
	restore

	drop t DRegimientos_Placebo Draw b* se* t rnd
}
	
**** Figures	
preserve
	use "${TEMP}PlaceboRegimientos_RF_v2.dta", clear
		
	g pval1 = (b_no<2.24)
	sum pval1
	*.975
	g pval2 = (b_reg<9.26)
	sum pval2
	*.975

// Folder
	cd "${FIGURES}"
	
	** 100%
	kdensity b_reg, ///
		xline(9.25, lc(gray)) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-12(2)12) ///
		legend(off) title("") ///
		xtitle("Coefficient") 
	
	graph export "PaperVersion_FD3_PC.pdf"	, replace
	
	kdensity b_no, ///
		xline(2.24, lc(gray)) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-4(2)4) ///
		legend(off) title("") ///
		xtitle("Coefficient") 
	
	graph export "PaperVersion_FD3_PD.pdf"	, replace
restore	

*******************************************************************
*******************************************************************	
** Figure D4: Potential bias from selection on unobservables
*******************************************************************
*******************************************************************
	
// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1
	
** Registration
	preserve
		`qui' areg Share_reg70_w2 DMilitaryPresence $C [aw=$W], absorb(IDProv) vce(robust)
		forvalues x=0.68(0.01)1.01{
		local y=round(`x'*100)
		psacalc beta DMilitaryPresence,rmax(`x')
		gen reg_`y'=round(r(beta),0.001)
		}
		
		keep reg_*
		keep in 1
		gen id=1
		reshape long reg_,i(id) j(rmax)
		drop id
		set obs 34
		replace rmax=67 if rmax==.
		replace reg_=9.254 if reg_==.
		replace rmax=rmax/100
		gen min95=0.63
		gen max95=17.9
		
		twoway (scatter reg_ rmax if rmax<0.68) (connected reg_ rmax if rmax>0.68) (rcap min95 max95 rmax if rmax<0.68), ytitle(Impact of military presence on voter registration) ylabel(, angle(horizontal)) xtitle(R-squared MAX) xlabel(0.65 0.67 0.70 0.75 0.80 0.85 0.90 0.95 1.00) xscale(range(0.65 1.0)) legend(order(1 "Actual point estimate" 3 "95% confidence interval" 2 "Adjusted treatment effect") rows(2)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FD4_PA.pdf", replace
	restore	

** NO
	preserve
		`qui' areg VoteShareNo DMilitaryPresence $C [aw=$W], absorb(IDProv) robust
		forvalues x=0.83(0.01)1.00{
		local y=round(`x'*100)
		psacalc beta DMilitaryPresence,rmax(`x')
		gen no_`y'=round(r(beta),0.001)
		}
		
		keep no_*
		keep in 1
		gen id=1
		reshape long no_,i(id) j(rmax)
		drop id
		set obs 19
		replace rmax=82 if rmax==.
		replace no_=2.242 if no_==.
		replace rmax=rmax/100
		gen min95=0.24
		gen max95=4.24
		
		twoway (scatter no_ rmax if rmax<=0.82) (connected no_ rmax if rmax>0.82) (rcap min95 max95 rmax if rmax<=0.82), ytitle(Impact of military presence on NO vote share) ylabel(, angle(horizontal)) xtitle(R-squared MAX) xlabel(0.80 0.82 0.85 0.90 0.95 1.00) xscale(range(0.8 1.0)) legend(order(1 "Actual point estimate" 3 "95% confidence interval" 2 "Adjusted treatment effect") rows(2)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		graph export "PaperVersion_FD4_PB.pdf", replace
	restore
		
		
*******************************************************************
*******************************************************************	
** Figure D5: Relaxing the exogeneity assumption	
*******************************************************************
*******************************************************************

// Open final dataset
	use "${DATA}FinalDatasetForReplication.dta", clear
	keep if MainSample == 1

	tab IDProv, g(dProv)	
	
	preserve
		clear all 
		g delta = .
		g lb_ci = .
		g ub_ci = .
	
		save "${TEMP}PlausiblyExog_Reg_v3.dta", replace 
		save "${TEMP}PlausiblyExog_No_v3.dta", replace
	restore

	*** Loop for figure
	forval i = 1/100 {
		local x = -9+`i'*2*9/100
		plausexog uci Share_reg70_w2 $C  dProv* (shVictims_70 = DMilitaryPresence) [aw=$W ]	, vce(robust) level(.9) gmin(`x') gmax(`x') 
		preserve
			g delta = `x'
			g lb_ci = e(lb_shVictims_70)
			g ub_ci = e(ub_shVictims_70)
			keep delta lb_ci ub_ci
			duplicates drop
			append using "${TEMP}PlausiblyExog_Reg_v3.dta"
			
			compress
			save "${TEMP}PlausiblyExog_Reg_v3.dta", replace
		restore

		local x = -2+`i'*2*2/100
		plausexog uci VoteShareNo $C  dProv* (shVictims_70 = DMilitaryPresence) [aw=$W ]	, vce(robust) level(.9) gmin(`x') gmax(`x') 
		preserve
			g delta = `x'
			g lb_ci = e(lb_shVictims_70)
			g ub_ci = e(ub_shVictims_70)
			keep delta lb_ci ub_ci
			duplicates drop
			append using "${TEMP}PlausiblyExog_No_v3.dta"
			
			compress
			save "${TEMP}PlausiblyExog_No_v3.dta", replace
		restore		
	}	
	
	** Create figure
	preserve
		use "${TEMP}PlausiblyExog_Reg_v3.dta", clear
		
		g t = _n
		g Cutoff = 1 if lb_ci < 0 & lb_ci[_n+1] > 0
		g delta_cut = delta if Cutoff == 1
		sum delta_cut
		
		two (line lb_ci delta, lc(gs0) lp(solid)) ///
			(line ub_ci delta, lc(gs0) lp(dash)), ///
			ytitle("Effect of repression") xtitle("Direct effect of the instrument") ///
			yline(0, lc(gray)) ///
			legend(label(1 "Lower bound") label(2 "Upper bound")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-9(2)9) 
			
		graph export "PaperVersion_FD5_PA.pdf"	, replace
		
		
		use "${TEMP}PlausiblyExog_No_v3.dta", clear
		
		g t = _n
		g Cutoff = 1 if lb_ci < 0 & lb_ci[_n+1] > 0
		g delta_cut = delta if Cutoff == 1
		** 
		sum delta_cut
		
		two (line lb_ci delta, lc(gs0) lp(solid)) ///
			(line ub_ci delta, lc(gs0) lp(dash)), ///
			ytitle("Effect of repression") xtitle("Direct effect of the instrument") ///
			yline(0, lc(gray)) ///
			legend(label(1 "Lower bound") label(2 "Upper bound")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) scale(1.2) xlabel(-2(0.5)2) 

		graph export "PaperVersion_FD5_PB.pdf"	, replace
	restore 	
		
	log close

This readme file explains the contents of the replication folder for:

The Geography of Repression and Opposition to Autocracy 

Published in the American Journal of Political Science. 

Authors:

1. Maria Angelica Bautista, University of Chicago 
2. Felipe Gonzalez, Universidad Catolica de Chile 
3. Luis R. Martinez (corresponding author), University of Chicago, luismartinez@uchicago.edu 
4. Pablo Munoz, Fundacao Getulio Vargas
5. Mounu Prem, Universidad del Rosario

Computational Environment:

Operating System: Windows 10 Enterprise
Statistical and GIS Software: Stata MP 16.1 (64-bit x86-64), QGIS version 3.10 or higher
Additional Stata packages: acreg, lassoShooting, x_ols, xmerge, ivreg2, ranktest, parmest, latabstat, binscatter, psacalc 

Main folders:

I. Data. This folder contains all the datasets needed to replicate the paper. All variables have detailed labels. 
1.	FinalDatasetForReplication.dta: final dataset at the county level with all necessary variables for the main analysis.
2.	LB_Analysis.dta: dataset based on Latinobarometro survey used for Table E1.
3.	MilitaryBasesByYear.dta: dataset with the list of military bases and their year of creation used in Appendix Figure C2
4.	VictimsByYear.dta: dataset with the number of victims of the Pinochet dictatorship per year used in Appendix Figure C1
5.	Codebook.pdf: file with information on each variable in each of the previous four datasets, including detailed data sources.
Sub folder: Temporary. This folder within the Data folder is used for temporary files within the analysis to create figures.
Sub folder: Map. This folder contains all the data and instructions needed to replicate Figure 1 of the paper.

II. Dofiles. This folder contains the .do files that replicate all tables and figures.
1.	ReplicatePaper-Tables: replicates all the analysis shown in tables.
2.	ReplicatePaper-Figures: replicates all the analysis shown in figures.
Note: These do-files contain detailed instructions for their execution. Files in other folders must preserve the folder structure and the path to the main folder must be specified in each do-file.

III. Ado. This folder includes 4 .ado files that are necessary to compute Conley SE (x_ols.ado and acreg.ado), to implement the machine learning procedure that selects controls (lassoShooting.ado), and to merge multiple dataset at the same time (xmerge.ado).
Note: Other ado files used in the analysis can easily be installed from Stata by typing "ssc install" followed by the name of the respective package. Our do-files include commands to do this automatically.

IV. Figures. This folder contains all the figures of the paper generated with the dofile ReplicatePaper-Figures.do

V. Tables. This folder contains all the tables of the paper generated with the dofile ReplicatePaper-Tables.do

VI. Logs. This folder contains the log files for all figures (log_Figures) and for all tables (log_Tables).

Content in each folder: 

Tables:
1. PaperVersion_T2_PA.txt: Table 2 panel A
2. PaperVersion_T2_PB.txt: Table 2 panel B 
3. PaperVersion_T3_PA.txt: Table 3 panel A 
4. PaperVersion_T3_PB.txt: Table 3 panel B 
5. PaperVersion_T4.txt: Table 4 
6. PaperVersion_TC1.txt: Appendix table C1 
7. PaperVersion_TC2.txt: Appendix table C2 
8. PaperVersion_TD1_PA.txt: Appendix table D1 panel A 
9. PaperVersion_TD1_PB.txt: Appendix table D1 panel B 
10.PaperVersion_TD2_PA.txt: Appendix table D2 panel A 
11.PaperVersion_TD2_PB.txt: Appendix table D2 panel B 
12.PaperVersion_TD2_PC.txt: Appendix table D2 panel C 
13.PaperVersion_TD3_PA.txt: Appendix table D3 panel A 
14.PaperVersion_TD3_PB.txt: Appendix table D3 panel B 
15.PaperVersion_TD3_PC.txt: Appendix table D3 panel C 
16.PaperVersion_TD4_PA.txt: Appendix table D4 panel A 
17.PaperVersion_TD4_PB.txt: Appendix table D4 panel B 
18.PaperVersion_TD4_PC.txt: Appendix table D4 panel C 
19.PaperVersion_TD5_PA.txt: Appendix table D5 panel A 
20.PaperVersion_TD5_PB.txt: Appendix table D5 panel B 
21.PaperVersion_TD5_PC.txt: Appendix table D5 panel C 
22.PaperVersion_TD6.txt: Appendix table D6 
23.PaperVersion_T1.tex: Table 1 
24.PaperVersion_T2_PA.tex: Table 2 panel A 
25.PaperVersion_T2_PB.tex: Table 2 panel B 
26.PaperVersion_T3_PA.tex: Table 3 panel A 
27.PaperVersion_T3_PB.tex: Table 3 panel B 
28.PaperVersion_T4.tex: Appendix table C4 
29.PaperVersion_TC1.tex: Appendix table C1 
30.PaperVersion_TC2.tex: Appendix table C2 
31.PaperVersion_TC4.tex: Appendix table C4 
32.PaperVersion_TD1_PA.tex: Appendix table D1 panel A 
33.PaperVersion_TD1_PB.tex: Appendix table D1 panel B
34.PaperVersion_TD2_PA.tex: Appendix table D2 panel A
35.PaperVersion_TD2_PB.tex: Appendix table D2 panel B
36.PaperVersion_TD2_PC.tex: Appendix table D2 panel C
37.PaperVersion_TD3_PA.tex: Appendix table D3 panel A
38.PaperVersion_TD3_PB.tex: Appendix table D3 panel B
39.PaperVersion_TD3_PC.tex: Appendix table D3 panel C
40.PaperVersion_TD4_PA.tex: Appendix table D4 panel A
41.PaperVersion_TD4_PB.tex: Appendix table D4 panel B
42.PaperVersion_TD4_PC.tex: Appendix table D4 panel C
43.PaperVersion_TD5_PA.tex: Appendix table D5 panel A
44.PaperVersion_TD5_PB.tex: Appendix table D5 panel B
45.PaperVersion_TD5_PC.tex: Appendix table D5 panel C
46.PaperVersion_TD6.tex: Appendix table D6 
47.PaperVersion_TE1.tex: Appendix table E1 

Figures:
1. PaperVersion_F2.pdf: Figure 2
2. PaperVersion_F3_PA.pdf: Figure 3 panel A
3. PaperVersion_F3_PB.pdf: Figure 3 panel B
4. PaperVersion_F3_PC.pdf: Figure 3 panel C
5. PaperVersion_F4.pdf: Figure 4
6. PaperVersion_FB1.pdf: Appendix figure B1
7. PaperVersion_FC1.pdf: Appendix figure C1
8. PaperVersion_FC2.pdf: Appendix figure C2
9. PaperVersion_FC3_PA.pdf: Appendix figure C3 panel A
10.PaperVersion_FC3_PB.pdf: Appendix figure C3 panel B
11.PaperVersion_FC4_PA.pdf: Appendix figure C4 panel A
12.PaperVersion_FC4_PB.pdf: Appendix figure C4 panel B
13.PaperVersion_FC5.pdf: Appendix figure C5
14.PaperVersion_FD1_PA.pdf: Appendix figure D1 panel A
15.PaperVersion_FD1_PB.pdf: Appendix figure D1 panel B
16.PaperVersion_FD2_PA.pdf: Appendix figure D2 panel A
17.PaperVersion_FD2_PB.pdf: Appendix figure D2 panel B
18.PaperVersion_FD3_PA.pdf: Appendix figure D3 panel A
19.PaperVersion_FD3_PB.pdf: Appendix figure D3 panel B
20.PaperVersion_FD3_PC.pdf: Appendix figure D3 panel C
21.PaperVersion_FD3_PD.pdf: Appendix figure D3 panel D
22.PaperVersion_FD4_PA.pdf: Appendix figure D4 panel A
23.PaperVersion_FD4_PB.pdf: Appendix figure D4 panel B
24.PaperVersion_FD5_PA.pdf: Appendix figure D5 panel A
25.PaperVersion_FD5_PB.pdf: Appendix figure D5 panel B

Logs:
log_Figures.log: log file for all figures of the paper
log_Tables.scml: log file for all tables of the paper 

Data:
FinalDatasetForReplication.dta: final dataset at the county level with all necessary variables for the analysis.
LB_Analysis.dta: dataset based on Latinobarometro used for Table E1.
MilitaryBasesByYear.dta: dataset with the military bases and its year of creation.
VictimsByYear.dta: dataset with the number of victims per year.
Codebook.pdf: codebook for all variables used in the analysis and their sources.

Subfolder Temporary within Data folder:
1. COEF_STAB_FIGURE_r2.dta: temporary dataset to create figure D1 in the paper
2. COEF_STAB_FIGURE_r4.dta: temporary dataset to create figure D1 in the paper
3. COEF_STAB_FIGURE_r6.dta: temporary dataset to create figure D1 in the paper
4. COEF_STAB_FIGURE_r8.dta: temporary dataset to create figure D1 in the paper
5. COEF_STAB_FIGURE_r10.dta: temporary dataset to create figure D1 in the paper 
6. PlaceboRegimientos_RF_v1.dta: temporary dataset to create figure D3 in the paper
7. PlaceboRegimientos_RF_v2.dta: temporary dataset to create figure D3 in the paper
8. PlausiblyExog_No_v3.dta: temporary dataset to create figure D5 in the paper
9. PlausiblyExog_Reg_v3.dta: temporary dataset to create figure D5 in the paper
10. Rob_ExclRndCounties_v3.dta: temporary dataset to create figure D2 in the paper
11. temp.dta: temporary dataset to create different figures in the paper
12. temp1.dta: temporary dataset to create different figures in the paper
13. temp2.dta: temporary dataset to create different figures in the paper
14. temp3.dta: temporary dataset to create different figures in the paper
15. temp4.dta: temporary dataset to create different figures in the paper
16. temp5.dta: temporary dataset to create different figures in the paper
17. temp6.dta: temporary dataset to create different figures in the paper
18. temp7.dta: temporary dataset to create different figures in the paper
19. temp8.dta: temporary dataset to create different figures in the paper
20. temp9.dta: temporary dataset to create different figures in the paper
21. temp10.dta: temporary dataset to create different figures in the paper
22. temp11.dta: temporary dataset to create different figures in the paper
23. temp12.dta: temporary dataset to create different figures in the paper
24. temp13.dta: temporary dataset to create different figures in the paper
25. temp14.dta: temporary dataset to create different figures in the paper
26. temp15.dta: temporary dataset to create different figures in the paper
27. temp16.dta: temporary dataset to create different figures in the paper
28. temp17.dta: temporary dataset to create different figures in the paper

Subfolder Map within Data folder:
1. cl_comunas_cautin.zip: shapefile of counties in Cautin province 
2. cl_comunas_coquimbo.zip: shapefile of counties in Coquimbo province 
3. cl_comunas_geo.zip: shapefile of counties in Chile 
4. cl_comunas_geo.odt: additional file with information for shapefile of counties in Chile
5. division_provincial.zip: shapefile of provinces in Chile.
6. data.csv: county-level data with the share of victims.
7. military_bases.csv: locations (latitude and longitude) of counties with a military base in 1970.
8. README.txt: step-by-step explanation to reproduce Figure 1 of the paper. 

Dofiles: 
ReplicatePaper-Figures.do: replicates all the analysis shown in tables.
ReplicatePaper-Tables.do: replicates all the analysis shown in figures.

Ado:
acreg.ado: necessary to compute Conley SE
lassoShooting.ado: implement the machine learning procedure that selects controls
x_ols.ado: necessary to compute Conley SE
xmerge.ado: merge multiple dataset at the same time





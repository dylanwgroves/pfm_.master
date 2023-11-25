/* Basics ______________________________________________________________________

Project: Pfm4_audio_screening
Purpose:Randomization 
Author: Martin Zuakulu, mzuakulu@poverty-action.org
Date: 2022/04/1
________________________________________________________________________________*/

cap import excel "X:\Box\30_Community Media II (Wellspring)\07&08 Questionnaires & Data\03 Baseline\05_data\01_preloads\AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear
cap import excel "X:\Box Sync\30_Community Media II (Wellspring)\07&08 Questionnaires & Data\03 Baseline\05_data\01_preloads\AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear

egen id_village_uid = concat(District_C Ward_Code Vil_Mtaa_C), punct("_")
			lab var id_village_uid "Village Unique ID"
	
	set seed 1956
				
	* Generate Random Numbers ------------------------------------------------------
	gen rand1 = runiform()														// Create random number (usually create two): gen rand1 = runiform()
	gen rand2 = runiform()
							
	* Assign Treatment using within-pair randomization -----------------------------
	sort rand1 rand2 
	gen rank = _n
	egen rank_max = max(rank), by(Ward_Name)
	gen treat = 1 if rank == rank_max 
		replace treat = 0 if rank < rank_max 

	sort id_village_uid
	order id_village_uid treat rank rand1 
		
export excel "X:\Box Sync\30_Community Media II (Wellspring)\07&08 Questionnaires & Data\03 Baseline\05_data\01_preloads\AS_2_randomized_final.xlsx", firstrow(variables) replace
	
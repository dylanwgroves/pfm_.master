/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening 2 - Boda Bora
Purpose: Randomization Inference 
Author: Dylan Groves, dylanwgroves@gmail.com
Date: 2022/05/14
________________________________________________________________________________*/

cap import excel "X:\Box\30_Community Media II (Wellspring)\07&08 Questionnaires & Data\03 Baseline\05_data\01_preloads\AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear
cap import excel "X:\Box Sync\30_Community Media II (Wellspring)\07&08 Questionnaires & Data\03 Baseline\05_data\01_preloads\AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear


/* Create Unique IDs */
egen id_village_uid = concat(District_C Ward_Code Vil_Mtaa_C), punct("_")
			lab var id_village_uid "Village Unique ID"

egen id_ward_uid = concat(District_C Ward_Code), punct("_")
			lab var id_ward_uid "Ward Unique ID"

drop if id_ward_uid == "3_."

tab id_ward_uid 

forval i = 1/5000 {

	set seed `i'
				
	* Generate Random Numbers ------------------------------------------------------
	sort id_village_uid 
	gen rand = runiform()													
							
	* Assign Treatment using within-pair randomization -----------------------------
	sort rand
	gen rank = _n
	egen rank_max = max(rank), by(id_ward_uid)
	gen treat_`i' = 1 if rank == rank_max 
		replace treat_`i' = 0 if rank < rank_max 
	
	drop rand rank rank_max 
}

	drop wkt_geom Region_Cod Region_Nam District_C District_N Ward_Code Ward_Name Vil_Mtaa_C Vil_Mtaa_N Shape_Leng Shape_Area Distance X250_Cov bbc select
	
	
save "X:\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Audio Screening 2 (gbv)\01_data\pfm_bb_ri.dta", replace
	
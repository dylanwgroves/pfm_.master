

/* Basics ______________________________________________________________________

Project: Pangani FM AS2
Purpose:Randomization 
Author: Dylan W Groves, dylanwgroves@gmail.com
Date: 2022/04/1
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956
	
/* Load Data ___________________________________________________________________*/

	import excel "${data}/01_raw_data/AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear


	/* Create Unique IDs */
	egen id_village_uid = concat(District_C Ward_Code Vil_Mtaa_C), punct("_")
				lab var id_village_uid "Village Unique ID"

	egen id_ward_uid = concat(District_C Ward_Code), punct("_")
				lab var id_ward_uid "Ward Unique ID"

	drop if id_ward_uid == "3_."

	tab id_ward_uid 

	forval i = 1/10000 {

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
		
/* Save ________________________________________________________________________*/

save "${data}/02_mid_data/pfm_ri_as2.dta", replace
	
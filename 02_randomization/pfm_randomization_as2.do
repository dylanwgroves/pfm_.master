
/* Basics ______________________________________________________________________

Project: Pangani FM AS2
Purpose:Randomization 
Author: Dylan W Groves, dylanwgroves@gmail.com
Date: 2022/04/1
________________________________________________________________________________*/

import excel "${data}/01_raw_data/AS_2_Sample Villages_Final.xlsx", sheet("Sheet1") firstrow clear

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
	
	keep id_village_uid treat
	drop if id_village_uid == "3_._."

	* Save ---------------------------------------------------------------------
		
	save "${data}/02_mid_data/pfm_randomized_as2.dta", replace
	
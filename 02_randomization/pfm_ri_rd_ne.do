
/* _____________________________________________________________________________

Project: Pangani FM 2
File: Audio Screening Randomization
Date: 8/22/2019
Author: Dylan Groves, dgroves@poverty-action.org
verview: This imports radio distribution randomization file

________________________________________________________________________________*/


/* Notes _______________________________________________________________________*/

* We are randomly selecting one village within each ward


/* Introduction ________________________________________________________________*/

clear all
set more off

/* Import ______________________________________________________________________*/

	import delimited "X:/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/5_Radio Distribution/pfm_ri_base.csv", clear 
	
/* Re-Randomize ______________________________________________________________________*/

	/* Stable Sort */
	sort village_c uid
	
forvalues x = 1/10000 {

	/* Set seed */
	set seed `x'
	
	/* Generate Random Number */
	gen random_1 = runiform()				// Called random_2 because random_1 was used for randomly selecting villages out of wards
	gen random_2 = runiform()	
	
	/* Generate Median */
	bys village_c : egen r_median_1 = median(random_1)
	bys village_c : egen r_median_2 = median(random_2)

	
	/* Assign Treatment If Above Meidan */
	gen rd_treat_`x' = 0 if 	(random_1 > r_median_1) | ///
								(random_1 == r_median_1 & random_2 > r_median_2)
						
	replace rd_treat_`x' = 1 if (random_1 <= r_median_1) | ///
								(random_1 == r_median_1 & random_2 <= r_median_2)
								
	
	/* Drop Using Variblaes */
	drop random_1 random_2 r_median_1 r_median_2
							
}
		
	/* Create Block Variable */
	tostring village_c, gen(rd_block)
	
	/* Drop */
	drop uid

	


/* Save ________________________________________________________________________*/

save "${data}/02_mid_data/pfm_ri_rd_ne.dta", replace

*export delimited using "X:/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/5_Radio Distribution/pfm_ri_sb.csv", replace









	

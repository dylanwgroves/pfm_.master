
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
set seed 1956


/* Import ______________________________________________________________________*/

	import delimited "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis\2 - Final Data\5_Radio Distribution\pfm_ri_base.csv", clear 

	* Stable Sort
	sort village_c uid

	* (1) Generate Random Number
	gen random_1 = runiform()				// Called random_2 because random_1 was used for randomly selecting villages out of wards
	gen random_2 = runiform()	

	* (2) Generate Median
	bys village_c : egen r_median_1 = median(random_1)
	bys village_c : egen r_median_2 = median(random_2)
	
	* (3) Assign Treatment If Above Meidan
	gen rd_treat = 0 if 	(random_1 > r_median_1) | ///
							(random_1 == r_median_1 & random_2 > r_median_2)
						
	replace rd_treat = 1 if (random_1 <= r_median_1) | ///
							(random_1 == r_median_1 & random_2 <= r_median_2)
							
		* (3a) Mistaken randomization in first two villages - if odd, assigned
		* -1 respondents to treatment
		replace rd_treat = 0 if random_1 >= r_median_1 & village_c == 14932
		replace rd_treat = 0 if random_1 >= r_median_1 & village_c == 15395

	* (4) Drop Using Variblaes
	drop random_2 r_median_2 uid

/* Save ________________________________________________________________________*/

stop
save "${data}/02_mid_data/pfm_randomized_rd_ne.dta", replace

*export delimited using "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis\2 - Final Data\5_Radio Distribution\pfm_ri_sb.csv", replace









	

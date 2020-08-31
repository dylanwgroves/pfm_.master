
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

	use "${data}\01_raw_data\pfm_as_villagesample.dta", clear

	* Stable Sort
	sort vill_id

	* (1) Generate Random Number
	gen random_2 = runiform()			// Called random_2 because random_1 was used for randomly selecting villages out of wards
	* duplicates report random_2 		// Checks that no duplicates are generated by random num generator

	* (2) Identify Largest Random Number in Each Ward
	bys district_c ward_c: egen r2_median = median(random_2)
	gen treat = 0 if random_2 > r2_median
	replace treat = 1 if random_2 < r2_median

	drop random_2 r2_median vill_id


/* Save ________________________________________________________________________*/

save "${data}/02_mid_data/pfm_randomized_as.dta", replace









	

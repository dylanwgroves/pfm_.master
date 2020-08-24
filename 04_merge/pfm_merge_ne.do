/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Natural Experiment Datasets
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

	clear all

/* Temfiles __________________________________________________________________*/

	tempfile temp_allvills
	tempfile temp_base
	tempfile temp_base_rand
	tempfile temp_rd_dist
	tempfile temp_rd_rand
	tempfile temp_rand


/* Import Data ________________________________________________________________*/

/* NOTES: 
	- 	we might want to consider adding a prefix to each survey so we know where its
		coming from
*/	
		
	/* All villages */
	use "${data}\01_raw_data\pfm_allvills_clean.dta"
	sort village_id
	save `temp_allvills'
	
	/* Baseline */
	use "${data}/02_mid_data/pfm_ne_baseline_clean.dta", clear
	gen objectid = village_c
	drop respid
	sort resp_id
	save `temp_base', replace

	/* Radio Randomization */
	use "${data}/01_raw_data/03_surveys/pfm_pii_rd_randomization_ne.dta", clear
	rename object_id objectid
	sort objectid																// Has both version of respid and resp_id
	save `temp_rd_rand', replace

	/* Radio Distribution */
	use "${data}/02_mid_data/pfm_clean_rd_distribution_ne.dta", clear	
	drop resp_name
	sort respid																	// Only has the no "_" version of respid
	save `temp_rd_dist', replace

	/* Village Randomization */
	use "${data}/01_raw_data/pfm_ne_randomization.dta", clear
	drop village_id
	save `temp_rand', replace 
	
	/* Merge, with Radio randomization first */
	use `temp_allvills'
	merge 1:n objectid using `temp_base', gen(merge_base)						// Baseline
		drop if merge_base==1
	merge n:1 objectid using `temp_rand', gen(merge_base_rand)					// Village randomization
	save `temp_base_rand', replace
	
	use `temp_rd_rand', clear													// Radio randomization
	merge 1:1 respid using `temp_rd_dist', gen(merge_rd)						// Radio distribution
		drop if merge_rd == 2

	merge 1:1 resp_id using `temp_base_rand', gen(merge_base_rand_rd)


/* Save ______________________________________________________________________*/

	rename * ne_*	
	rename ne_id_* id_*
	save "${data}/03_final_data/pfm_ne_merged.dta", replace
	
	



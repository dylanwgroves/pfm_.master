/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Audio Screening Datasets
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

	clear all

/* Temfiles __________________________________________________________________*/

	tempfile temp_as_mid
	tempfile temp_as_rd_dist
	tempfile temp_as_rd_rand
	tempfile temp_as_rand


/* Import Data ________________________________________________________________*/

/* NOTES: 
	- 	we might want to consider adding a prefix to each survey so we know where its
		coming from
*/

	/* Audio Screening */
		
		/* Midline */
		use "${data}\01_raw_data\pfm_as_midline_clean.dta", clear
		sort resp_id 
		save `temp_as_mid', replace
		
		/* Radio Distribution */
		use "${data}\02_mid_data\pfm_clean_rd_distribution_as.dta", clear
		sort resp_id 
		save `temp_as_rd_dist'
		
		/* Radio Randomization */
		use "${data}/01_raw_data/pfm_pii_rd_random_as.dta", clear
		save `temp_as_rd_rand'
		
		/* Village Randomization */
		use "${data}\01_raw_data\pfm_as_randomization.dta", clear
		save `temp_as_rand'
		
		
			/* Merge, with baseline first */
			use "${data}\02_mid_data\pfm_as_baseline_clean.dta", clear
			
			merge 1:1 resp_id using `temp_as_mid', gen(merge_as_base_mid)
			merge 1:1 resp_id using `temp_as_rd_dist', gen(merge_as_bas_mid_rd)
			merge 1:1 resp_id using `temp_as_rd_rand', gen(merge_as_bas_mid_rd_rdrand)
			merge n:1 village_id using `temp_as_rand', force gen(merge_as_bas_mid_rd_rdrand_rand)
	
/* Save ______________________________________________________________________*/

	save "${data}/03_final_data/pfm_as_merged.dta", replace
	
	

	/* Natural Experiment */
		
		/* Radio Distribution */
		use "${data}\02_mid_data\pfm_clean_rd_distribution_ne.dta", clear
		sort resp_id 
		save `temp_as_rd_dist'
		
		stop
		
		/* Radio Randomization */
		use "${data}/01_raw_data/pfm_pii_rd_random_as.dta", clear
		save `temp_as_rd_rand'
		
		/* Village Randomization */
		use "${data}\01_raw_data\pfm_as_randomization.dta", clear
		save `temp_as_rand'
		
		
			/* Merge, with Baseline first */
			use "${data}\02_mid_data\pfm_as_baseline_clean.dta", clear
			
			merge 1:1 resp_id using `temp_as_rd_dist', gen(merge_as_bas_rd)
			merge 1:1 resp_id using `temp_as_rd_rand', gen(merge_as_bas_rd_rdrand)
			merge n:1 village_id using `temp_as_rand', force gen(merge_as_bas_rd_rdrand_rand)
			
			

/* Merge ______________________________________________________________________*/

append using `temp_audioscreening'
order resp_id resp_name district_name ward_name village_name




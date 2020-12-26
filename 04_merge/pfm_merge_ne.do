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
	tempfile temp_end
	tempfile temp_base_rand
	tempfile temp_rd_dist
	tempfile temp_rd_rand
	tempfile temp_rand
	tempfile temp_rd_ri


/* Import Data _________________________________________________________________

	NOTES: 
		- 	we might want to consider adding a prefix to each survey so we know where its
			coming from
*/

	/* Natural Experiment */
	
		/* All villages */
		use "${data}\01_raw_data\pfm_allvills_clean.dta"
		sort village_id
		save `temp_allvills'
		
		/* Baseline */
		use "${data}/02_mid_data/pfm_ne_baseline_clean.dta", clear
		rename * b_*
			rename b_village_c village_c
			rename b_resp_id resp_id
			rename b_id id
			rename b_resp_name resp_name
		gen objectid = village_c
		drop b_respid
		sort resp_id
		save `temp_base', replace
		
		/* Endline */
		use "${data}/02_mid_data/pfm_ne_endline_clean.dta", clear
		save `temp_end', replace
		
		/* Village Sample */
		use "${data}\01_raw_data\pfm_sample_ne.dta", clear
		drop village_id
		save `temp_rand', replace 

	/* Radio Distribution */
	
		/* Radio Randomization */
		use "${data}/02_mid_data/pfm_randomized_rd_ne.dta", clear
		rename village_c objectid
		destring respid, replace
		sort objectid																// Has both version of respid and resp_id
		save `temp_rd_rand', replace

		/* Radio RI */
		use "${data}/02_mid_data/pfm_ri_rd_ne.dta", clear
		sort resp_id 
		save `temp_rd_ri', replace

		/* Radio Distribution */
		use "${data}/02_mid_data/pfm_clean_rd_distribution_ne.dta", clear	
		drop rd_resp_name
		destring rd_respid, gen(respid)
		sort respid																	// Only has the no "_" version of respid
		save `temp_rd_dist', replace
	

/* Merge _______________________________________________________________________

	Note
		- The endline data is merged off of a unique respondent id is created
		after merging the other files first. So the steps are a little bit awkward:
			1 - Merge all baseline data
			2 - Generate Unique IDs
			3 - Merge endline data based on unique ids
			
*/

	/* Merge Baseline */
	
		** Baseline, Treatment Assignment
		use `temp_allvills'
		merge 1:n objectid using `temp_base', gen(merge_base)						// Baseline
			drop if merge_base==1
		merge n:1 objectid using `temp_rand', gen(merge_base_rand)					// Village randomization
		save `temp_base_rand', replace

		** Radio Randomization and Distribution
		use `temp_rd_rand', clear													// Radio randomization
		merge 1:1 respid using `temp_rd_dist', gen(merge_rd)						// Radio distribution
			drop if merge_rd == 2
		
		** NE and RD
		merge 1:1 resp_id using `temp_base_rand', gen(merge_base_rand_rd)
		
		** RI
		merge 1:1 resp_id using `temp_rd_ri', gen(merge_rd_ri)
	
	/* Create Unique IDs */
		gen id_resp_c = id
			lab var id_resp_c "Respondent Code"
				
		gen id_resp_n = resp_name
			lab var id_resp_n "Respondent Name"
			
		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"

	/* Merge Endline */
		merge 1:1 id_resp_uid using `temp_end', gen(merge_end)
		rename treat b_treat
		bys id_village_n : egen treat_ne = max(b_treat)							// Assign treatment to replacements, who dont have baseline data w/ treatment assignment
		bys id_village_n : egen block_ne = max(pair_c)	

/* Label ______________________________________________________________________*/

	rename * ne_*	
	rename ne_id_* id_*
	rename ne_sample sample
		replace sample = "ne"

/* Save ______________________________________________________________________*/

	save "${data}/03_final_data/pfm_ne_merged.dta", replace
	
	


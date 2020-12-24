/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Audio Screening Datasets
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all

/* Tempfiles ___________________________________________________________________*/
	
	tempfile temp_allvills
	tempfile temp_base
	tempfile temp_mid
	tempfile temp_end
	tempfile temp_end_partner
	tempfile temp_rd_dist
	tempfile temp_rd_rand
	tempfile temp_rand
	
	tempfile temp_rd_ri
	tempfile temp_ri

/* Import Data ________________________________________________________________*/

/* NOTES: 

	- 	we might want to consider adding a prefix to each survey so we know where its
		coming from		
		
	-	to avoid confusion, put "b_" in front of all baseline variables and
		"m_" in front of all midline variables

*/


	/* Audio Screening */
	
		/* All villages */
		use "${data}/01_raw_data/pfm_allvills_clean.dta"
		sort village_id
		save `temp_allvills'
		
		/* Baseline */
		use "${data}/02_mid_data/pfm_as_baseline_clean.dta", clear
		rename * b_*
		rename b_village_id village_id
		rename b_resp_id resp_id
		sort village_id resp_id
		save `temp_base'
		
		/* Midline */
		use "${data}\01_raw_data\pfm_as_midline_clean.dta", clear
		rename * m_*
		rename m_resp_id resp_id
		sort resp_id 
		save `temp_mid', replace
		
		/* Endline */
		use  "${data}\01_raw_data\pfm_as_endline_clean.dta", clear
		save `temp_end'
		
		/* Partner */
		use "${data}\01_raw_data\pfm_as_endline_clean_partner.dta", clear
		rename * p_*			
		gen id_resp_uid = subinstr(p_id_resp_uid,"_p","",.)						// Create matching unique respondent id
			replace id_resp_uid =subinstr(id_resp_uid,"_P","",.)
			duplicates drop id_resp_uid, force
		save `temp_end_partner'

		
		/* Village Randomization */
		use "${data}/02_mid_data/pfm_randomized_as.dta", clear
		save `temp_rand'
		
		/* Village RI */
		use "${data}/02_mid_data/pfm_ri_as.dta", clear
		save `temp_ri'
		
	/* Radio */
	
		/* Radio Distribution */
		use "${data}/02_mid_data/pfm_clean_rd_distribution_as.dta", clear
		gen resp_id = rd_resp_id
		sort resp_id 
		save `temp_rd_dist'
		
		/* Radio Randomization */
		use "${data}/02_mid_data/pfm_rd_randomization_as.dta", clear
		save `temp_rd_rand'
		
		/* Radio RI */
		use "${data}/02_mid_data/pfm_rd_ri_as.dta", clear
		save `temp_rd_ri'
		
/* Merge _______________________________________________________________________

	Note
		- The endline data is merged off of a unique respondent id is created
		after merging the other files first. So the steps are a little bit awkward:
			1 - Merge all baseline data
			2 - Generate Unique IDs
			3 - Merge endline data (main and partner) based on unique ids
			
*/
	/* Merge Baseline */
	
		use `temp_allvills'
		merge 1:n village_id using `temp_base', force gen(merge_base)
			drop if merge_base == 1
		merge 1:1 resp_id using `temp_mid', force gen(merge_base_mid)
		merge 1:1 resp_id using `temp_rd_dist', force gen(merge_bas_mid_rd)
		merge 1:1 resp_id using `temp_rd_rand', force gen(merge_bas_mid_rd_rdrand)
		merge 1:1 resp_id using `temp_rd_ri', force gen(merge_rdri)
		merge n:1 village_id using `temp_rand', force gen(merge_bas_mid_rd_rdrand_rand)
	
		/* RI */
		merge 1:1 resp_id using `temp_rd_ri', force gen(merge_ri_rd)
		merge n:1 village_id using `temp_ri', force gen(merge_ri_as)
		
	/* Unique IDs */
		gen id_resp_c = b_resp_c
			lab var id_resp_c "Respondent Code"
		
		gen id_resp_n = b_resp_name
			lab var id_resp_n "Respondent Name"

		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
			
	/* Merge Endlines */
		merge 1:1 id_resp_uid using `temp_end', gen(merge_end)
		merge 1:1 id_resp_uid using `temp_end_partner', gen(merge_end_part)
		
/* Label ______________________________________________________________________*/

	rename * as_*	
	rename as_id_* id_*
	rename as_sample sample
		replace sample = "as"

/* Save ________________________________________________________________________*/

	save "${data}/03_final_data/pfm_as_merged.dta", replace
	
	
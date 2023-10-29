/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Audio Screening 2 Datasets
	Date: 2023.10.28
	Author: dylan w groves, dylanwgroves@gmail.com
	Overview: This merges and appends are relevant datasets
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all
	set maxvar 30000
	
/* Tempfiles ___________________________________________________________________*/
	
	tempfile temp_allvills
	tempfile temp_base
	tempfile temp_mid
	
	tempfile temp_end
	tempfile temp_end_partner
	tempfile temp_end_friend
	tempfile temp_end_kid
	tempfile temp_leader
	
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
		use "${data}/02_mid_data/pfm_as2_baseline_clean.dta", clear
		rename consented1section_* c1sec_*
		rename * b_*
		gen village_id = b_id_village_uid
		replace village_id = subinstr(village_id, "_", "-", .)
		rename b_resp_id resp_id
		sort village_id resp_id
		save `temp_base'
		
		/* Midline */
		use "${data}/02_mid_data/pfm_as2_midline_clean.dta", clear
		rename consented1* c1*
		rename * m_*
		rename m_resp_id resp_id
		sort resp_id 
		save `temp_mid', replace
		
		/* Endline */
		use  "${data}/02_mid_data/pfm_as2_endline_clean.dta", clear
		rename consented* c1*		
		rename * e_*
		rename e_resp_id resp_id
		sort resp_id 
		save `temp_end'
	
		/* Partner */
		use "${data}/02_mid_data/pfm_as2_endline_clean_partner.dta", clear
		rename consented* c*
		rename * p_*	
		rename p_resp_id resp_id
		save `temp_end_partner'
		
		/* Kids */
		use "${data}/02_mid_data/pfm_as2_endline_clean_kids.dta", clear
		gen k_resp_kidnum = substr(k_resp_id,-1,.) 
		rename resp_id_parent resp_id 
		rename * k_*		
		rename k_resp_id id_resp_uid
		save `temp_end_kid'
	


	/* Randomization
	
		/* Village Randomization */
		use "${data}/02_mid_data/pfm_randomized_as.dta", clear
		save `temp_rand'
			
		/* Village RI */
		use "${data}/02_mid_data/pfm_ri_as.dta", clear
		save `temp_ri'
	 */		
	/* Radio 
	
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
	*/	
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
		merge 1:1 resp_id using `temp_end', force gen(merge_base_mid_end)
		merge 1:1 resp_id using `temp_end_partner', force gen(merge_base_mid_end_p)

		*merge 1:1 resp_id using `temp_rd_dist', force gen(merge_bas_mid_rd)
		*merge 1:1 resp_id using `temp_rd_rand', force gen(merge_bas_mid_rd_rdrand)
		*merge 1:1 resp_id using `temp_rd_ri', force gen(merge_rdri)
		*merge n:1 village_id using `temp_rand', force gen(merge_bas_mid_rd_rdrand_rand)
	
		/* RI */
		*merge 1:1 resp_id using `temp_rd_ri', force gen(merge_ri_rd)
		*merge n:1 village_id using `temp_ri', force gen(merge_ri_as)
		
	/* Unique IDs */
		/*
		gen id_resp_c = b_resp_c
			lab var id_resp_c "Respondent Code"
		
		gen id_resp_n = b_resp_name
			lab var id_resp_n "Respondent Name"
		*/
		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		gen id_resp_uid = resp_id			
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
	

/* Label ______________________________________________________________________*/

	rename *_religious_* *_rel_*
	rename *_second_* *_2nd_*
	rename *_rand_* *_r_*
	rename *_enviro_* *_env_*
	drop *_label_*
	drop *_randomizer_*
	drop *_ptixpart_* *_ppart_*
	rename *_section_* *_sect_*
	rename *_receive_* *_rec_*
	rename *_marital_status_* *_marstat_*
	rename e_end_* e_*
	drop e_excluderadioownershipmodule*
	drop p_excluderadioownershipmodule*
	rename *_productivity_* *_product_*
	rename *_visitcity_* *_gocity_*
	rename *_safe_streets_* *_sfstreet_*
	drop e_resp_gocity_activities__222 
	drop p_resp_gocity_activities__222
	rename *_radio_stations_* *_radstat_*
	rename *_compliance_* *_comply_*
	rename *_wifesampling_* *_wifesamp_*
	rename p_end_* p_*
	rename * as2_*	
	rename as2_id_* id_*
	*rename as2_sample sample
		gen sample = "as2"

/* Save ________________________________________________________________________*/


	save "${data}/03_final_data/pfm_as2_merged.dta", replace
	
	
	use "${data}/03_final_data/pfm_as2_merged.dta", replace
	
	

/* Merge Kids Long _____________________________________________________________*/

		merge 1:n id_resp_uid using `temp_end_kid', gen(merge_end_kid)
			drop if merge_end_kid == 2
			drop if id_village_uid == ""
	
	save "${data}/03_final_data/pfm_as2_merged_kids.dta", replace
	
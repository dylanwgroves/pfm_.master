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
	
	tempfile temp_end_kid_long

/* Import Data ________________________________________________________________*/

/* NOTES: 

	-	to avoid confusion, 
		"b_" in front of all baseline variables and
		"m_" in front of all midline variables
		"e_" in front of all endline variables

*/

	/* Audio Screening */
	
		/* All villages */
		use "${data}/01_raw_data/pfm_allvills_clean.dta"
		sort village_id
		save `temp_allvills'
		
		/* Baseline */
		use "${data}/02_mid_data/pfm_as2_baseline_clean.dta", clear
		rename * b_*
		gen village_id = b_id_village_uid
		replace village_id = subinstr(village_id, "_", "-", .)
		rename b_resp_id resp_id
		sort village_id resp_id
		save `temp_base'
		
		/* Midline */
		use "${data}/02_mid_data/pfm_as2_midline_clean.dta", clear
		rename * m_*
		rename m_resp_id resp_id
		sort resp_id 
		save `temp_mid', replace
		
		/* Endline */
		use  "${data}/02_mid_data/pfm_as2_endline_clean.dta", clear
		rename * e_*
		rename e_resp_id resp_id
		sort resp_id 
		save `temp_end'
	
		/* Partner */
		use "${data}/02_mid_data/pfm_as2_endline_clean_partner.dta", clear
		rename consented* c*
		rename * p_*	
		rename 	p_resp_id 		resp_id
		rename 	p_resp_id_par 	resp_id_par
		save `temp_end_partner'
		
		/* Kids -- use the wide dta! */
		use "${data}/02_mid_data/pfm_as_endline_clean_kid_wide.dta", clear
		rename resp_id_parent resp_id 
		drop k_id_re* k_resp_id_pull* k_id*
*		rename * k_*		// already k_ in the wide 
		save `temp_end_kid'
	
	/* Audio Screening 2 Randomization */
	
		/* AS2 Randomization */
		use "${data}/02_mid_data/pfm_randomized_as2.dta", clear
		gen village_id = subinstr(id_village_uid, "_", "-", .)
		save `temp_rand'
			
		/* AS2 RI */
		use "${data}/02_mid_data/pfm_ri_as2.dta", clear
		drop id_ward_uid
		gen village_id = subinstr(id_village_uid, "_", "-", .)
		save `temp_ri'
		
		
	/* Radio */
	
		/* Radio Randomization */

		/* Radio RI */
		use "${data}/02_mid_data/pfm_ri_rd_as2_cm.dta", clear
		rename id_resp_uid resp_id
		sort resp_id
		save `temp_rd_ri'
		
			
/* Merge _______________________________________________________________________*/
	
	/* Merge surveys */
		use `temp_allvills'
		merge 1:n village_id using `temp_base',  gen(merge_base)
			drop if merge_base == 1
		merge 1:1 resp_id using `temp_mid',  gen(merge_base_mid)
			gen m_attritor = (merge_base_mid==1)
		merge 1:1 resp_id using `temp_end',  gen(merge_base_mid_end)
			gen e_attritor = (merge_base_mid_end==1)
		merge 1:1 resp_id using `temp_end_partner',  gen(merge_base_mid_end_p)
		merge 1:1 resp_id using `temp_end_kid',  gen(merge_base_mid_end_k)
	
	
	/* AS Randomization */
		merge n:1 village_id using `temp_rand',  gen(merge_rand_as)
		
	/* AS Randomizations -- with RI */
		merge n:1 village_id using `temp_ri',  gen(merge_rand_as_ri)
		
		
	/* Radio Randomization -- without RI*/
		
	/* Radio Randomization -- with RI */
		merge 1:1 resp_id using `temp_rd_ri', force gen(merge_rd_as2_ri)
		drop if merge_rd_as2_ri == 2
		drop OBJECTID
	
	
	/* Unique IDs */
		gen id_resp_c = b_id_resp_c
			lab var id_resp_c "Respondent Code"
		
		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		drop id_village_uid
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		gen id_resp_uid = resp_id			
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
	
		drop	b_id_* m_id_* e_id_* resp_id_par ///
				objectid *_region_code  *_district_code *_ward_code  *_village_code  village_id *_id_resp_c  
					
/* Label ______________________________________________________________________*/

	rename *_religious_* *_rel_*
	rename *_second_* *_2nd_*
	rename *_rand_* *_r_*
	rename *_enviro_* *_env_*
	drop *_label_*
	drop *_randomizer_*
	rename *_ptixpart_* *_ppart_*
	rename *_section_* *_sect_*
	rename *_receive_* *_rec_*
	rename *_marital_status_* *_marstat_*
	rename e_end_* e_*
	rename *_productivity_* *_product_*
	rename *_visitcity_* *_gocity_*
	rename *_safe_streets_* *_sfstreet_*
	drop e_resp_gocity_activities__222 
	drop p_resp_gocity_activities__222
	rename *_radio_stations_* *_radstat_*
	rename *_compliance_* *_comply_*
	rename *_wifesampling_* *_wifesamp_*
	rename p_end_* p_*
	rename k_end_* k_*
	rename k_resp_religion_txt_swa_pull* k_resp_rel_txt_swa_pull*
	rename k_as2_* k_*
	rename k_pi_cut_comvil_rej_txt_pull* k_pi_cut_comvil_rej_txt*
	rename k_pi_cut_comvil_tot_txt_pull* k_pi_cut_comvil_tot_txt*
	*rename p_excluderadioownershipmodule p_noradioownmodule
	
	rename * as2_*	
	rename as2_id_* id_*
	*rename as2_sample sample
		gen sample = "as2"

/* Save -- PICK WHICH ONE YOU WANT TO SAVE AND CHANGE THE MERGE ACCORDINGLY ____*/

	*CURRENTLY: saves with AS2 RI and RD RI, can be changed above! 

	/* save with RI */
	save "${data}/03_final_data/pfm_as2_merged_withri.dta", replace
	
	
	/* save without RI 
	save "${data}/03_final_data/pfm_as2_merged.dta", replace
	*/
	
/* Merge Kids Long if needed ___________________________________________________*/
		
	/* Kids -- use the long dta! 
	use "${data}/02_mid_data/pfm_as2_endline_clean_kids.dta", clear
	gen k_resp_kidnum = substr(k_resp_id,-1,.)
	rename resp_id_parent resp_id 
	rename * k_*	
	rename k_resp_id id_resp_uid
	save `temp_end_kid_long'
	*/
	
	/* without RI 
	
		use "${data}/03_final_data/pfm_as2_merged.dta", replace
		drop as2_k_*  // drop wide kids
		
		merge 1:n id_resp_uid using `temp_end_kid_long', gen(merge_end_kidlong)
		
		/* Label */
		rename as2_* *	
		rename *_end_* *_e_*
		rename *_responsibilities_* *_respo_*
		rename *_parent_interviewed_* *_p_int_*
		rename k_gbv_safe_streets_self_short k_gbv_safe_str_self_short
		rename * as2_*	
		rename as2_id_* id_*
		
		/* Save */
		save "${data}/03_final_data/pfm_as2_merged_kids_long.dta", replace
	*/    

	/* with RI 
	
		use "${data}/03_final_data/pfm_as2_merged_withri.dta", replace
		drop as2_k_*  // drop wide kids

		merge 1:n id_resp_uid using `temp_end_kid_long', gen(merge_end_kidlong)
		
		/* Label */
		rename as2_* *	
		rename *_end_* *_e_*
		rename *_responsibilities_* *_respo_*
		rename *_parent_interviewed_* *_p_int_*
		rename k_gbv_safe_streets_self_short k_gbv_safe_str_self_short
		rename * as2_*	
		rename as2_id_* id_*
		
		/* Save  */

		save "${data}/03_final_data/pfm_as2_merged_kids_withri.dta", replace
		drop as2_treat_* 
		drop as2_rd_treat_*
		save "${data}/03_final_data/pfm_as2_merged_kids.dta", replace   
	*/
	

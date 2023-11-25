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
	-	to avoid confusion, 
		"b_" in front of all baseline variables
		"m_" in front of all midline variables
		"e_" in front of all midline variables	
*/

	/* Audio Screening 2 */
	
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
		rename p_resp_id resp_id
		save `temp_end_partner'
		
		/* Kids */
		use "${data}/02_mid_data/pfm_as2_endline_clean_kids.dta", clear
		gen k_resp_kidnum = substr(k_resp_id,-1,.) 
		rename resp_id_parent resp_id 
		rename * k_*		
		rename k_resp_id id_resp_uid
		save `temp_end_kid'
	

	/* Randomization */

		/* Village Randomization */
		use "${data}/02_mid_data/pfm_randomized_as2.dta", clear
		gen village_id = subinstr(id_village_uid, "_", "-", .)
		save `temp_rand'
			
		/* Village RI 
		use "${data}/02_mid_data/pfm_ri_as2.dta", clear
		gen village_id = subinstr(id_village_uid, "_", "-", .)
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
	

/* Merge _______________________________________________________________________*/
	
		use `temp_allvills'
		merge 1:n village_id using `temp_base', force gen(merge_base)
			drop if merge_base == 1
		merge 1:1 resp_id using `temp_mid', force gen(merge_base_mid)
			gen m_attritor = (merge_base_mid==1)
		merge 1:1 resp_id using `temp_end', force gen(merge_base_mid_end)
			gen e_attritor = (merge_base_mid_end==1)
		merge 1:1 resp_id using `temp_end_partner', force gen(merge_base_mid_end_p)
	
		/* AS Randomizations */
		merge n:1 village_id using `temp_rand', force gen(merge_ri_rd)
		*merge n:1 village_id using `temp_ri', force gen(merge_ri_as)
		
	/* Unique IDs */
		/*
		gen id_resp_n = b_resp_name
			lab var id_resp_n "Respondent Name"
		*/
		
		*drop id_ward_uid
		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		drop id_village_uid
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		gen id_resp_c = b_id_resp_c
			lab var id_resp_c "Respondent Code"
		
		gen id_resp_uid = resp_id			
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
		
		drop	*_id_ward_uid *_id_village_uid *_id_resp_c ///
				objectid
			
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
	*save "${data}/03_final_data/pfm_as2_merged_withri.dta", replace
	
	/* Save NO PII _____________________________________________________________*/

		drop 	id_region_n id_district_n id_ward_n id_village_n ///
				as2_*_enum_name 		///
				as2_*_region_name 		///
				as2_*_district_name 	///
				as2_*_ward_name 		///
				as2_*_village_name  	///
				as2_*_village_pull 		///
				as2_*_correct_village	///
				as2_*_sub_village		///
				as2_*_sub_village_pull 	///
				as2_*_correct_subvillage	///
				as2_*_key 				///
				as2_*_concl_phone as2_*_concl_phone_re 	///
				as2_*_gps*				///
				as2_m_phone_pull 		///
				as2_*_resp_name			///
				as2_*_name_pull 		///
				as2_*_correct_name		///
				as2_*_enum_name 		///
				as2_p_id_resp_name_pull ///
				as2_p_k_resp_name* 		///
				as2_p_spouse_name_pull  ///
				as2_p_id_district_name_pull ///
				as2_p_id_ward_name_pull ///
				as2_p_id_village_name_pull ///
				as2_p_id_sub_village_name_pull ///
				as2_p_new_enum_name		

		label drop 	enum

		save "${data}/03_final_data/pfm_nopii_as2_merged.dta", replace
	

/* Merge Kids Long _____________________________________________________________*/

	use "${data}/03_final_data/pfm_as2_merged.dta", replace
	*use "${data}/03_final_data/pfm_as2_merged_withri.dta", replace

	merge 1:n id_resp_uid using `temp_end_kid', gen(merge_end_kid)

	/* Label */
	rename as2_* *	
	rename *_end_* *_e_*
	rename *_responsibilities_* *_respo_*
	rename *_parent_interviewed_* *_p_int_*
	rename k_gbv_safe_streets_self_short k_gbv_safe_str_self_short
	rename * as2_*	
	rename as2_id_* id_*

	/* Save */
	save "${data}/03_final_data/pfm_as2_merged_kids.dta", replace
	*save "${data}/03_final_data/pfm_as2_merged_kids_withri.dta", replace


	/* Save NO PII _____________________________________________________________*/

		drop 	id_region_n id_district_n id_ward_n id_village_n ///
				as2_*_enum_name 		///
				as2_*_region_name 		///
				as2_*_district_name 	///
				as2_*_ward_name 		///
				as2_*_village_name  	///
				as2_*_village_pull 		///
				as2_*_correct_village	///
				as2_*_sub_village		///
				as2_*_sub_village_pull 	///
				as2_*_correct_subvillage	///
				as2_*_key 				///
				as2_*_concl_phone as2_*_concl_phone_re 	///
				as2_*_gps*				///
				as2_m_phone_pull 		///
				as2_*_resp_name			///
				as2_*_name_pull 		///
				as2_*_correct_name		///
				as2_*_enum_name 		///
				as2_p_id_resp_name_pull ///
				as2_p_k_resp_name* 		///
				as2_p_spouse_name_pull  ///
				as2_p_id_district_name_pull ///
				as2_p_id_ward_name_pull ///
				as2_p_id_village_name_pull ///
				as2_p_id_sub_village_name_pull ///
				as2_p_new_enum_name		/// 
				as2_k_parent_name 		/// 
				as2_k_correct_parent_name ///
				as2_k_correct_kid_name ///
				as2_k_s20q2latitude as2_k_s20q2longitude as2_k_s20q2altitude as2_k_s20q2accuracy 
			
		label drop 	enum

		save "${data}/03_final_data/pfm_nopii_as2_merged_kids.dta", replace

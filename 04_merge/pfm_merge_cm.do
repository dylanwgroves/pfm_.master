/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Community Media Datasets
	Date: 2023.10.28
	Author: dylan w groves, dylanwgroves@gmail.com
	Overview: This merges and appends are relevant datasets
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all
	set maxvar 30000
	
/* Tempfiles ___________________________________________________________________*/
	
	tempfile temp_allvills
	tempfile temp_1_2020
	tempfile temp_2_2021
	tempfile temp_3_2023
	
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

/* Import Data ________________________________________________________________

NOTES: 

	- 	we might want to consider adding a prefix to each survey so we know where its
		coming from		
		
	-	to avoid confusion, put "b_" in front of all baseline variables and
		"m_" in front of all midline variables

*/


	/* Audio Screening */
	
		/* All villages */
		use "${data}/01_raw_data/pfm_allvills_clean.dta", clear
		sort village_id
		save `temp_allvills'
		
		/* Community Media 1 (2020) */
		use "${data}/02_mid_data/pfm_cm_1_2020_clean.dta", clear
		drop political_participation_rpt_coun 
		rename values_noneighbor_* values_nonbr_*
		rename ptixpart_* ppart_*
		sort village_id
		replace village_id = svy_vill_c if village_id == ""
		replace village_id = subinstr(village_id, "_", "-", .)
		rename * cm1_*
		rename cm1_resp_id resp_id
		rename cm1_village_id village_id
		save `temp_1_2020'
		
		/* Community media 2 (2021) */
		use "${data}/02_mid_data/pfm_cm_2_2021_clean.dta", clear
		drop id_village
		rename s1q4_village village_id
		replace village_id = "5-51-52" if village_id == "-222"
		sort village_id
		rename ccimpact_problems_* ccprobs_*
		rename section_couplesconflict_* section_cfight_*
		rename couplesconflict_* cfight_*
		rename * cm2_*
		rename cm2_resp_id resp_id
		duplicates drop resp_id, force
		save `temp_2_2021'
		
		/* Community media 3 (2023) */
		use "${data}/02_mid_data/pfm_cm_3_2023_clean.dta"
		sort resp_id
		rename *_relationship_* *_rltn_*
		rename enviro_* env_*
		rename agr_productivity_* agr_prod_*
		rename radio_stations_* radio_stns_*
		rename rd_receive_* rd_rec_*
		rename consented_* cnsnt_*
		rename * cm3_*
		rename cm3_resp_id resp_id
		save `temp_3_2023'
			
	/* Radio */

		
		/* Radio Randomization 
		use "${data}/02_mid_data/pfm_rd_randomization_as.dta", clear
		save `temp_rd_rand'
		*/
		
		/* Radio RI */
		use "${data}/02_mid_data/pfm_ri_rd_cm.dta", clear
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
		merge 1:n village_id using `temp_1_2020', force gen(merge_1_2020)
			drop if merge_1_2020 == 1
		merge 1:1 resp_id using `temp_2_2021', force gen(merge_2_2021)		
		merge 1:1 resp_id using `temp_3_2023', force gen(merge_3_2023)
	
		/* RI */
		merge 1:1 resp_id using `temp_rd_ri', force gen(merge_ri_rd)

		
	/* Unique IDs */
	/*
		gen id_resp_c = b_resp_c
			lab var id_resp_c "Respondent Code"
		
		gen id_resp_n = b_resp_name
			lab var id_resp_n "Respondent Name"
	*/
		egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		drop id_village_uid
		egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		gen id_resp_uid = resp_id			
			lab var id_resp_uid "Respondent Unique ID"
			
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
	

/* Label ______________________________________________________________________*/
	
	gen sample = "cm"

/* Save ________________________________________________________________________*/

	save "${data}/03_final_data/pfm_cm_merged.dta", replace
	
	
	use "${data}/03_final_data/pfm_cm_merged.dta", replace
	
	
	
	
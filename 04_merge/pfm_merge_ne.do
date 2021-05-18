/*______________________________________________________________________________

	Project: Pangani FM
	File: Merges Natural Experiment Datasets
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

	clear all
	set maxvar 32767
	set seed 1956		
	
/* Temfiles __________________________________________________________________*/

	tempfile temp_allvills
	tempfile temp_base
	tempfile temp_end
	tempfile temp_end_merge
	tempfile temp_merged
	tempfile temp_base_rand
	tempfile temp_rd_dist
	tempfile temp_rd_rand
	tempfile temp_rand
	tempfile temp_rd_ri
	tempfile temp_end_partner


/* Import Data _________________________________________________________________

	NOTES: 
		- 	we might want to consider adding a prefix to each survey so we know where its
			coming from
*/

	/* Natural Experiment */
	
		/* All villages */
		use "${data}/01_raw_data/pfm_allvills_clean.dta"
		sort village_id
		save `temp_allvills'
		
		/* Baseline */
		use "${data}/02_mid_data/pfm_ne_baseline_clean.dta", clear
		gen baseline = 1
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
		gen endline = 1
		save `temp_end', replace
		
		/* Partner Endline */
		use "${data}/02_mid_data/pfm_ne_endline_partner_clean.dta", clear
		rename * p_*			
		gen id_resp_uid = subinstr(p_id_resp_uid,"_p","",.)						// Create matching unique respondent id
			replace id_resp_uid =subinstr(id_resp_uid,"_P","",.)
			duplicates drop id_resp_uid, force
		save `temp_end_partner'

		/* Village Sample */
		use "${data}/02_mid_data/pfm_ne_scoping_clean.dta", clear
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
	
		/* Baseline, treatment assignment */
		use `temp_allvills'
		merge 1:n objectid using `temp_base', gen(merge_base)					// Baseline
			drop if merge_base==1
		merge n:1 objectid using `temp_rand', gen(merge_base_rand)				// Village randomization
		save `temp_base_rand', replace

		/* Radio randomization and distribution */
		use `temp_rd_rand', clear												// Radio randomization
		merge 1:1 respid using `temp_rd_dist', gen(merge_rd)					// Radio distribution
			drop if merge_rd == 2
		
		/*	NE and RD */
		merge 1:1 resp_id using `temp_base_rand', gen(merge_base_rand_rd)
		
		/* RI */
		merge 1:1 resp_id using `temp_rd_ri', gen(merge_rd_ri)
	
	/* Create unique ids */
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
			
		save `temp_base', replace
		
			
		/* Merge endline */
		merge 1:1 id_resp_uid using `temp_end', gen(merge_end)
		rename treat b_treat
		bys id_village_n : egen treat_ne = max(b_treat)							// Assign treatment to replacements, who dont have baseline data w/ treatment assignment
		bys id_village_n : egen block_ne = max(pair_c)	
		gen svy_attrition = 1 if b_baseline ==1 & endline != 1					// Create attrition variable
			replace svy_attrition = 0 if b_baseline == 1 & endline == 1
		sort id_village_n id_resp_uid										

		/* Merge Partner */
		merge 1:1 id_resp_uid using `temp_end_partner', gen(merge_end_part)
		save `temp_end', replace
	
		/* Fix endline respondent IDs */
			/* Prepare endline replacements */
			use `temp_end', clear												// Randomly assign ID to replacement respondents
			keep if svy_replacement == 1
			gen rand_merge = runiform()		
			sort id_village_n resp_female rand_merge 
			bys id_village_n resp_female: gen merge_rank = _n
			keep id_resp_uid id_village_n resp_female merge_rank treat_ne resp_name asset_radio svy_replacement rand_merge 
			rename id_resp_uid id_resp_uidR
			save `temp_merged', replace
			order id_resp_uid id_village_n svy_replacement
			sort id_village_n resp_female rand_merge 	

			/* Prepare baseline attriters */
			use `temp_end', clear												// Randomly assign ID to respondents who needed to be replaced
			keep if svy_attrition == 1 											// Only assign to attriters
			keep if rd_treat == . 												// Do not assign to folks in RD sample snce they were not assigned replacements
			gen rand_merge = runiform()	
			sort id_village_n b_resp_female rand_merge 
			bys id_village_n b_resp_female: gen merge_rank = _n 
			keep id_resp_uid id_village_n b_resp_female merge_rank b_asset_radio treat_ne b_asset_radio rand_merge
			rename id_resp_uid id_resp_uidB
			gen resp_female = b_resp_female
			
			duplicates list id_village_n resp_female merge_rank 
			order id_resp_uid id_village_n
			sort id_village_n resp_female rand_merge 

			/* Merge replacements and baseline attriters */
			merge 1:1 id_village_n resp_female merge_rank using `temp_merged', gen(_merge_attriterid)
			keep if _merge_attriterid == 3 | _merge_attriterid == 2 			// Keep successful matches and 
			drop if b_asset_radio == 0											// Drop people in control group who were replacing 
			keep id_resp_uidB id_resp_uidR  _merge_attriterid 					//treat_ne id_village_n merge_rank resp_female b_resp_female resp_name b_asset_radio asset_radio
			gen id_resp_uid = id_resp_uidR 
			gen svy_replacement_nesample = 1 
			
			/* Merge with endline again */
			merge 1:1 id_resp_uid using `temp_end', gen(merge_attriterid2)		// Merge
			replace id_resp_uid = id_resp_uidB + "R" if svy_replacement_nesample == 1 & id_resp_uidB != ""	// Replace the ID with the baseline ID 
			replace id_resp_uid = id_resp_uidR if svy_replacement_nesample == 1 & id_resp_uidB == ""	// 
			order id_resp_uid id_resp_uidB id_resp_uidR id_village_n 
			sort id_village_n
			*drop svy_replacement_nesample
			*duplicates tag id_resp_uid, gen(SB)
			*keep if SB == 1
			order resp_female svy_replacement_nesample
			sort id_village_n id_resp_uid

			/* Do some hand-fixes to avoid duplicates */
			replace id_resp_uid = "8_111_3_36R" if id_resp_uidR == "8_111_3_36R"
			replace id_resp_uid = "3_221_4_200R" if id_resp_uidR == "3_221_4_2 R"
			replace id_resp_uid = "2_31_2_151R" if id_resp_uidR == "2_31_2_151R"
			replace id_resp_uid = "3_221_2_8R" if id_resp_uidR == "3_221_2_8R"
			replace id_resp_uid = "1_411_4_63R" if id_resp_uidR == "1_411_4_63R"
			
			/* Calculate total in need of replacement */
			bys id_village_n: egen vill_baseline = total(b_baseline)

			/* Expand village-level variables */
			foreach var of varlist /// 	
								v_cellpfm v_radiopfm v_cell v_cell_bar v_timetotown /// 
								v_electricity v_muslim v_mixed v_noworship v_mosques ///
								v_churches v_totworship v_villexec v_pop v_subvills ///
								v_poplist v_poplist_final v_subvil_reachable ///
								v_subvil_cell v_subvil_cellpfm v_subvil_radpfm {
								
				bys id_village_n : egen `var'_max = max(`var')
				replace `var' = `var'_max
				drop `var'_max
			}
			
/* Label ______________________________________________________________________*/

	rename * ne_*	
	rename ne_id_* id_*
	rename ne_sample sample
		replace sample = "ne"

/* Save ______________________________________________________________________*/

	save "${data}/03_final_data/pfm_ne_merged.dta", replace
	
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
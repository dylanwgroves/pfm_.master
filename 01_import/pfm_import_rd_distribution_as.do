/*______________________________________________________________________________
* Project: Pangani FM 2
* File: Baseline Pilot Import and Cleaning
* Date: 7/5/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports piloting data
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Import Data _________________________________________________________________*/

	use "${ipa_as}\05_data\09_radio_distribution\04_precheck/panganifm2_radio_survey_clean_MERGED.dta", clear 
	rename resp_name resp_n
	sort resp_n
	drop if resp_n == "Henry francis mbago" & q9_consent == . 				// two interviews with same respondnent, one in which radio distribution appears to have happend
	
	rename resp_id resp_id_rd 												// rename resp_id so it doesn't get saved over when merging
	tempfile temp_rd
	save `temp_rd'
	
	
/* Get Respondent IDs __________________________________________________________*/

/* 	40 resp_id are missing from the survey, so we need to merge back in the original 
	randomization to save them */

	use "${ipa_as}/04_checks/02_outputs/DG_panganifm2_radiodistribution_master.dta", clear	// This will need to be updated when we incorporate the randomization
	rename resp_name resp_n
	sort resp_n
	keep resp_n resp_id
	
	merge 1:1 resp_n using `temp_rd'
	keep if _merge == 3
	replace resp_id = resp_id_rd if resp_id_rd != ""
	drop _merge resp_id_rd
	
	
/* Export ______________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/pfm_pii_rd_distribution_as.dta", replace

	/* No PII */
	drop resp_n q6_n q15_name_neighbour q17_name_neighbour2 q16_phone_neighbour q18_phone_neighbour2 neighbour2_locationlongitude neighbour_locationlatitude neighbour2_locationlatitude
	save "${data}/01_raw_data/pfm_nopii_rd_distribution_as.dta", replace






*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: Radio Distribution Randomization (AS)
* Date: 8/22/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports radio distribution randomization file
*-------------------------------------------------------------------------------

/* Introduction ___________________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Import Data ___________________________________________________________________*/

	use "${ipa_as}/04_checks/02_outputs/DG_panganifm2_radiodistribution_master.dta", clear	// This will need to be updated when we incorporate the randomization

	
/* Data Cleaning ___________________________________________________________________*/

	* Geographic Variables
	rename *_code *_c
	rename *_name *_n

	* Respondent variables
	rename s2q1_gender resp_gender
	rename radiorandomization_treat treat_rd
	lab var treat_rd "Radio Randomization Treatment"

	/* Create sample identifier */
	gen sample_rd = 1


/* Export _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/pfm_pii_rd_random_as.dta", replace

	/* No PII */
	drop resp_n cases_phone1 cases_phone2 cases_*
	save "${data}/01_raw_data/pfm_nopii_rd_random_as.dta", replace






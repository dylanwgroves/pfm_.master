
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survey 2 (November 2021)
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023/10/28
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${ipa_cm_2_2021}/panganifm_survey2_clean.dta", clear

/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_cm_2_2021.dta", replace

	/* No PII */
	drop resp_name replace_hh_name1_1 replace_hh_name2_1 replace_hh_name3_1 replace_hh_name1_2 replace_hh_name2_2 replace_hh_name3_2 replace_hh_name1_3 replace_hh_name2_3 replace_hh_name3_3 s20q1b s20q1b_oth s20q2longitude replace_locationlongitude replace_locationlatitude s20q2latitude
	
	save "${data}/01_raw_data/03_surveys/pfm_nopii_cm_2_2021.dta", replace


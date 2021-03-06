
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${ipa_as}/05_data/04_precheck/panganifm2_baseline_clean", clear


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_as_baseline.dta", replace

	/* No PII */
	drop head_name resp_name survey_locationlongitude survey_locationlatitude
	save "${data}/01_raw_data/pfm_nopii_as_baseline.dta", replace


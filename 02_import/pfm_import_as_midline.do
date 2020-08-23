
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening  
Purpose: Import midline and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	version 15 
	set maxvar 30000

/* Import  _____________________________________________________________________*/

	use "${ipa_as}/05_data/04_precheck/panganifm2_Followup_clean", clear


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}\01_raw_data\03_surveys\pfm_as_midline_nopii.dta", replace

	/* No PII */
	drop head_name resp_name cases_label pre_label pre_phone* pre_phone2 pre_resp_name pre_hhh_name
	save "${data}\01_raw_data\03_surveys\pfm_as_midline_nopii.dta", replace



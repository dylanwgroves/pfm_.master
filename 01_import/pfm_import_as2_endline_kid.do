
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening 2 (2022-2023)
Purpose: Import raw data and remove PII - endline partner
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023.10.28
________________________________________________________________________________*/

	
/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${ipa_as2_endline}/pfm5_child.dta", clear


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_endline_kids.dta", replace

	/* No PII */
	drop k_resp_name correct_kid_name correct_parent_name s20q2longitude s20q2latitude
	save "${data}/01_raw_data/pfm_nopii_as2_endline_kids.dta", replace


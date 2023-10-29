
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening 2 (2022-2023)
Purpose: Import raw data and remove PII - endline
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023.10.28
________________________________________________________________________________*/

	
/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${ipa_as2_endline}/pfm5_endline_fixed.dta", clear
	

/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_endline.dta", replace

	/* No PII */
	drop resp_name name_pull info_confirm correct_name kids_first_name_r_1 kids_second_name_r_1 kids_third_name_r_1 child_full_name_r_1 kids_first_name_r_2 kids_second_name_r_2 kids_third_name_r_2 child_full_name_r_2 kids_first_name_r_3 kids_second_name_r_3 kids_third_name_r_3 child_full_name_r_3 kids_first_name_r_4 kids_second_name_r_4 kids_third_name_r_4 child_full_name_r_4 wife_name cases_resp_name gpslongitude gpslatitude
	save "${data}/01_raw_data/pfm_nopii_as2_endline.dta", replace


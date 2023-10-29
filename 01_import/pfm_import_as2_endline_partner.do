
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

	use "${ipa_as2_endline}/pfm5_endline_partner_fixed.dta", clear
	


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_endline_partner.dta", replace

	/* No PII */
	drop resp_name k_resp_name1 k_resp_name2 k_resp_name3 k_resp_name4 p_resp_name name_pull spouse_name_pull new_enum_name correct_name cases_resp_name id_resp_name_pull gpslongitude gpslatitude
	save "${data}/01_raw_data/pfm_nopii_as2_endline_partner.dta", replace


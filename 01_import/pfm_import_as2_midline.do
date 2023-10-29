
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

	use "${ipa_as2_midline}/pfm4_audio_screening_midline_survey_clean.dta", clear


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_midline.dta", replace

	/* No PII */
	drop correct_name cases_resp_name cases_phone concl_phone concl_phone_re phone_pull gpslongitude gpslatitude
	save "${data}/01_raw_data/pfm_nopii_as2_midline.dta", replace


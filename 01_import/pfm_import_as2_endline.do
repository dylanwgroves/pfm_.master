
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

	drop 	_append_phone _merge_radio _merge_radio2 _merge_rdfollowup			///
			caseid cases_* consented* isvalidated simid										///
			deviceid devicephonenum enum_oth excluderadioownershipmodule 		///
			formdef_version pilot_pull subscriberid survey_comment	///
			v5* v6* v7* v8* section_*_start section_*_end section_*_dur text_audit
	
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_endline.dta", replace

	/* No PII */
	
	drop 	District_N Vil_Mtaa_N Ward_Name 									///
			child_full* kids_first_name_r_* kids_old_r_* kids_second_name_r_* kids_third_name_r_*	///
			concl_phone concl_phone_re 								///
			correct_name correct_village village_pull correct_subvillage sub_village_pull	///
			gps* key															///
			name_pull resp_name wife_name ///
			new_enum_name

	label drop 	enum
	
	save "${data}/01_raw_data/03_surveys/pfm_nopii_as2_endline.dta", replace

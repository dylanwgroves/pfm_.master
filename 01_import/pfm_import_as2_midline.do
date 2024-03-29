
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
	

	* import screening 	
	use "${ipa_as2_midline}/pfm4_audio_screening_midline_survey_clean.dta", clear



/* Export  _____________________________________________________________________*/

	/* PII */
		
	drop 	deviceid subscriberid simid devicephonenum caseid liverlihood_pull enum_oth ///
			district_code_oth ward_code_oth village_code_oth							///
			survey_comment cases_* formdef_version *_label isvalidated					///
			consented* v291 v293 v302 section_*_start section_*_end section_*_dur 
	
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_midline.dta", replace

	/* No PII */
	drop 		phone_pull name_pull correct_name								///
				enum_name 														///
				region_name district_name ward_name village_name sub_village sub_village_pull	///
				correct_village 												///
				key concl_phone concl_phone_re 									///
				gps*
	
	label drop 	enum 
				
	save "${data}/01_raw_data/03_surveys/pfm_nopii_as2_midline.dta", replace


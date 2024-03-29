
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening 2 (2022-2023)
Purpose: Import raw data and remove PII - baseline
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023.10.28
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	import excel "${data}/01_raw_data/Screening Attendancy Summary.xlsx", sheet("SUMMARY") firstrow clear
	drop P Q R S T U V W X Y Z
	rename Resp_Name resp_name
	rename Resp_Attend resp_attend
	rename ATT1_Start resp_attend_start
	rename Come_Companion resp_attend_friend
	rename ATT2_Middle resp_attend_middle 
	rename ATT3_End resp_attend_end
	keep resp_id resp_attend resp_attend_*
	
	merge 1:1 resp_id using "${ipa_as2}/pfm4_audio_screening_survey_encrypted_clean.dta", gen(_merge_attend)

/* Export  _____________________________________________________________________*/

	/* PII */
	
	drop 	deviceid subscriberid simid devicephonenum caseid liverlihood_pull enum_oth ///
			district_code_oth ward_code_oth village_code_oth							///
			survey_comment cases_* formdef_version *_label isvalidated					///
			consented* section_*_start section_*_end section_*_dur 
	
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_baseline.dta", replace

	/* No PII */
	drop 		enum_name 														///
				region_name district_name ward_name village_name sub_village	///
				key concl_phone concl_phone_re 									///
				gps*
	
	label drop 	enum 
				
	save "${data}/01_raw_data/03_surveys/pfm_nopii_as2_baseline.dta", replace



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

	use "${ipa_as2_endline}/pfm5_partner.dta", clear
	


/* Export  _____________________________________________________________________*/

	/* PII */
	drop 	deviceid subscriberid simid devicephonenum username duration caseid ///
			enum_oth survey_comment formdef_version key isvalidated 				///
			excluderadioownershipmodule cases_* v5*  
			* _merge* attritor
	
	save "${data}/01_raw_data/03_surveys/pfm_pii_as2_endline_partner.dta", replace

	/* No PII */
	drop 	name_pull correct_name 					///
			spouse_name_pull							///
			village_pull sub_village_pull correct_village correct_subvillage	///
			new_enum_name															///
			gps*
			* resp_name id_resp_name_pull k_resp_name* p_resp_name 
			* id_district_name_pull id_ward_name_pull id_village_name_pull id_sub_village_name_pull ///

			
	label drop 	enum
	
	save "${data}/01_raw_data/03_surveys/pfm_nopii_as2_endline_partner.dta", replace


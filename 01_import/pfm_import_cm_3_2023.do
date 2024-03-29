
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survey 3 (November 2023)
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023/10/28
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${data}/01_raw_data/pfm5_pangani_preclean.dta", clear

/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_cm_3_2023.dta", replace

	/* No PII */
	drop resp_name  replace_hh_name1_1 replace_hh_name2_1 replace_hh_name3_1 replace_hh_name1_2 replace_hh_name2_2 replace_hh_name3_2 name_pull concl_phone cases_phone replace_locationlongitude gpslongitude gpslatitude
	
	save "${data}/01_raw_data/03_surveys/pfm_nopii_cm_3_2023.dta", replace


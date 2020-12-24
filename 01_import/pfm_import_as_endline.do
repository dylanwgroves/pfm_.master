
/* _____________________________________________________________________________

project: Wellspring Tanzania, Audio Screening
purpose: Endline Data: import raw data and remove PII
author: dylan groves, dylanwgroves@gmail.com
date: 2020/12/23


	Structure: 
	-- Import
	-- Additonal cleaning
	-- Export
	 

	Still to be done:
	-- Drop PII
	-- Any additional cleaning

________________________________________________________________________________*/



/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	version 15 
	set maxvar 30000

	
/* Import data _________________________________________________________________*/
	
	use "${ipa_as_endline}\audio_screening_survey_encrypted_clean.dta", clear

/* Cleaning __________________________________________________________*/



/* Export ____________________________________________________________________*/

	/* PII */
	save "${data}\01_raw_data\03_surveys\pfm_rawpii_as_endline.dta", replace

	/* No PII */
	*drop head_name resp_name survey_locationlongitude survey_locationlatitude enumerator_notes resp_phon*				/// NEED TO UPDATE
	save "${data}\01_raw_data\03_surveys\pfm_rawnopii_as_endline.dta", replace

		
		
		


/* _____________________________________________________________________________

project: Wellspring Tanzania, Natural Experiment
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
	
	use "${ipa_ne_endline}/natural_experiment_survey_encrypted_clean.dta" 


/* Cleaning __________________________________________________________*/



/* Export ____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_rawpii_ne_endline.dta", replace

	/* No PII */
	*drop head_name resp_name survey_locationlongitude survey_locationlatitude enumerator_notes resp_phon*				/// NEED TO UPDATE
	save "${data}/01_raw_data/03_surveys/pfm_rawnopii_ne_endline.dta", replace

		
		
		

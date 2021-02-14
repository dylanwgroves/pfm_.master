
/* _____________________________________________________________________________

project: Wellspring Tanzania, Audio Screening
purpose: Endline Data: import raw data and remove PII from kids survey
author: dylan groves, dylanwgroves@gmail.com
date: 2021/02/13


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
	
	use "${ipa_as_endline_spill}/02_imported/friend_survey_encrypted.dta" 


/* Formatting Date _____________________________________________________________*/

	* startdate
			gen startdate = dofc(starttime) 
			order startdate, after(starttime)
			format %td startdate
		
	* enddate
		gen enddate = dofc(endtime) 
		order enddate, after(endtime)
	
	format %td enddate
	
		
/* Survey_length _______________________________________________________________*/
 
	generate double survey_length = endtime - starttime
	replace survey_length = round(survey_length / (1000*60), 1) // in minutes
		
		
/* Dropping testing and piloting data: _________________________________________*/	
				
	drop if startdate < td(27012021)
	
	
/* Dropping refusals ___________________________________________________________*/
	
	drop if consent==0
	
/* Export ____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_rawpii_as_endline_friend.dta", replace

	/* No PII */
	*drop head_name resp_name survey_locationlongitude survey_locationlatitude enumerator_notes resp_phon*				/// NEED TO UPDATE
	
	save "${data}/01_raw_data/03_surveys/pfm_rawnopii_as_endline_friend.dta", replace

		
		
		

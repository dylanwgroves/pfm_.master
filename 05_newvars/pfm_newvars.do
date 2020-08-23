/*______________________________________________________________________________

	Project: Pangani FM
	File: Creates New Variables for Merged / Appended Dataset
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/



/* Introduction ________________________________________________________________*/

	clear all
	

/* Import Data _________________________________________________________________*/

	use "${data}/03_final_data/pfm_appended.dta", clear
	
	
/* Define Samples ______________________________________________________________*/

	gen sample_survey = 1 if ne_sample == "ne"
		replace sample_survey = 2 if as_sample == "as"
		lab def sample_survey 1 "Natural Experiment" 2 "Audio Screening" 3 "Pangani"
		lab val sample_survey sample_survey
		lab var sample_survey "Sample survey (Audio Screening / Natural Experiment / Pangani)"
	
	gen sample_ne = (ne_sample == "ne")
		lab var sample_ne "Natural Experiment Sample"
	gen sample_as = (as_sample == "as")
		lab var sample_as "Audio Screening Sample"
	gen sample_rd = (ne_sample_rd == 1) | (as_sample_rd == 1)
		lab var sample_rd "Radio Distribution Sample"
		
		
/* Treatment Groups ____________________________________________________________*/

	/* Natural Experiment */
	rename ne_treat treat_ne
		lab def treat_ne 0 "Outside PFM range" 1 "Inside PFM range"
		lab val treat_ne treat_ne
		lab var treat_ne "Treatment - Natural Experiment"
	
	/* Audio Screening */
	rename as_treat treat_as
		lab def treat_as 0 "HIV screening" 1 "EFM screening"
		lab val treat_as treat_as
		lab var treat_as "Treatment - Audio Screening"

	/* Radio Distribution */	
	gen treat_rd = (ne_treat_rd == 1) | (as_treat_rd == "Treat")
	replace treat_rd = . if  sample_rd == 0
		lab def treat_rd 0 "No radio" 1 "Received radio" 
		lab val treat_rd treat_rd
		lab var treat_rd "Treatment - Radio distribution"
		
	/* Drop */
	drop ne_treat_rd as_treat_rd id_re id_2 	

/* Identifiers _________________________________________________________________*/

	label var id_region_c "Region Code"
	label var id_region_n "Region Name"
	label var id_district_c "District Code"
	label var id_district_n "District Name"
	label var id_ward_c "Ward Code"
	label var id_ward_n "Ward Name"
	label var id_village_n "Village Name"
	label var id_village_c "Village Code"
	
	gen id_resp_c = ne_id
		replace id_resp_c = as_resp_c if sample_as == 1
		lab var id_resp_c "Respondnet Code"
	gen id_resp_n = ne_resp_name if sample_ne == 1
		replace id_resp_n = as_name if sample_as == 1							// SOME VILLAGES ARE MISSING
		lab var id_resp_n "Respondnet Name"
		
	/* Unique IDs */
	egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
		lab var id_village_uid "Village Unique ID"
		
	egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
		lab var id_resp_uid "Respondent Unique ID"

/* Drop ________________________________________________________________________*/

drop as_cases*

keep sample_* treat_* id_*
sort id_village_uid id_resp_uid
order id_* sample_* treat_*

*drop resp_n 


/* Export ________________________________________________________________________*/


save "${data}/03_final_data/pfm_all.dta", replace

	
		
	
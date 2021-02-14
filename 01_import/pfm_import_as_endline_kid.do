
/* _____________________________________________________________________________

project: Wellspring Tanzania, Audio Screening
purpose: Endline Data: import raw data and remove PII from friends data
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
	
	use "${ipa_as_endline_spill}/02_imported/kids_survey_encrypted.dta" 


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

	
/* Cleaning ____________________________________________________________________*/

	replace village_pull="Majani Mapana" if key =="uuid:53fa1cb4-ae75-4574-a3a6-560173c94f36" | key=="uuid:cddbb387-df43-408b-8348-1063591ef7ac" | key=="uuid:f802f011-84ad-454b-9320-148ad5e5366e" 
	replace name_pull ="Ibrahim Hamidu Mshana" if key =="uuid:53fa1cb4-ae75-4574-a3a6-560173c94f36" 
	replace name_pull="Ramadhani Yusuph" if key=="uuid:cddbb387-df43-408b-8348-1063591ef7ac"

	replace parent_name_pull ="Aishatu Juma" if key =="uuid:53fa1cb4-ae75-4574-a3a6-560173c94f36" 
	replace parent_name_pull="Yusuph Rashid" if key=="uuid:cddbb387-df43-408b-8348-1063591ef7ac"


	replace village_pull="Chogo" if key=="uuid:d2cddbdb-3a48-4b78-88f3-e5c778704bc6" | key=="uuid:69898687-968c-4a66-999a-2ce5f85a1214" | key=="uuid:0c6b85b1-16cc-4fa8-976f-35517f11c3a8" 
	replace village_pull="Kwambojo" if key=="uuid:80312e79-c320-492e-a626-2f8d20a16f50" | key=="uuid:4bcaaaef-f31a-4799-9bd3-65f7bc90436a" | key=="uuid:c347f603-37c0-4560-9e77-f082f56866e2" | ///
	key=="uuid:673be251-79bf-4902-a8b5-a8344deb3f9a" | key=="uuid:f535390a-acd2-47d1-82d9-dc951eab5acf" | key=="uuid:17337234-05ec-4f1c-9723-4c9b7189275d"
	replace village_pull="Komsanga" if key=="uuid:d42b5d72-c2c0-4bb0-b16d-c9c22bf11009" | key=="uuid:d4be4e8a-9cbf-46ae-a23f-a7dc5531e045" | key=="uuid:7f335cd2-be1d-4d8f-af97-0082b689e6e9" 
	replace village_pull="Chogo" if id=="6_191_5_62_1"

	
/* Cleaning duplicates__________________________________________________________*/

	replace id = "6_191_3_1_4" if key =="uuid:53fa1cb4-ae75-4574-a3a6-560173c94f36" 
	replace id_re = "6_191_3_1_4" if key =="uuid:53fa1cb4-ae75-4574-a3a6-560173c94f36" 

	replace id="6_191_3_83_2" if key =="uuid:cddbb387-df43-408b-8348-1063591ef7ac"
	replace id_re="6_191_3_83_2" if key =="uuid:cddbb387-df43-408b-8348-1063591ef7ac"

	replace id="6_161_1_72_1" if key =="uuid:2738b915-1ebd-4d01-837b-aa98fa1c7fa3"
	replace id_re="6_161_1_72_1" if key =="uuid:2738b915-1ebd-4d01-837b-aa98fa1c7fa3"

	replace id="3_181_2_91_1" if key =="uuid:5abb7bb6-95de-45b9-b327-0a459aefd1f8"
	replace id_re="3_181_2_91_1" if key =="uuid:5abb7bb6-95de-45b9-b327-0a459aefd1f8"

	replace id="6_201_3_149_1" if key=="uuid:be700c7f-e8ab-4377-a16f-46102ba00bec"
	replace id_re="6_201_3_149_1" if key=="uuid:be700c7f-e8ab-4377-a16f-46102ba00bec"

	replace id="6_191_3_1_1" if id == "6_191_3_100"
	replace id_re="6_191_3_1_1" if id == "6_191_3_100"

/* Export ____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_rawpii_as_endline_kid.dta", replace

	/* No PII */
	*drop head_name resp_name survey_locationlongitude survey_locationlatitude enumerator_notes resp_phon*				/// NEED TO UPDATE
	
	save "${data}/01_raw_data/03_surveys/pfm_rawnopii_as_endline_kid.dta", replace

		
		
		


/* Basics ______________________________________________________________________

project: Wellspring Tanzania, Natural Experiment
purpose: Import raw data and remove PII
author: dylan groves, dylanwgroves@gmail.com
date: 2020/08/18

________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	version 15 
	set maxvar 30000

	
/* Import data ____________________________________________________________________*/

use "${ipa_ne}/0 - Raw Data_encrypted/Baseline/panganifm_baseline survey_cleaned.dta" 


/* Cleaning ____________________________________________________________________*/

replace id  = "6" if key == "uuid:5d6e817c-e87b-4631-9ce9-1a800c95e0ba"
replace id  = "10" if key == "uuid:098bbc57-afc6-4281-9b5f-a2e770e6153f"
replace id  = "13" if key == "uuid:d3147a0d-f40f-47a1-a751-3ede7eae672a"
replace id  = "22" if key == "uuid:429fd374-a0af-4416-8605-cd7106789259"
replace id  = "38" if key == "uuid:13dd632b-7f34-461e-9187-c3a96edf04c0"
replace id  = "41" if key == "uuid:82514855-7e78-423f-a363-52370f3df060"
replace id  = "44" if key == "uuid:7d7e4a59-168a-4c8e-ac2d-858ad1515544"
replace id  = "51" if key == "uuid:1ff2aa64-db3d-4a79-8c4e-24dd4e8bdd70"
replace id  = "67" if key == "uuid:bb327259-8175-4bbb-b783-238e1a18b586"
replace id  = "71" if key == "uuid:14ab5a2a-5868-4f10-b3d8-66470495b251"
replace id  = "74" if key == "uuid:5d902b47-f737-4ddf-b468-bc778746619e"
replace id  = "76" if key == "uuid:d20b7f08-39e6-47e4-8bf9-2bf7583ca92b"
replace id  = "79" if key == "uuid:09699282-bb9a-4f93-90a3-c8ab46874184"
replace id  = "99" if key == "uuid:582e9a89-715b-4c4c-a0df-e6c7240537f4"
replace id  = "99" if key == "uuid:59e46e33-d26b-47f5-85d8-43f3d238c2ac"
replace id  = "98" if key == "uuid:cedf83e9-2107-4365-8159-f2aed9000eea"




/* Export ____________________________________________________________________*/

/* PII */
save "${data}/01_raw_data/03_surveys/pfm_rawpii_ne_baseline.dta", replace

/* No PII */
drop head_name resp_name survey_locationlongitude survey_locationlatitude enumerator_notes resp_phon*
save "${data}/01_raw_data/03_surveys/pfm_rawnopii_ne_baseline.dta", replace

	
	
	

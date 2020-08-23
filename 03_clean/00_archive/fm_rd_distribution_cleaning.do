/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Clean radio distribution (natural experiment) data
	Date: 8/21/2020
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: 	Imports, removes PII, and does some essential preparation of 
				radio randomization importation files
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

clear all	
clear matrix
clear mata
set more off
version 15 
set maxvar 30000


/* Import data _________________________________________________________________*/

use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_ne_radiodistribution_pii.dta", clear


/* Cleaning ____________________________________________________________________*/

/* Basics */
rename SubmissionDate survey_date
rename which_village village_c
rename enum survey_enum_id
rename enumer survey_enum_name
rename q5_house_present survey_anyonepresent


** Option 1: Respondent home
rename hhh_athome_yes resp_present
rename q9_consent resp_consent
rename q12_radio_delivery resp_delivered
rename household_locationLatitude resp_latitude
rename household_locationLongitude resp_longitude

** Option 2: Resondent not home
rename consent_hh alt_consent
rename q6_name alt_name
rename q7_relhouse alt_relation
	lab def house 1	"Head of the household" 2 "Spouse/partner" 3 "Son/Daughter" 7 "Parent"
	lab val alt_relation house 
rename q14_help alt_deliver
	lab def yesno 0 "No" 1 "Yes"
	lab val alt_deliver yesno

** Option 3: No one home (go to neighbor)
rename q15_name_neighbour neighbor_name
rename q16_phone_neighbour neighbor_phone
rename neighbour_locationLatitude neighbor_latitude
rename neighbour_locationLongitude neighbor_longitude

** Pangani
rename q10_panganiFM pfm_yes
replace pfm_yes = panganiFM_test2 if pfm_yes == 2 | pfm_yes == 3 // try moving around house if difficult at first
lab def pfm 1 "Yes, clear" 2 "Yes, but difficult" 3 "Not clear"
lab val pfm_yes pfm


/*______________________________________________________________________________*/

** Export

* Keep
keep survey* village* resp_* alt_* neighbor_* pfm_*

* Export
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_ne_radiodistribution_clean.dta", replace



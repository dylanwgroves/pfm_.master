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

use  "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiodistribution_pii.dta", clear

/* Cleaning ____________________________________________________________________*/

* Geographic Variables
rename village village_id

/* Basics */
rename district district_c
rename ward ward_c
rename submissiondate survey_date
rename enum survey_enum_id
rename q5_house_present survey_anyonepresent


** Option 1: Respondent home
rename hhh_athome_yes resp_present
rename q9_consent resp_consent


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
	replace neighbor_name = q17_name_neighbour2 if neighbor_name == ""
rename q16_phone_neighbour neighbor_phone
	replace neighbor_phone = q18_phone_neighbour2 if neighbor_phone == .
rename neighbour_locationaltitude neighbor_latitude
	replace neighbor_latitude = neighbour2_locationlatitude if neighbor_latitude == . 
rename neighbour_locationlongitude neighbor_longitude
	replace neighbor_longitude = neighbour2_locationlongitude if neighbor_longitude == .

** Pangani
rename panganifm_freq1 pfm_yes
lab def pfm 1 "Yes" 0 "No"
lab val pfm_yes pfm

** Delete duplicate
drop if resp_id == "3-71-1-024" & resp_present == 0 


/*Export ______________________________________________________________________________*/

* Keep
keep survey* village* resp_* alt_* neighbor_* pfm_*

* Export
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_rd_as_clean.dta", replace



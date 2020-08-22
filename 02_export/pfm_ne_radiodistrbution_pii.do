/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Import and prepare radio distribution survey (natural experiment)
	Date: 8/21/2020
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: 	Imports, removes PII, and does some essential preparation of 
				radio randomization importation files
________________________________________________________________________________*/


/*______________________________________________________________________________*/

* Introduciton

clear all	
clear matrix
clear mata
set more off
version 15 
set maxvar 30000




/*______________________________________________________________________________*/

** Import Data

import excel "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis\2 - Final Data\5_Radio Distribution\PanganiFM_II_data.xlsx", sheet("Foglio2") firstrow clear



/*______________________________________________________________________________*/

** Essential Cleaning

rename resp_id respid // respid is the no _ version
tostring respid, replace

/* Fix one duplicate accidentally inputted wrong respid -- see baseline dta file to Marian's correct listing */
replace respid = "14939027" if resp_name == "Marian Shauri"	
replace respid = "14861001" if resp_name == "Amina Mohamed"
replace respid = "15395004" if resp_name == "THABITINA NURU"
replace respid = "15395006" if resp_name == "PENIELI YOHANA"



/*______________________________________________________________________________*/

** Export 

/* PII */
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_ne_radiodistribution_pii.dta", replace

/* Non-PII */
drop resp_name household_* pre_lat pre_long pre_location current_location q6_name

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_ne_radiodistribution_nopii.dta", replace

	

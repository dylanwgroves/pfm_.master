/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Import and prepare radio distribution survey (natural experiment)
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


/* Import Data _________________________________________________________________*/

	import excel "${ipa_ne}/2 - Final Data/5_Radio Distribution/PanganiFM_II_data.xlsx", sheet("Foglio2") firstrow clear


/* Essential Cleaning __________________________________________________________*/

	rename resp_id respid // respid is the version with no "_"
	tostring respid, replace

	/* Fix one duplicate accidentally inputted wrong respid -- see baseline dta file to Marian's correct listing */
	replace respid = "14939027" if resp_name == "Marian Shauri"	
	replace respid = "14861001" if resp_name == "Amina Mohamed"
	replace respid = "15395004" if resp_name == "THABITINA NURU"
	replace respid = "15395006" if resp_name == "PENIELI YOHANA"



/* Export ______________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/pfm_pii_rd_distribution_ne.dta", replace

	/* Non-PII */
	drop resp_name household_* pre_lat pre_long pre_location current_location q6_name
	save "${data}/01_raw_data/pfm_nopii_rd_distribution_ne.dta", replace

	

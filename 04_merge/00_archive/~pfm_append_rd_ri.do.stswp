/*______________________________________________________________________________

	Project: Pangani FM
	File: Appends Audio Screening and Natural Experiment DTA files
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

	clear all
	
/* Locals and Tempfiles ________________________________________________________*/

tempfile temp_ne
tempfile temp_ne_new
tempfile temp_as
tempfile temp_as2_cm
tempfile temp_cm

	
/* Notes _______________________________________________________________________

*/


/* Import Data _________________________________________________________________*/

	use "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Radio Distribution\01 Data/pfm_ri_rd_as.dta", clear
		gen sample = "as"
		save `temp_as', replace

	use "${data}/02_mid_data/pfm_ri_rd_as2_cm.dta", clear
		gen sample = "as2cm"
		save `temp_as2_cm'

	use "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Radio Distribution\01 Data/pfm_ri_rd_ne.dta", clear
		gen sample = "ne"
		save `temp_ne'
		
	
/* Export ______________________________________________________________________*/
	
	use `temp_as'
	qui append using `temp_ne', force
	qui append using `temp_as2_cm', force
		
		
		*replace id_resp_uid = resp_id if missing(id_resp_uid)
		*drop if id_resp_uid == ""
		drop if id_resp_uid == "" 
	
	save "${data}/03_final_data/pfm_rd_ri.dta", replace
	save "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/01 Data/pfm_rd_ri.dta", replace



	



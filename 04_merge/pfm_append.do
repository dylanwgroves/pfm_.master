/*______________________________________________________________________________

	Project: Pangani FM
	File: Appends Audio Screening and Natural Experiment DTA files
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/




/* Introduction _______________________________________________________________*/

	clear all
	
/* Notes _______________________________________________________________________

	THIS IS WHERE NEED TO GO BACK TO MAKE SURE THAT WE ARE NOT APPENDING
	VARIABLES WITH DIFFERENT VALUES TO ONE ANOTHER , WHICH COULD FUCK UP 
	THE LABELLING AND/OR VALUES

*/


/* Import Data ________________________________________________________________*/

	use "${data}/03_final_data/pfm_ne_merged.dta", clear
	append using "${data}/03_final_data/pfm_as_merged.dta"
		
/* Save ______________________________________________________________________*/

	save "${data}/03_final_data/pfm_appended.dta", replace




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
tempfile temp_as


	
/* Notes _______________________________________________________________________

	THIS IS WHERE NEED TO GO BACK TO MAKE SURE THAT WE ARE NOT APPENDING
	VARIABLES WITH DIFFERENT VALUES TO ONE ANOTHER , WHICH COULD FUCK UP 
	THE LABELLING AND/OR VALUES

*/


/* Import Data _________________________________________________________________*/

	use "${data}/03_final_data/pfm_ne_merged.dta", clear
		rename ne_rd_treat_* rd_treat_*
		save `temp_ne', replace

	use "${data}/03_final_data/pfm_as_merged.dta", clear
		rename as_rd_treat_* rd_treat_*
		save `temp_as'
		

/* Export with Prefix __________________________________________________________

	This is useful when we want to easy select only variables asked in one of the
	surveys. 
	
*/
	stop
	use `temp_as'
	qui append using `temp_ne', force
	save "${data}/03_final_data/pfm_appended_prefix.dta", replace

	
/* Export without Prefixes _____________________________________________________

	This is iseful when we want to combien surveys for some reason
	
*/

	use `temp_ne', clear
		rename ne_* *
		save `temp_ne', replace

	use `temp_as', clear
		rename as_* *
		rename treat treat_as
		save `temp_as', replace

	append using `temp_ne', force
	save "${data}/03_final_data/pfm_appended_noprefix.dta", replace

	



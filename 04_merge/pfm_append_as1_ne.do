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
tempfile temp_as2
tempfile temp_cm

	
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
		rename as_treat   as_treat_as
		rename as_treat_* as_treat_as_*
		save `temp_as'

	use "${data}/03_final_data/pfm_as2_merged.dta", clear
		*rename as2_rd_treat_* rd_treat_*
		save `temp_as2'
		

/* Export with Prefix __________________________________________________________

	This is useful when we want to easy select only variables asked in one of the
	surveys. 
	
*/
	use `temp_as'
	qui append using `temp_ne', force
	qui append using `temp_as2', force
	save "${data}/03_final_data/pfm_appended_prefix.dta", replace

	
/* Export Each AS Dataset Independently ________________________________________

	This is useful so we can pull in different datasets
	
*/

	use `temp_ne', clear
		rename ne_* *
		save `temp_ne_new', replace

	use `temp_as', clear
		rename as_* *

	use `temp_as2', clear
		rename as2_* *
		rename as2_treat as2_treat_as2
		rename as2_treat_* as2_treat_as2_*

	append using `temp_ne_new', force
	save "${data}/03_final_data/pfm_appended_noprefix.dta", replace


	
/* Export without Prefixes _____________________________________________________

	This is useful when we want to combine surveys for some reason
	
*/

	use `temp_ne', clear
		rename ne_* *
		save `temp_ne_new', replace

	use `temp_as', clear
		rename as_* *
		rename treat treat_as
		gen survey = "as"

	append using `temp_ne_new', force
		replace survey = "ne" if survey != "as"
	save "${data}/03_final_data/pfm_appended_noprefix.dta", replace

	



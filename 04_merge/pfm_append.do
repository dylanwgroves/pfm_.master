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
	use `temp_as'
	qui append using `temp_ne', force
	save "${data}/03_final_data/pfm_appended_prefix.dta", replace

	
/* Export Each AS Dataset Independently ________________________________________

	This is useful so we can pull in different datasets
	
*/

	use `temp_ne', clear
		rename ne_* *
		save `temp_ne_new', replace

	use `temp_as', clear
		rename as_* *
		rename treat treat_as

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

	append using `temp_ne_new', force
	save "${data}/03_final_data/pfm_appended_noprefix.dta", replace

	



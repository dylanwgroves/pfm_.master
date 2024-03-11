/*______________________________________________________________________________

	Project: Pangani FM
	File: Appends Audio Screening and Natural Experiment DTA files
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


*set maxvar 32767 , perm

/* Introduction _______________________________________________________________*/

	clear all
	
/* Locals and Tempfiles ________________________________________________________*/

tempfile temp_as
tempfile temp_as2
tempfile temp_as_noprefix
tempfile temp_as2_noprefix

	
/* Notes _______________________________________________________________________

	THIS IS WHERE NEED TO GO BACK TO MAKE SURE THAT WE ARE NOT APPENDING
	VARIABLES WITH DIFFERENT VALUES TO ONE ANOTHER , WHICH COULD FUCK UP 
	THE LABELLING AND/OR VALUES

*/


/* Import Data _________________________________________________________________*/

	use "${data}/03_final_data/pfm_as_merged.dta", clear
		drop as_rd_treat_* 
		drop as_treat_*
		rename as_rd_treat   rd_treat
		drop *_cases_*
		drop *_section_*
		save `temp_as'

	use "${data}/03_final_data/pfm_as2_merged.dta", clear
		drop *_sect_*
		save `temp_as2'
		

/* Export with Prefix __________________________________________________________

	This is useful when we want to easy select only variables asked in one of the
	surveys. 
	
*/
	use `temp_as'
	qui append using `temp_as2', force
	save "${user}/Dropbox/Socialization/01_data/pfm_as_as2_appended_prefix.dta", replace


	
/* Export without Prefixes _____________________________________________________

	This is useful when we want to combine surveys 
	
*/

	use `temp_as', clear
		rename as_* *
		rename treat treat_as
		gen survey = "as1"
		save `temp_as_noprefix'
		
	use `temp_as2'
		rename as2_* *
		rename treat treat_as2
		gen survey = "as2" 	
		save `temp_as2_noprefix'
	
	use`temp_as_noprefix'
	qui append using `temp_as2_noprefix', force

	save "${user}/Dropbox/Socialization/01_data/pfm_as_as2_appended_noprefix.dta", replace

	



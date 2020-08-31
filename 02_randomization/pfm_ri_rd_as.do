
/* _____________________________________________________________________________

Project: Pangani FM 2
File: Radio Distribution Randomization Inference (AS)
Date: 8/22/2020
Author: Dylan Groves, dgroves@poverty-action.org
verview: This imports radio distribution randomization file

________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

clear all
set maxvar 30000
set more off

/* Globals and Temps ___________________________________________________________*/

global first 1
tempfile master


/* Import ______________________________________________________________________*/

use "${data}/02_mid_data/pfm_rd_randomization_as.dta", clear
keep resp_id resp_name ward_name village_id ward_code s2q1_gender rd_block rd_treat


/* Import ______________________________________________________________________*/

lab def treat 0 "Control" 1 "Treat"

forvalues x = 1/100 {

	* Set seed
	set seed `x'
	
	* Random Number
	gen radiorandomization_resprandom = runiform()
	gen radiorandomization_resprandom_2 = runiform()
	
	* Assign Treatment
	bys rd_block : egen radiorandomization_treatmed = median(radiorandomization_resprandom)
	bys rd_block : egen radioradnomization_treatmed_2 = median(radiorandomization_resprandom_2)
	
	gen rd_treat_`x' = 1 if 	(radiorandomization_resprandom > radiorandomization_treatmed) | ///
								(radiorandomization_resprandom == radiorandomization_treatmed & ///											
								radiorandomization_resprandom_2 > radioradnomization_treatmed_2)
											
	replace rd_treat_`x' = 0 if (radiorandomization_resprandom < radiorandomization_treatmed) | ///
								(radiorandomization_resprandom == radiorandomization_treatmed & ///
								radiorandomization_resprandom_2 < radioradnomization_treatmed_2)
	
	lab var rd_treat_`x' "RI Treat Assignment `x'"
	lab val rd_treat_`x' treat
	
	* Drop Variables
	drop radiorandomization_treatmed
	drop radioradnomization_treatmed_2
	drop radiorandomization_resprandom
	drop radiorandomization_resprandom_2
}




/* Export _______________________________________________________________________*/

save "${data}/02_mid_data/pfm_rd_ri_as.dta", replace



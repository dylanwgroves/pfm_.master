/*______________________________________________________________________________
	
	
	Purpose: Set globals for Pangani FM project
			 
	Stata version: 15
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19
 											
______________________________________________________________________________*/


/* Stata Prep ___________________________________________________________________*/

version 15 
clear all 
clear matrix
clear mata
set more off 
set maxvar 30000
 
 
/* Part 1: Set Globals _________________________________________________________*/

/* Dylan */ 
if "`c(username)'" == "dylan" {
	
	/* Maine */
	global code "X:\Documents/pfm_.master"
	global data "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data"
	
	/* Output */
	global output "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\02_outputs"
	global output_final "X:\Dropbox/Apps/Overleaf"
	
	/* IPA source files */
	global ipa_ne "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis"
	global ipa_as "X:\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data"
	global ipa_endline "X:\Box Sync\19_Community Media Endlines"
	
}

/* Bea 
if "`c(username)'" == "Bea"														// Bea to fill in
*/


/* Set Date _____________________________________________________________________*/

global date : di %tdDNCY daily("$S_DATE", "DMY")


/* Indicate Globals Set _________________________________________________________*/

global globals_set "yes"


di "${code}"
di "${data}"


/* Indicate Globals Set _________________________________________________________*/

set seed 1956


/* Page 2: Run Programs ________________________________________________________

do "${code}/02_code/pfm_programs.do"

*/
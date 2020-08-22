/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Merge Audio Screening dta and Radio Randomization dta
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: Merges audio screening baseline/midline and radio randomization
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Temfiles __________________________________________________________________*/

tempfile baseline
tempfile randomization
	

/* Import Data ________________________________________________________________*/

/* Load Radio Distribution Randomized */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_ne_radiorandomization_pii.dta"
sort respid
save `randomization'


/* Load Radio Distribution */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_rd_ne_clean.dta", clear
sort respid



/* Merge ______________________________________________________________________*/

merge 1:1 respid using `randomization', force gen(merge_rd_rdrandom)
drop if merge_rd_rdrandom == 1															// This is a blank row
order respid resp_name district_n ward_n village_n merge_rd_rdrandom


/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_merge_ne_rd_rdrandom.dta", replace

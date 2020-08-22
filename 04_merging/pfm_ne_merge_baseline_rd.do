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
tempfile randomizationcheck
	

/* Import Data ________________________________________________________________*/

/* Load Baseline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_ne_baseline_clean.dta", clear
sort resp_id
save `baseline', replace


/* Load Radio Distribution and RD Randomized */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_merge_ne_rd_rdrandom.dta", clear
sort  resp_id


/* Merge ______________________________________________________________________*/

merge 1:1 resp_id using `baseline', force gen(ne_base_rd)
order resp_id resp_name district_n ward_n village_n ne_base_rd


/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_merge_ne_base_rd.dta", replace

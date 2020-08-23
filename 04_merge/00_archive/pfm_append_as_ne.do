/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Append Audio Screening and Natural Experiment
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This appends audio screening baseline/midline and natural experiment baseline
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

clear all
set maxvar 30000
set more off

/* Temfiles __________________________________________________________________*/
tempfile temp_audioscreening
tempfil temp_naturalexperiment


/* Import Data ________________________________________________________________*/

/* Load Audio Screening */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_basemid.dta", clear
sort resp_id 
save `temp_audioscreening', replace

/* Load Midline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_ne_baseline_clean.dta"
sort  resp_id


/* Merge ______________________________________________________________________*/

append using `temp_audioscreening'
order resp_id resp_name district_name ward_name village_name


/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_basemid.dta", replace

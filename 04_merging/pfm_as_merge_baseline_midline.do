/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Merge Audio Screening Baseline and Midline
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This imports piloting data
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

clear all
set maxvar 30000
set more off

/* Temfiles __________________________________________________________________*/
tempfile baseline


/* Import Data ________________________________________________________________*/

/* Load Baseline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_baseline_clean.dta", clear
sort resp_id 
save `baseline', replace

/* Load Midline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\pfm_as_midline_clean.dta"
sort  resp_id


/* Merge ______________________________________________________________________*/

merge 1:1 resp_id using `baseline', force
rename _merge merge_as_basemid
order resp_id resp_name district_name ward_name village_name merge_as_basemid
*keep resp_id resp_name district_name ward_name village_name _merge


/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_basemid.dta", replace

/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Merge Audio Screening DTA and Radio Randomization DTA
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: Merges audio screening baseline/midline and radio randomization
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

clear all
set maxvar 30000
set more off

/* Temfiles __________________________________________________________________*/
tempfile basemid


/* Import Data ________________________________________________________________*/

/* Load Baseline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_basemid.dta", clear
sort resp_id 
save `basemid', replace

/* Load Radio Distribution Randomized */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\pfm_radiodistribution_ra_clean.dta"
sort  resp_id


/* Merge ______________________________________________________________________*/

merge 1:1 resp_id using `basemid', force gen(base_mid_radio)
order resp_id resp_name district_name ward_name village_name base_mid_radio


/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_base_mid_radio.dta", replace

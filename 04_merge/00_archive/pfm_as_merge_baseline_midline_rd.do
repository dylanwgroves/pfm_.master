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

tempfile basemid
tempfile rdrandom
	

/* Import Data ________________________________________________________________*/

/* Load Baseline/Midline */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_baseline_midline.dta", clear
sort resp_id
tab resp_id
save `basemid', replace

/* Load Radio Randomization Data */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiorandomization_pii.dta", clear
stop
sort resp_id
tab resp_id
duplicates drop resp_id, force													// Accidentally ran randomization twice for two villages, these are exact duplicates
save `rdrandom'

/* Load Radio Distribution Data */
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_rd_as_clean.dta", clear
sort resp_id





/* Merge ______________________________________________________________________*/

merge 1:1 resp_id using `rdrandom', force gen(rd_rdrandom)

stop

merge 1:1 resp_id using `basemid', force gen(base_mid_rd_rdrandom)

order resp_id resp_name district_n ward_n village_n base_mid_radio

stop

stop
/* Save ______________________________________________________________________*/

save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_merged_base_mid_radio.dta", replace

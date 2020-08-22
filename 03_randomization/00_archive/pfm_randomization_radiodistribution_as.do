/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Append Audio Screening and Natural Experiment
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: 	This loads anonymized audio screening baselie and randomizes
				assignment to radio distribution
_______________________________________________________________________________*/


/* Introduction _______________________________________________________________*/

clear all
set maxvar 30000
set more off
version 15


/* Load Data __________________________________________________________________*/

use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiodistribution_nopii.dta", clear


/* Randomize within villages ___________________________________________________*/

	/* Take Levels */

	levelsof s1q5_village
	local radran_village = r(levels)

	/* Set global */
	global i = 1

	/* Loop through villageses */
	foreach vill of local radran_village {

	* Preserve 
	preserve

	* Sub-Select Villages 
	keep if village_id == "`vill'"

	* Keep if would accept radio if given
	keep if s12q3_radio_wouldlisten == 1

	local vill_str = village_id
	local vill_num = vill_num

	gl village "`vill_str'"
	set seed `vill_num'
	tempfile `vill_num'

	* Do Principal Components Analysis 
	pca s6q*
	predict pca1, score

	* Generate Random Numbers 
	gen radiorandomization_villrandom = runiform()
	bysort s1q5_village: replace radiorandomization_villrandom = radiorandomization_villrandom[1]
	gen radiorandomization_resprandom = runiform()

	* Generate Matched Pairs 
	gsort s2q1_gender -pca1 radiorandomization_resprandom
	by s2q1_gender: gen radiorandomization_pairnum = round(_n/2, 1), 
	by s2q1_gender: replace radiorandomization_pairnum = round(_n/2, 1) if mod(_n, 2) == 0
	gen gender_string = "m" if s2q1_gender == 1
	replace gender_string = "f" if s2q1_gender == 2
	egen radiorandomization_pair = concat(radiorandomization_pairnum gender_string), punct("_")

	* Assign Treatment using within-pair randomization 
	egen radiorandomization_treatmed = median(radiorandomization_resprandom), by(radiorandomization_pair)
	gen radiorandomization_treat = "Treat" if radiorandomization_resprandom > radiorandomization_treatmed
	replace radiorandomization_treat = "Control" if radiorandomization_resprandom < radiorandomization_treatmed // Guaruntees that non-paired people will not be selected

	* T-Tests 
	ttest s2q1_gender, by(radiorandomization_treat)
	ttest s12q5, by(radiorandomization_treat)
	ttest s6q3_gh_earn, by(radiorandomization_treat)

	* Sort, Order, and Select Variables 
	sort radiorandomization_pair s2q1_gender radiorandomization_treat pca1 
	order district_code district_name ward_code ward_name village_code village_name village_name resp_id s1q5_village s2q1_gender radiorandomization_treat radiorandomization_pair pca1 village_id
	keep district_code district_name ward_code ward_name village_code village_name resp_id s2q1_gender pca1 radiorandomization_treat radiorandomization_pair village_id pca1

	* Append 
	if  ${i} == 1 {
		save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_radiodistribution_randomization_mid.dta", replace
	}

	if ${i} > 1 {
		append using "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_radiodistribution_randomization_mid.dta"
		save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_radiodistribution_randomization_mid.dta", replace
	}

	* Restore
	restore

	global i = ${i} + 1
	}


/* Export ______________________________________________________________________*/

* Load Data
use "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_radiodistribution_randomization_mid.dta", clear

* Rename and Keep variables
rename pca1 radiorandomization_pca1
rename s2q1_gender radiorandomization_gender
keep village_id resp_id radiorandomization_treat radiorandomization_pair radiorandomization_pca1 radiorandomization_gender
sort resp_id

* Save
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\pfm_as_radiodistribution_randomization.dta", replace




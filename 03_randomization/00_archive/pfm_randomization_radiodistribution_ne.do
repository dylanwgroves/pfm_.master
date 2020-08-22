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

use "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/01_sample/pfm_ne_radiodistribution_nopii.dta", clear


/* Randomize within villages ___________________________________________________*/

	/* Sort */
	sort survey_villageid pca1 survey_uniqueid
	
	/* Generate Random Numbers */
	gen radiorandomization_resprandom = runiform()

	* Generate Matched Pairs 
	gsort survey_villageid -pca1 radiorandomization_resprandom
	bys survey_villageid: gen radiorandomization_pairnum = round(_n/2, 1), 
	bys survey_villageid: replace radiorandomization_pairnum = round(_n/2, 1) if mod(_n, 2) == 0
	egen radiorandomization_pair = concat(radiorandomization_pairnum survey_villageid), punct("_")

	* Assign Treatment using within-pair randomization 
	egen radiorandomization_treatmed = median(radiorandomization_resprandom), by(radiorandomization_pair)
	gen radiorandomization_treat = "Treat" if radiorandomization_resprandom > radiorandomization_treatmed
	replace radiorandomization_treat = "Control" if radiorandomization_resprandom < radiorandomization_treatmed // Guaruntees that non-paired people will not be selected

	* T-Tests 
	ttest pca1, by(radiorandomization_treat)

	* Sort, Order, and Select Variables 
	sort survey_villageid radiorandomization_pair radiorandomization_treat pca1 
	order survey_uniqueid survey_villageid radiorandomization_pair radiorandomization_treat pca1 


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




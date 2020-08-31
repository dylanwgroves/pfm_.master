*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: Radio Distribution Randomization (AS)
* Date: 8/22/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports radio distribution randomization file
*-------------------------------------------------------------------------------

/* Introduction ___________________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Import Data ___________________________________________________________________*/

import delimited "${ipa_as}\05_data\09_radio_distribution\05_Radio_Survey\panganifm2_radiodistribution_master.csv", encoding(ISO-8859-9) clear 

/* Data Cleaning ___________________________________________________________________*/

* Geographic Variables
rename *_code *_c
rename *_name *_n

* Respondent variables
rename s2q1_gender resp_gender
rename radiorandomization_treat treat_rd
lab var treat_rd "Radio Randomization Treatment"

/* Export _____________________________________________________________________*/

/* PII */
save "${data}/01_raw_data/01_sample/pfm_as_radiodistribution_pii.dta", replace

/* No PII */
drop resp_n cases_phone1 cases_phone2 cases_*
save "${data}/01_raw_data/01_sample/pfm_as_radiodistribution_nopii.dta", replace






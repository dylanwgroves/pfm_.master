*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: Baseline Pilot Import and Cleaning
* Date: 7/5/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports piloting data
*-------------------------------------------------------------------------------

/* Introduction ___________________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Import Data ___________________________________________________________________*/

import delimited "X:\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data\05_data\09_radio_distribution\05_Radio_Survey\panganifm2_radiodistribution_master.csv", encoding(ISO-8859-9) clear 
stop
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
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiorandomization_pii.dta", replace

/* No PII */
drop resp_n cases_phone1 cases_phone2 cases_*
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiorandomization_nopii.dta", replace






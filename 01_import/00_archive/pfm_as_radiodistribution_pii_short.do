/*______________________________________________________________________________
* Project: Pangani FM 2
* File: Baseline Pilot Import and Cleaning
* Date: 7/5/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports piloting data
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

clear all
set maxvar 30000
set more off


/* Import Data _________________________________________________________________*/

import delimited "X:\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data\05_data\09_radio_distribution\01_raw\PanganiFM2_Radio_Survey_WIDE.csv", clear 


/* Export ______________________________________________________________________*/

/* PII */
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiodistribution_pii.dta", replace

/* No PII */
drop resp_n q6_n q15_name_neighbour q17_name_neighbour2 q16_phone_neighbour q18_phone_neighbour2 neighbour2_locationlongitude neighbour_locationlatitude neighbour2_locationlatitude
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\01_sample\pfm_as_radiodistribution_nopii.dta", replace






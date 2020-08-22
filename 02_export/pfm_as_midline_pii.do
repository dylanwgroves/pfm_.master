*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: FollowUp Pilot Import and Cleaning
* Date: 8/7/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This cleans data for high frequency checks on the follow up data
*-------------------------------------------------------------------------------


** NOTES
** Need to drop dates from piloting

* Introduction -----------------------------------------------------------------
clear all
set maxvar 30000
set more off
set seed 1956

* Set Global -------------------------------------------------------------------
global pfm2 "X:\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data"

* Import Data ------------------------------------------------------------------
use "$pfm2/05_data/04_precheck/panganifm2_Followup_clean", clear

/* drop PII variables ----------------------------------------------------------*/
drop head_name resp_name cases_label pre_label pre_phone* pre_phone2 ///
		pre_resp_name pre_hhh_name

/* export ----------------------------------------------------------------------*/
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_as_midline_nopii.dta", replace



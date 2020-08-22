/* background -----------------------------------------------------------------
Project: Wellspring Tanzania, Audio Screening
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
*/


* introduction -----------------------------------------------------------------
clear all
set maxvar 30000
set more off

* Import Data ------------------------------------------------------------------
use "X:/Box Sync/17_PanganiFM_2/07&08 Questionnaires & Data/03 Baseline/04_Data Quantitative/02 Main Survey Data/05_data/04_precheck/panganifm2_baseline_clean", clear


/* drop PII variables ----------------------------------------------------------*/
drop head_name resp_name survey_locationlongitude survey_locationlatitude

/* export ----------------------------------------------------------------------*/
save "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\01_raw_data\03_surveys\pfm_as_baseline_nopii.dta", replace


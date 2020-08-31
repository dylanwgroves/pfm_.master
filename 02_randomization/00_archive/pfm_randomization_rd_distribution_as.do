*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: Baseline Pilot Import and Cleaning
* Date: 7/5/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This imports piloting data
*-------------------------------------------------------------------------------

********************************************************************************
* ONLY RUN WHEN ALL SURVEYS IN THE VILLAGE ARE COMPLETE
********************************************************************************

* Introduction -----------------------------------------------------------------
clear all
set maxvar 30000
set more off

* SET PREFERENCES --------------------------------------------------------------
*local radran_dist_ward "3_191"
global first "1"

* Set Global -------------------------------------------------------------------
global pfm2 "X:\Box Sync\17_PanganiFM_2/07&08 Questionnaires & Data/03 Baseline/04_Data Quantitative/02 Main Survey Data"

* Import Data ---------------------------- --------------------------------------
use "$pfm2/05_data/04_precheck/panganifm2_baseline_clean.dta", clear

* Geographic Variables
rename s1q3 s1q3_district
rename s1q4 s1q4_ward
egen dist_ward = concat(s1q3_district s1q4_ward), punct("_")
rename s1q5 s1q5_village
rename s2q1 s2q1_gender 

* Cleaning
replace ward_name = "Kabuku ndani" if s1q4_ward == "191"
replace district_name = "Handeni" if s1q3_district == "6"

* Radio Ownership - Would Receive
rename s12q3 s12q3_radio_wouldlisten											

* Prepare dataset for principal components analysis ----------------------------	
rename s6q1 s6q1_gh_eqkid 
recode s6q1_gh_eqkid (0 = 1) ///
					 (1 = 0)
lab var s6q1_gh_eqkid "6.1 [REVERSED] 6.1)  A husband and wife should both participate equally in raising children."

rename s6q2 s6q2_gh_marry
rename s6q3 s6q3_gh_earn 
rename s6q4 s6q4_gh_lead
recode s6q4_gh_lead (0 = 1) ///
					(1 = 0)
lab var s6q4_gh_lead "[REVERSED] 6.4) Do you trust a woman leader to bring development to the community?"

rename s6q5 s6q5_gh_numkidpref
rename s6q6 s6q6_gh_kidgenderpref
													// This needs to get renumbered
recode s6q6_gh_kidgenderpref (1 = 1) (2 = 0) (3 = 0) (4 = 1) (5 = 0) (6 = 0), gen(s6q6_gh_prefboy)
lab def moreboy 1 "More boys than girls" 0 "As many girls as boys" -999 "Don't Know" -888 "Refuse" 
lab val s6q6_gh_prefboy moreboy 
lab var s6q6_gh_prefboy "[As many girls as boys] 6.5) Ideally, what proportion of them would you like to be boys?"

* Drop variables that won't fit PCA
drop s6q5_gh_numkidpref
drop s6q6_gh_kidgenderpref

*Generate variables to be used in CSV file.
gen district_code=district_c_pull
gen ward_code=ward_c_pull
gen village_code=village_c_pull

* Get rid of missing
foreach var of varlist s6q* {
	replace `var' = 0 if `var' == -999 | `var' == -888
}

* Select Ward ------------------------------------------------------------------
*keep if dist_ward == "`radran_dist_ward'"

qui levelsof s1q5_village
local radran_village = r(levels)

* Run randomization within each village
foreach vill of local radran_village {

* Preserve ---------------------------------------------------------------------
preserve

* Sub-Select Villages ----------------------------------------------------------
keep if village_id == "`vill'"

* Keep if would listen
keep if s12q3_radio_wouldlisten == 1

local vill_str = village_id
local vill_num = vill_num

gl village "`vill_str'"
set seed `vill_num'
tempfile `vill_num'

* Do Principal Components Analysis ---------------------------------------------
pca s6q*
predict pca1, score

* Generate Random Numbers ------------------------------------------------------
gen radiorandomization_villrandom = runiform()
bysort s1q5_village: replace radiorandomization_villrandom = radiorandomization_villrandom[1]
gen radiorandomization_resprandom = runiform()

* Generate Matched Pairs -------------------------------------------------------
gsort s2q1_gender -pca1 radiorandomization_resprandom
by s2q1_gender: gen radiorandomization_pairnum = round(_n/2, 1), 
by s2q1_gender: replace radiorandomization_pairnum = round(_n/2, 1) if mod(_n, 2) == 0
gen gender_string = "m" if s2q1_gender == 1
replace gender_string = "f" if s2q1_gender == 2
egen radiorandomization_pair = concat(radiorandomization_pairnum gender_string), punct("_")

* Assign Treatment using within-pair randomization -----------------------------
egen radiorandomization_treatmed = median(radiorandomization_resprandom), by(radiorandomization_pair)
gen radiorandomization_treat = "Treat" if radiorandomization_resprandom > radiorandomization_treatmed
replace radiorandomization_treat = "Control" if radiorandomization_resprandom < radiorandomization_treatmed // Guaruntees that non-paired people will not be selected

* T-Tests ----------------------------------------------------------------------
ttest s2q1_gender, by(radiorandomization_treat)
ttest s12q5, by(radiorandomization_treat)
ttest s6q3_gh_earn, by(radiorandomization_treat)

* Sort, Order, and Select Variables --------------------------------------------
sort radiorandomization_pair s2q1_gender radiorandomization_treat pca1 
order district_code district_name ward_code ward_name village_code village_name village_name resp_name resp_id s1q5_village s2q1_gender radiorandomization_treat radiorandomization_pair pca1 village_id
keep  district_code district_name ward_code ward_name village_code village_name resp_name resp_id s1q5_village s2q1_gender radiorandomization_treat radiorandomization_pair cases_phone1 cases_phone2 cases_hhh_name cases_hhh_phone village_id

* Export -----------------------------------------------------------------------
export excel "$pfm2/04_checks/02_outputs/panganifm2_radiodistribution_`radran_dist_ward'.xlsx", firstrow(variables) sheet(`vill_str', replace)

*keep if radiorandomization_treat == "Treat"
keep district_code district_name ward_code ward_name village_code village_name resp_name resp_id s2q1_gender cases_phone1 cases_phone2 cases_hhh_name cases_hhh_phone radiorandomization_treat radiorandomization_pair village_id

if  "$village" == "6-191-3" {
	save "$pfm2/04_checks/02_outputs/panganifm2_radiodistribution_master.dta", replace
}

if "$village" != "6-191-3" {
	append using "$pfm2/04_checks/02_outputs/panganifm2_radiodistribution_master.dta"
	save "$pfm2/04_checks/02_outputs/panganifm2_radiodistribution_master.dta", replace
}

* Restore ----------------------------------------------------------------------
restore
}

* Export Master to Excel
use "$pfm2/04_checks/02_outputs/DG_panganifm2_radiodistribution_master.dta", clear
duplicates drop district_name ward_name village_name resp_name, force
sort district_name ward_name village_name

*export excel "$pfm2/04_checks/02_outputs/panganifm2_radiodistribution_master.xlsx", firstrow(variables) replace


/* _____________________________________________________________________________

Project: Pangani FM 2
File: Radio Distribution Randomization (AS)
Date: 8/22/2020
Author: Dylan Groves, dgroves@poverty-action.org
verview: This imports radio distribution randomization file

________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

clear all
set maxvar 30000
set more off

/* Globals and Temps ___________________________________________________________*/

global first 1
tempfile master

set seed 1956

/* Import ______________________________________________________________________*/

use "${data}/01_raw_data/03_surveys/pfm_pii_as_baseline.dta", clear

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
*keep if s1q5_village == "3-181-4"
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

	if "`vill'" == "3-181-4" {
		sort vill_num resp_id
		local vill_num = 31814
	}

	if "`vill'" == "3-191-4" {
		sort vill_num resp_id
		local vill_num = 31914
	}

	gl village "`vill_str'"
	set seed `vill_num'	
	tempfile `vill_num'

* Do Principal Components Analysis ---------------------------------------------
	qui pca s6q*
	qui predict pca1, score

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

* Sort, Order, and Select Variables --------------------------------------------
	sort radiorandomization_pair s2q1_gender radiorandomization_treat pca1 
	order district_code district_name ward_code ward_name village_code village_name village_name resp_name resp_id s1q5_village s2q1_gender radiorandomization_treat radiorandomization_pair pca1 village_id 
	keep  district_code district_name ward_code ward_name village_code village_name resp_name resp_id resp_name s1q5_village s2q1_gender radiorandomization_resprandom radiorandomization_treat radiorandomization_pair cases_phone1 cases_phone2 vill_num  cases_hhh_name cases_hhh_phone village_id pca1

* Save and Append --------------------------------------------------------------
	if  ${first} == 1 {
		save "${data}/02_mid_data/pfm_rd_randomization_mid.dta", replace
	}

	if  ${first} != 1 {
		append using "${data}/02_mid_data/pfm_rd_randomization_mid.dta"
		save "${data}/02_mid_data/pfm_rd_randomization_mid.dta", replace
		
		sleep 300
	}

* Restore ----------------------------------------------------------------------
	restore
	global first = ${first} + 1
	}


/* Export ______________________________________________________________________*/
	
	use "${data}/02_mid_data/pfm_rd_randomization_mid.dta", clear
	duplicates drop district_name ward_name village_name resp_name, force

	* Rename district code stuff for merging
	*rename *_code *_c
	rename radiorandomization_treat rd_treat


/* Fix _________________________________________________________________________*/

/* 
Two villages had randomizations conducted on-site by the field facilitator because
new respondents were added to the list on the day of distribution. This followed
the same matched-pair coinflip randomization as described above. 
*/

	replace rd_treat = "Treat" if resp_id == "3-181-4-0097"
	replace rd_treat = "Control" if resp_id == "3-181-4-0072"
	replace radiorandomization_pair = "2_f" if resp_id == "3-181-4-132"
	replace rd_treat = "Treat" if resp_id == "3-181-4-132"
	replace radiorandomization_pair = "1_f" if resp_id == "3-181-4-0067"
	replace rd_treat = "Control" if resp_id == "3-181-4-0067"
	replace rd_treat = "Treat" if resp_id == "3-181-4-119"
	replace rd_treat = "Control" if resp_id == "3-181-4-138"
	replace radiorandomization_pair = "6_f" if resp_id == "3-181-4-012"
	replace rd_treat = "Treat" if resp_id == "3-181-4-012"
	replace radiorandomization_pair = "4_f" if resp_id == "3-181-4-022"
	replace rd_treat = "Control" if resp_id == "3-181-4-022"
	replace rd_treat = "Treat" if resp_id == "3-191-4-133"
	replace rd_treat = "Control" if resp_id == "3-191-4-0044"
	replace rd_treat = "Treat" if resp_id == "3-191-4-178"
	replace rd_treat = "Control" if resp_id == "3-191-4-181"
	replace rd_treat = "Control" if resp_id == "3-191-4-093"
	replace rd_treat = "Treat" if resp_id == "3-191-4-089"
	replace rd_treat = "Treat" if resp_id == "3-191-4-204"
	replace rd_treat = "Control" if resp_id == "3-191-4-140"
	replace rd_treat = "Treat" if resp_id == "3-191-4-177"
	replace rd_treat = "Control" if resp_id == "3-191-4-125"
	replace rd_treat = "Treat" if resp_id == "3-191-4-183"
	replace rd_treat = "Control" if resp_id == "3-191-4-195"
	replace rd_treat = "Treat" if resp_id == "3-191-4-130"
	replace rd_treat = "Control" if resp_id == "3-191-4-132"
	replace rd_treat = "Control" if resp_id == "3-181-4-082"

/* Create Unique _______________________________________________________________*/

	egen rd_block = concat(village_id radiorandomization_pair), punct(_)
	order resp_id rd_block rd_treat pca1 radiorandomization_resprandom village_id
	sort district_c* ward_c* village_id s2q1_gender rd_block rd_treat

/* Encode rd_treat _____________________________________________________________*/

rename rd_treat rd_treat_str
	gen rd_treat = 1 if rd_treat_str == "Treat"
	replace rd_treat = 0 if rd_treat_str == "Control"
	
/* Export ______________________________________________________________________*/

save "${data}/02_mid_data/pfm_rd_randomization_as.dta", replace



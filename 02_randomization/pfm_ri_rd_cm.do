
/* Basics ______________________________________________________________________

	Project: Radio Distribtuion, Community Media
	Purpose: RI Radio Randomization
	Author: dylan w groves, dylanwgroves@gmail.com
	Date: 2023.10.28
________________________________________________________________________________*/


 use "${data}/01_raw_data/03_surveys/pfm_nopii_cm_3_2023.dta", clear 

 * quick clean 
replace id_village_code = "5_51_2" if id_village_code == "5_52_2"
	rename id_village_code id_village_uid 
	
gen rd_treat = 1 if treat_rd_pull == "Radio"
replace rd_treat = 0 if treat_rd_pull == "Flashlight"

drop if rd_treat == . 
	
	* Set seed
	isid resp_id, sort
	
forval i = 1/5000 {
	
	set seed 1956		

	* Decide which villages get extras if there are a tie --------------------------
	bys id_village_uid: gen rand_vill = runiform()
	bysort id_village_uid: replace rand_vill = rand_vill[1]				
	gen vill_extra = (rand_vill > 0.5)

	* Individual level randomization -----------------------------------------------

	* Generate Random Numbers ------------------------------------------------------
	sort resp_id
	gen rand_resp = runiform()														

	* Assign Treatment using within-pair randomization -----------------------------
	bysort id_village_uid: egen rand_resp_median = median(rand_resp)
	*bys id_village_uid: egen radio_rank = rank(rand_resp)

	gen rd_treat_`i' = .
	replace rd_treat_`i' =1 if rand_resp <= rand_resp_median & vill_extra == 1
	replace rd_treat_`i'=1 if rand_resp < rand_resp_median & vill_extra == 0
	replace rd_treat_`i'=0 if rd_treat_`i'==.
	
	drop rand_vill vill_extra rand_resp rand_resp_median 

}

	 
	keep id_village_uid resp_id rd_treat_* 
	
	save "${data}/02_mid_data/pfm_ri_rd_cm.dta"

/* Basics ______________________________________________________________________

	Project: Radio Distribtuion, AS2
	Purpose: RI Radio Randomization
	Author: dylan w groves, dylanwgroves@gmail.com
	Date: 2023.10.28
________________________________________________________________________________*/


* load data 
use "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Radio Distribution\01 Data/pfm_rd_analysis.dta", clear 

	keep if sample == "as2" | sample == "cm"
	
forval i = 1/5000 {
	
	set seed `i'	

	* Decide which villages get extras if there are a tie --------------------------
	qui bys id_village_uid: gen rand_vill = runiform()
	qui bysort id_village_uid: replace rand_vill = rand_vill[1]				
	qui gen vill_extra = (rand_vill > 0.5)

	* Individual level randomization -----------------------------------------------

	* Generate Random Numbers ------------------------------------------------------
	sort id_resp_uid
	qui gen rand_resp = runiform()														

	* Assign Treatment using within-pair randomization -----------------------------
	qui bysort id_village_uid: egen rand_resp_median = median(rand_resp)
	*bys id_village_uid: egen radio_rank = rank(rand_resp)

	qui gen rd_treat_`i' = .
	qui replace rd_treat_`i' =1 if rand_resp <= rand_resp_median & vill_extra == 1
	qui replace rd_treat_`i'=1 if rand_resp < rand_resp_median & vill_extra == 0
	qui replace rd_treat_`i'=0 if rd_treat_`i'==.
	
	qui drop rand_vill vill_extra rand_resp rand_resp_median 

}
	 
	keep id_village_uid id_resp_uid rd_treat_* 
	
	save "${data}/02_mid_data/pfm_ri_rd_as2_cm.dta", replace
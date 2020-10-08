/*______________________________________________________________________________

	Project: Pangani FM
	File: Creates New Variables for Merged / Appended Dataset
	Date: 8/22/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This merges and appends are relevant datasets
_______________________________________________________________________________*/


/* NOTES _______________________________________________________________________*/

/* 

(1) Always code so that more liberal / equal / progressive to be a higher number

*/


/* Introduction ________________________________________________________________*/

	clear all
	

/* Import Data _________________________________________________________________*/

	use "${data}/03_final_data/pfm_appended.dta", clear
	
/* Drop ________________________________________________________________________*/

drop ne_respid ne_real_treat
	
/* Define Samples ______________________________________________________________*/

	gen sample_survey = 1 if ne_sample == "ne"
		replace sample_survey = 2 if as_sample == "as"
		lab def sample_survey 1 "Natural Experiment" 2 "Audio Screening" 3 "Pangani"
		lab val sample_survey sample_survey
		lab var sample_survey "Sample survey (Audio Screening / Natural Experiment / Pangani)"
	
	gen sample_ne = (ne_sample == "ne")
		lab def sample_ne 0 "No" 1 "Yes"
		lab val sample_ne sample_ne
		lab var sample_ne "[Dummy] Natural Experiment Sample"
	
	gen sample_as = (as_sample == "as")
		lab def sample_as 0 "No" 1 "Yes"
		lab val sample_as sample_as
		lab var sample_as "[Dummy] Audio Screening Sample"
	
	gen sample_rd = (ne_rd_treat == 1) | (as_rd_treat == "Treat") | (ne_rd_treat == 0) | (as_rd_treat == "Control")
		lab def sample_rd 0 "No" 1 "Yes"
		lab val sample_rd sample_rd
		lab var sample_rd "[Dummy] Radio Distribution Sample"
		
		
/* Treatment Groups ____________________________________________________________*/

	/* Natural Experiment */
	rename ne_treat treat_ne
		lab def treat_ne 0 "Outside PFM range" 1 "Inside PFM range"
		lab val treat_ne treat_ne
		lab var treat_ne "Treatment - Natural Experiment"
	
	/* Audio Screening */
	rename as_treat treat_as
		lab def treat_as 0 "HIV screening" 1 "EFM screening"
		lab val treat_as treat_as
		lab var treat_as "Treatment - Audio Screening"

	/* Radio Distribution */	
	gen treat_rd = (ne_rd_treat == 1) | (as_rd_treat == "Treat")
	replace treat_rd = . if  sample_rd == 0
		lab def treat_rd 0 "No radio" 1 "Received radio" 
		lab val treat_rd treat_rd
		lab var treat_rd "Treatment - Radio distribution"
		
	/* Drop */
	drop ne_rd_treat as_rd_treat

/* Identifiers _________________________________________________________________*/

	label var id_region_c "Region Code"
	label var id_region_n "Region Name"
	label var id_district_c "District Code"
	label var id_district_n "District Name"
	label var id_ward_c "Ward Code"
	label var id_ward_n "Ward Name"
	label var id_village_n "Village Name"
	label var id_village_c "Village Code"
	
	gen id_resp_c = ne_id
		replace id_resp_c = as_b_resp_c if sample_as == 1
		lab var id_resp_c "Respondent Code"
	
	gen id_resp_n = ne_resp_name if sample_ne == 1
		replace id_resp_n = as_b_resp_name if sample_as == 1					
		replace id_resp_c = as_resp_c if sample_as == 1
		lab var id_resp_c "Respondent Code"
	
	gen id_resp_n = ne_resp_name if sample_ne == 1
		replace id_resp_n = as_name if sample_as == 1							
		lab var id_resp_n "Respondent Name"
		
	/* Unique IDs */
	egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
		lab var id_village_uid "Village Unique ID"
		
	egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
		lab var id_resp_uid "Respondent Unique ID"
		
	gen id_objectid = ne_objectid if sample_ne == 1
		replace id_objectid = as_objectid if sample_as == 1
		lab var id_objectid "(TZ Census) Object ID"
		
/* Early Marriage ______________________________________________________________*/		
		
/* We asked a similar (BUT NOT THE SAME) vignette based on Uzikwasa input about
willingness to marry. Differneces included:

(1) In NE sample, the girl was always less than 18
(2) In NE sample, amount offered was always less
(3) In NE sample, there was a randomization error */

* Personally Reject Early Marriage (Vignette)
gen em_story_self = 1 if ne_s7q8_fm_okself == 0 & sample_ne == 1
	replace em_story_self = 0 if ne_s7q8_fm_okself == 1 & sample_ne == 1 
replace em_story_self = 1 if as_s4q1_fm_yesself == 1 & sample_as == 1			// These were coded in opposite directions in cleaning
	replace em_story_self = 0 if as_s4q1_fm_yesself == 0 & sample_as == 1			
	lab def em_story 	1 "No, a family should never marry their daughter under X circumstances" ///
						0 "Yes, a family should marry their daughter under X circumstances"
	lab val em_story_self em_story
	lab var em_story_self "[Self] Early marriage ok under vignette circumstances?"

* Perceives Community would Reject Early Marriage (Vignette)
gen em_story_comm = 1 if ne_s7q9_fm_okcomm == 0 & sample_ne == 1
	replace em_story_comm = 0 if ne_s7q9_fm_okcomm == 1 & sample_ne == 1
replace em_story_comm = 1 if as_s4q1_fm_yescomm == 1 & sample_as == 1
	replace em_story_comm = 0 if as_s4q1_fm_yescomm == 0 & sample_as == 1
	lab val em_story_comm em_story
	lab var em_story_comm "[Community] Early marriage ok under vignette circumstances?"

gen em_story_t_age = ne_s7q8_fm_t_age if sample_ne == 1
replace em_story_t_age = as_s4q1_fm_t_age if sample_as == 1
	destring em_story_t_age, replace
	lab var em_story_t_age "Age of daughter in vignette"

gen em_story_t_outsider = ne_s7q8_fm_t_outsidevill if sample_ne == 1
replace em_story_t_outsider = as_s4q1_fm_t_inout if sample_as == 1
	lab def em_story_outside 1 "Outside village" 0 "Inside village"
	lab val em_story_t_outside em_story_outside
	lab var em_story_t_outsider "Prospective husband inside/outside of village"

gen em_story_t_offer = ne_s7q8_fm_t_amnt if sample_ne == 1
replace em_story_t_offer = as_s4q1_fm_t_amnt  if sample_as == 1
	replace em_story_t_offer = subinstr(em_story_t_offer,",","",.)
	destring em_story_t_offer, replace
	lab var em_story_t_offer "Bride price offer"

gen em_story_t_son = ne_s7q8_fm_t_son if sample_ne == 1
replace em_story_t_son = as_s4q1_fm_t_son if sample_as == 1
	lab def em_story_son 1 "Son" 0 "Old man"
	lab val em_story_t_son em_story_son
	lab var em_story_t_son "Prospective husband father/son"

gen em_story_t_issue = ne_s7q8_fm_t_daughterissue if sample_ne == 1
replace em_story_t_issue = 4 if ne_s7q8_fm_t_scen == 1							// If scenario is family money problems, daughter issue is not revealed even though SurveyCTO still randomly assigned to one of the daughter problems treatment groups
replace em_story_t_issue = 1 if as_b_txt5_eng == "failing in school"
replace em_story_t_issue = 2 if as_b_txt5_eng == "difficult to control at home"
replace em_story_t_issue = 3 if as_b_txt5_eng == "at risk of getting pregnantt"
replace em_story_t_issue = 4 if as_s4q1_fm_t_scen == 1								// If scenario is family money problems, daughter issue is not revealed even though SurveyCTO still randomly assigned to one of the daughter problems treatment groups
	lab def em_story_issue 1 "Failing at school" 2 "Hard to control" 3 "Pregnancy risk" 4 "Family money problems"
	lab val em_story_t_issue em_story_issue
	lab var em_story_t_issue "Issue facing family"
	
	
tab em_story_self sample_ne if em_story_t_age < 18, col
tab em_story_comm sample_ne if em_story_t_age < 18, col

/* Drop ________________________________________________________________________*/

	drop as_cases*
	*keep sample_* treat_* id_*
	sort id_village_uid id_resp_uid
	order id_* sample_* treat_*
	*drop resp_n 


/* Export ________________________________________________________________________*/

replace id_resp_n = ""
save "${data}/03_final_data/pfm_all.dta", replace

	
		
	

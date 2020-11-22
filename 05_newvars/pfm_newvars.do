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
	

/* Run Globals (if necessary ____________________________________________________*/

	*do "X:\Documents\pfm_.master\00_setup\pfm_paths_master.do"

	
/* Import Data _________________________________________________________________*/

	use "${data}/03_final_data/pfm_appended.dta", clear

	
/* Drop ________________________________________________________________________*/

	drop ne_respid

	
/* Labels _______________________________________________________________________*/

	lab def treatdum 0 "Control" 1 "Treatment"
	lab def yesno 0 "No" 1 "Yes", replace
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report", replace
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def muslim 0 "Christian" 1 "Muslim"
	lab def female 0 "Male" 1 "Female"

	
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
		lab def treat_rd 0 "No radio group" 1 "Radio group" 
		lab val treat_rd treat_rd
		lab var treat_rd "Treatment - Radio distribution"
		
	/* Drop */
	drop ne_rd_treat as_rd_treat
	

/* Identifiers _________________________________________________________________*/

	/* Names and Codes */
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
		lab var id_resp_n "Respondent Name"

	/* Unique IDs */
	egen id_ward_uid = concat(id_district_c id_ward_c), punct("_")
		lab var id_ward_uid "Ward Unique ID"
		
	egen id_village_uid = concat(id_district_c id_ward_c id_village_c), punct("_")
		lab var id_village_uid "Village Unique ID"
		
	egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
		lab var id_resp_uid "Respondent Unique ID"
		
	gen id_objectid = ne_objectid if sample_ne == 1
		replace id_objectid = as_objectid if sample_as == 1
		lab var id_objectid "(TZ Census) Object ID"
		
		
/* Survey Information __________________________________________________________*/

	/* Consent */
	gen svy_consent = .
		replace svy_consent = as_consent_confirm if sample_as == 1
		replace svy_consent = ne_s0q2_consent if sample_ne == 1
		lab val svy_consent yesno
		lab var svy_consent "Would you like to agree with this survey?"

/* Respondent Information _______________________________________________________*/

	/* Gender */
	gen resp_female = ne_s2q1_gender if sample_ne == 1
		replace resp_female = as_b_s2q1_gender if sample_as == 2
		recode resp_female (1=0)(2=1)
		lab val resp_female female
		lab var resp_female "Respondent Female?"
		
	/* Age */
	gen resp_age = ne_s2q3_age if sample_ne == 1
		destring as_b_age, replace
		replace resp_age = as_b_age if sample_as == 2
		lab var resp_age "Respondent Age"
		
	/* Religion */
	gen resp_muslim = ne_s13q1_christian if sample_ne == 1
		recode resp_muslim (1 = 0) (0 = 1)
		replace resp_muslim = as_b_s3q1_religion_muslim if sample_as == 2
		lab val resp_muslim muslim
		lab var resp_muslim "Respondent Muslim?"
		

/* Compliance __________________________________________________________________*/

	/* Audio Screening */
		** Attended
		rename as_comply_attend as_comply_attend
		
		** New the topic
		rename as_comply_topic as_comply_knowtopic
	
	/* Natural Experiment
		NOTE: need to get village level information on PFM availability 
	*/
	
	/* Radio Distribution */
		** Delivered
		gen rd_comply_received = .
		replace rd_comply_received = as_rd_radio_delivered if sample_as == 1
		replace rd_comply_received = ne_rd_radio_delivered if sample_ne == 1
		lab val rd_comply_received yesno
		lab var rd_comply_received "Did respondent receive a radio?"
		
		
/* Early Marriage ______________________________________________________________*/		
		
/* We asked a similar (BUT NOT THE SAME) vignette based on Uzikwasa input about
willingness to marry. Differneces included:

(1) In NE sample, the girl was always less than 18
(2) In NE sample, amount offered was always less
(3) In NE sample, there was a randomization error */

** Vignette 
	* Vignette Treatments
	gen em_story_t_age = ne_s7q8_fm_t_age if sample_ne == 1
	replace em_story_t_age = as_s4q1_fm_t_age if sample_as == 1
		destring em_story_t_age, replace
		lab var em_story_t_age "Age of daughter in vignette"
		
	gen em_story_t_em = (em_story_t_age < 18)
		lab def em 0 "Over 18 [Forced Marriage]" 1 "Under 18 [Early Marriage]"
		lab val em_story_t_em em
		lab var em_story_t_em "Story about EARLY marriage or only FORCED marriage"

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
		
/*
	gen em_story_t_scen = ne_s7q8_fm_t_scen if sample_ne == 1
	replace em_story_t_scen = as_s4q1_fm_t_scen if sample_as == 1
		lab def em_story_issue 0 "Money Issue" 1 "Daughter Issue"
		lab val em_story_t_issue em_story_daughtissue
		lab var em_story_t_issue "Daughter acting out or family money problems?"
		*/

	gen em_story_t_issue = ne_s7q8_fm_t_daughterissue if sample_ne == 1
	replace em_story_t_issue = 1 if as_b_txt5_eng == "failing in school"
	replace em_story_t_issue = 2 if as_b_txt5_eng == "difficult to control at home"
	replace em_story_t_issue = 3 if as_b_txt5_eng == "at risk of getting pregnantt"
	replace em_story_t_issue = 4 if as_s4q1_fm_t_scen == 1								// If scenario is family money problems, daughter issue is not revealed even though SurveyCTO still randomly assigned to one of the daughter problems treatment groups
	replace em_story_t_issue = 4 if ne_s7q8_fm_t_scen == 1							// If scenario is family money problems, daughter issue is not revealed even though SurveyCTO still randomly assigned to one of the daughter problems treatment groups

		lab def em_story_issue 1 "Failing at school" 2 "Hard to control" 3 "Pregnancy risk" 4 "Family money problems"
		lab val em_story_t_issue em_story_issue
		lab var em_story_t_issue "Issue facing family"
		
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
		
/* Forced Marriage ______________________________________________________________*/		

recode as_s10q2_fm_accept (0=1 "Should not accept") (1=0 "Should accept"), gen(fm_girlreject)
	lab var fm_girlreject "[REVERSED] An 18 year old girl should accept the husband her parents choose for her"

rename as_s5q2_gh_marry fm_girlpick 
	replace fm_girlpick = 1 if ne_s7q2_gh_dadpickhusband == 0 
	replace fm_girlpick = 0 if ne_s7q2_gh_dadpickhusband == 1
	lab def fm_girlpick 0 "Dad should pick" 1 "Girl should pick"
	lab val fm_girlpick fm_girlpick
	
/* Assetts _____________________________________________________________________*/		

	gen radio_own  = .
		replace radio_own = as_b_s12q1_rad if sample_as == 1
		replace radio_own = ne_s16q1_radio if sample_ne == 1
		lab val radio_own yesno
		lab var radio_own "Do you own a radio?"

	gen radio_own_num = .
		replace radio_own_num = as_b_s12q1a_rad_num if sample_as == 1
			replace radio_own_num = 0 if as_b_s12q1_rad == 0
		replace radio_own_num = ne_s16q1a_rad_num if sample_ne == 1
			replace radio_own_num = 0 if ne_s16q1_radio == 0
		lab var radio_own_num "How many radios do you own?"

	gen radio_wouldaccept = .
		replace radio_wouldaccept = as_b_s12q1b_rad_list if sample_as == 1
		replace radio_wouldaccept = ne_s16q1b_rad_wouldaccept if sample_ne == 1
		lab val radio_wouldaccept yesno
		lab var radio_wouldaccept "If you were to get a radio, would you listen to it?"
		
	

/* Drop ________________________________________________________________________*/

	drop as_cases*
	*keep sample_* treat_* id_*
	sort id_village_uid id_resp_uid
	order id_* sample_* treat_*
	*drop resp_n 
	

/* Export ________________________________________________________________________*/

*replace id_resp_n = ""
save "${data}/03_final_data/pfm_all.dta", replace


stop


order id_resp_n id_* sample_* treat_* resp_* cases_* ne_resp_phone1 ne_resp_phone2 as_b_cases_phone1 as_b_cases_phone2 ne_head_name ne_alt_name ne_alt_relation ne_neighbor_name ne_neighbor_phone ne_resp_name ne_resp_phone1 ne_resp_phone2

keep id_resp_n id_* sample_* treat_* resp_* cases_* ne_resp_phone1 ne_resp_phone2 as_b_cases_phone1 as_b_cases_phone2 ne_head_name ne_alt_name ne_alt_relation ne_neighbor_name ne_neighbor_phone ne_resp_name ne_resp_phone1 ne_resp_phone2

sort id_ward_uid id_village_uid 



export delimited using "${data}\03_final_data\pfm_cases.csv", replace



/* Define IDs __________________________________________________________________

	** Create unique identifiers for case manamagement
	gen svy_district_id = id_district_c
	gen svy_district_name = id_district_n

	egen svy_ward_id = concat(id_district_c id_ward_c), punct(_)
	gen svy_ward_name = id_ward_n

	egen svy_village_id = concat(id_district_c id_ward_c id_village_c), punct(_)
	gen svy_village_name = id_village_n

	egen svy_resp_id = concat(id_district_c id_ward_c id_village_c ne_id) if sample_ne == 1, punct(_)
		egen as_svy_resp_id = concat(id_district_c id_ward_c id_village_c as_b_resp_c) if sample_as == 1, punct(_)
		replace svy_resp_id = as_svy_resp_id if sample_as == 1
	gen svy_resp_n = as_resp_n

	** Create Sample Identifiers
	clonevar svy_sample = sample_survey
	clonevar svy_radiosample = sample_rd

	** Create Treatment Identifiers
	clonevar treat_rd = ne_rd_treat
		replace treat_rd = 1 if as_rd_treat == "Treat"
		replace treat_rd = 0 if as_rd_treat == "Control"
		lab val treat_rd treatdum

	gen treat_ne = ne_treat
		lab val treat_ne treatdum
		
	gen treat_as = as_treat
		lab val treat_as treatdum
*/
	
		
	
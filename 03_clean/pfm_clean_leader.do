
	
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Audio Screening
	Purpose: Leader Survey
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/11/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global date = td(07122020) // update the date everyday		

/* Notes _______________________________________________________________________

	(1) Rememeber to cut out training and pilot data 
	(2) Need to come back for feeling thermometer questions

*/

/* Import  _____________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_rawpii_leader.dta", clear

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def female 0 "Male" 1 "Female"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def reject_cat 0 "Always Acceptable" 1 "Sometimes Acceptable" 2 "Never Acceptable"
	lab def interest 0 "Not interested" 1 "Somewhat interested" 2 "Interested" 3 "Very interested"
	lab def em_elect 0 "Vote Against EM Candidate" 1 "Vote For EM Candidate"
	lab def hiv_elect 0 "Vote Against HIV Candidate" 1 "Vote for HIV Candidate"
	lab def treatment 0 "Control" 1 "Treatment" 
	lab def elect_topic 1 "EFM" 2 "HIV" 3 "Roads" 4 "Crime"
	lab def em_norm_reject 0 "Acceptable" 1 "Sometimes Acceptable" 2 "Never acceptable"
	lab def tzovertribe 0 "Tribe >= TZ" 1 "TZ > Tribe"
	lab def hhlabor 1 "Mother" 2 "Father" 3 "Both"
	lab def hhdecision 1 "Mother" 2 "Father" 3 "Both" 4 "Other man" 5 "Other woman"
	lab def hh_dum 0 "Woman" 1 "Man or balanced"
	lab def hh_dum_rev 0 "Man" 1 "Woman or balanced"

	
/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)



/* Survey Info _________________________________________________________________*/

	destring duration, gen(svy_duration)
		replace svy_duration = svy_duration / 60
	
	rename enum_name svy_enum_txt
	
	rename village village_n 
	rename village_id id_village_uid
	rename subvillage subvillage_n


/* Consent _____________________________________________________________________*/

	rename consent consent														// HFC: Consent Check


/* Respondent Info ______________________________________________________________*/

	rename resp_name 		resp_name
	
	rename resp_ppe 		resp_ppe

	gen resp_female = .
		replace resp_female = 1 if resp_gender == 2
		replace resp_female = 0 if resp_gender == 1
		lab val resp_female female 
		
	rename resp_position 	resp_position
		replace resp_position = 5 if resp_position == 8

	rename resp_position_time 	resp_timegov_current
	rename resp_position_anygov	resp_timegov_any
	
	rename resp_age			resp_age 
		
	gen resp_muslim = (resp_religion == 3)
	gen resp_christian = (resp_religion == 2)
	
	rename s3q19_tribe 		resp_tribe 
	rename s3q19_tribe_oth 	resp_tribe_oth
	
	
/* Village Information _________________________________________________________*/

	rename villinfo_schools_prim 		vill_schools_primary
	rename villinfo_schools_sec			vill_schools_secondary
	rename villinfo_schools_sec_dist	vill_schools_distance
	
	rename villinfo_clinic				vill_clinics 
	
	rename villinfo_water_0				vill_water_none
	rename villinfo_water_1				vill_water_handwell
	rename villinfo_water_2				vill_water_motorwell
	rename villinfo_water_3				vill_water_piped
	rename villinfo_water_4				vill_water_broken 
	rename villinfo_water_5				vill_water_natural 
	replace vill_water_natural = 1 if villinfo_water_6 == 1
	
	rename villinfo_electric			vill_electric 
	
	rename villinfo_church				vill_churches 
	
	rename villinfo_mosque				vill_mosques 
	
	rename villinfo_jouranlist			vill_journalist
	
/* Preferences and Budget ______________________________________________________*/

	forval i = 1/9 {
		gen ptixpref_rank_`i' = .
		replace ptixpref_rank_`i' = 6 if pref_a == `i'
		replace ptixpref_rank_`i' = 5 if pref_b == `i'
		replace ptixpref_rank_`i' = 4 if pref_c == `i'
		replace ptixpref_rank_`i' = 3 if pref_d == `i'
		replace ptixpref_rank_`i' = 2 if pref_e == `i'
		replace ptixpref_rank_`i' = 1 if pref_f == `i'
	}
	
		drop ptixpref_rank_1 ptixpref_rank_2
		rename ptixpref_rank_3		ptixpref_rank_efm
		rename ptixpref_rank_4		ptixpref_rank_edu
		rename ptixpref_rank_5		ptixpref_rank_justice
		rename ptixpref_rank_6		ptixpref_rank_electric
		rename ptixpref_rank_7		ptixpref_rank_sanit
		rename ptixpref_rank_8		ptixpref_rank_roads
		rename ptixpref_rank_9		ptixpref_rank_health
		
/* Drop Stuff __________________________________________________________________*/

	sort resp_name 
	bysort id_village_uid : gen rank = _n
		
	
/* Export ______________________________________________________________________*/



	drop deviceid subscriberid simid devicephonenum username duration svy_duration caseid svy_enum_txt consent section_2_start pref_a pref_b pref_c pref_d pref_e pref_f pref_other s20q1 s20q1b s20q1b_oth s20q2latitude s20q2longitude s20q2altitude s20q2accuracy svt_comment formdef_version key isvalidated submissiondate starttime endtime village_n subvillage_n villinfo_*
	
	gen svy_leader = 1
	rename * l_*

	/* Save */
	save "${data}/01_raw_data/pfm_leader_long.dta", replace

	/* Reshape */
	reshape wide l_ptixpref_rank_* l_budget_* l_vill_* l_resp_*, i(l_id_village_uid) j(l_rank)
	
	* Within folder
	save "${data}/01_raw_data/pfm_leader.dta", replace



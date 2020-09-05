*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: FollowUp Pilot Import and Cleaning
* Date: 8/7/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This runs high frequency checks on the follow up data
*-------------------------------------------------------------------------------


* Introduction -----------------------------------------------------------------
clear all
set maxvar 30000
set more off

* Labels
lab def yesnodk 0 "No" 1 "Yes" -999 "Dont Know" -888 "Refuse"
lab def reversedyesno 0 "Yes" 1 "No" .d "Don't Know"

*-------------------------------------------------------------------------------
* Merge
*-------------------------------------------------------------------------------

* Import Basline ---------------------------------------------------------------
use "${data}/03_final_data/pfm_as_merged.dta", clear

*-------------------------------------------------------------------------------
* Remove PII
*-------------------------------------------------------------------------------

/* Baseline
drop b_resp_name b_district_n b_ward_n b_village_n b_cases_label b_cases_resp_name ///
		b_district_name b_ward_name b_village_name b_s1q9_subvillage b_idstring ///
		b_resp_name2 b_resp_phone1 b_re_phone1 b_resp_phone2 b_re_phone2 b_head_name ///
		b_hhh_phone b_re_hhh_phone b_survey_location* b_instancename b_vill_str b_vill_num ///
		b_village b_name
		
* Endline
drop s13q4 s13q4_oth resp_track_note resp_name resp_phone1 re_phone1 resp_phone2 re_phone2 head_name ///
	
		
*-------------------------------------------------------------------------------
* Remove Desideratum
*-------------------------------------------------------------------------------

* Baseline
drop 	b_deviceid b_caseid ///
		b_ward_c_pull b_district_c_pull b_selection_bc b_rand_sortby b_village_c_pull b_village_id ///
		b_village_c_pull b_cases_users b_cases_formids b_cases_sortby b_cases_phone1 b_cases_phone2 ///
		b_cases_hhh_phone b_cases_resp_gender b_cases_hhh_name b_cases_subvillage_name b_cases_village_name ///
		b_cases_ward_name b_cases_district_name b_cases_baseline_date b_cases_baseline_duration b_cases_baseline_fo ///
		b_fo_name b_id b_id_re b_intro_note_1 b_intro_note_2 b_audio_note b_intro_note_3 b_s13_note3 ///
		b_resp_track_note b_resp_track_note b_notes b_formdef_version b_key b_isvalidated b_consent ///
		b_survey_num_fo b_fo_string b_respid b_s1q1_txt b_village_id_pull b_team b_s8q2 b_s9_note1 ///
		b_s9_noteintro b_s8_2_note b_section_10_note b_s11_note3
		
* Endline
drop _merge deviceid subscriberid simid devicephonenum username rand_bc selection_bc ///
		cases_label cases_users cases_formids case_check pre_label pre_phone1 pre_phone2 ///
		pre_hhh_phone pre_resp_name pre_resp_gender_txt pre_hhh_name s1q6_subvillage ///
		pre_village_name pre_ward_name s1q4_ward s1q3_district intro_note* formdef_version key ///
		fo_string village
*/	
*-------------------------------------------------------------------------------
* Baseline Covariates
*-------------------------------------------------------------------------------

* New Baseline Covariates

gen c_religion2 = .
replace c_religion2 = 1 if b_s3q2_rel_attend >= 2
replace c_religion2 = 0 if b_s3q2_rel_attend == 1 | b_s3q2_rel_attend == 0
lab def rel2 1 "Attends mosque/church >2 days/week" 0 "Attend church < 2 days/week"
lab val c_religion2 rel2

gen c_religion7 = .
replace c_religion7 = 1 if b_s3q2_rel_attend >= 7
replace c_religion7 = 0 if b_s3q2_rel_attend < 7
lab def rel7 1 "Attends mosque/church >7 days/week" 0 "Attend church < 7 days/week"
lab val c_religion7 rel7

gen c_education_years = b_s2q19_education
replace c_education_years = .m if b_s2q19_education == -222
replace c_education_years = 16 if b_s2q19_education > 16 // Dont have a way to calculatehigher education, so stop at highest levels
replace c_education_years = 16 if b_s2q19_education_oth == "Astashahada"


gen c_equalchildcare = b_s6q1_gh_noeqkid	
gen c_dadchoosehusband = b_s6q2_gh_marry
gen c_equallearningbad = b_s6q3_gh_earn
gen c_equalearningbad = b_s6q3_gh_earn
gen c_gh_index = (c_equalchildcare + c_dadchoosehusband + c_equallearningbad + c_equalearningbad)/4
gen c_nofemlead = b_s6q4_gh_lead
gen c_technologygood = b_s5q2_techgood 
gen c_likechange = b_s5q1_likechange
gen c_age = b_s2q3_age 
gen c_gender = b_s2q1_gender
gen c_anyradio = b_s4q3_radio_any 
gen c_trustelders = b_s7q2_trustelders 
gen c_ownradio = b_s12q1_rad
gen c_goodday = b_s2q2_goodday
gen c_headofhousehold = b_s2q4_hhh
gen c_married = b_s2q5_married 
gen c_hhsize = b_s2q6_numhh	
gen c_timeinvillage = b_s2q11_yrsvill	
gen c_workedcity = b_s2q13_livecity_dum 
gen c_timesincity = b_s2q13_livecity_num 
gen c_borninvillage = b_s2q16_samevillage
gen c_standard7 = b_s2q19_standard7
gen c_readwrite = b_s2q19a_readwrite 
gen c_swahilimain = b_s2q20_lang_swahilimain 
gen c_christian = b_s3q1_religion_christ 
gen c_anytv = b_s4q1_tv_any 
gen c_respectauthority = b_s7q1_respectauthority 
gen c_hivaware = b_s8q1_hiv_aware 
gen c_hivexclude = b_s8q2_hiv_exctot
gen c_hivsafe = b_s8q3_hiv_safe 
gen c_hivacceptonbus = b_s8q4_hiv_bus 
gen c_multiplehuts = b_s11q1_multiplehuts
gen c_tvown = b_s12q2_tv 
gen c_cellown = b_s12q3_cell 
gen c_numberofkids = b_s2q7a_numkid
gen c_kidsever = b_s2q10_kidsever	
gen c_knowallvillage = b_s2q12_villknow_all 
gen c_nevervisitcity = b_s2q17_nevervisitcity 
gen c_nevervisittown = b_s2q18_nevervisittown
gen c_muslim = b_s3q1_religion_muslim
gen c_radiocommunity = b_s4q8_radcomm_ever	
gen c_nonews = b_s4q9_news_never
gen c_believewitchcraft = b_s10q1_witch_blf 
replace c_believewitchcraft  = 0 if c_believewitchcraft  == .d
gen c_cellinternet = b_s12q3a_cellint 
gen c_longcellbattery = b_s12q3b_battery_weeks
gen c_mudwalls = b_s11q3_mudwalls
bys b_village_c : egen c_vill_attend = count(comply_attend) 

recode c_readwrite c_timeinvillage c_equallearningbad c_trustelders c_anyradio  (-999 = .d)

gen churchattendance = b_s3q2_rel_attend // Not including because of high number of refusals

*-------------------------------------------------------------------------------
* Outcome Variables
*-------------------------------------------------------------------------------

* HIV --------------------------------------------------------------------------

* Discuss
	
	gen hiv_discuss = s2q4_discussions_hiv
	lab var hiv_discuss "Discussed HIV"
	lab val hiv_discuss yesnodkr
	
* Knowledge

	gen hiv_know_anydrug = s9q5a_hiv_knowdrug
	lab var hiv_know_anydrug "Knows any drug treats HIV"
	lab val hiv_know_anydrug yesnodkr
	
	gen hiv_know_arv_noprompt = s9q5c_hiv_knowarv
	lab var hiv_know_arv_noprompt "Knows ARVs (no prompt)"
	lab val hiv_know_arv_noprompt yesnodkr
	
	gen hiv_know_arv_prompt = s9q5b_hiv_knowarv_prompt
	lab var hiv_know_arv_prompt "Knows ARVs (prompt)"
	lab val hiv_know_arv_prompt  yesnodkr
	
	gen hiv_know_transmit_baby = s9q6_hiv_knowpreg
	lab var hiv_know_transmit_baby "Knows HIV Transmissable to Baby"
	lab val hiv_know_transmit_baby yesnodkr
	
	gen hiv_know_alttreatments = s9q7_hiv_spirit
	recode hiv_know_alttreatments (0=1)(1=0)
	lab var hiv_know_alttreatments "[Reversed] Believes in Alternative HIV Treatments"
	lab val hiv_know_alttreatments reversedyesno
	
	* Generate Index
	
	gen hiv_know_index = 	hiv_know_anydrug + hiv_know_arv_noprompt + ///
							hiv_know_arv_prompt + hiv_know_transmit_baby + ///
							hiv_know_alttreatments
	lab var hiv_know_index "HIV Knowledge Index"

* Conative Attitudes
	recode s9q10_hiv_workself (0=1)(1=0)
	gen hiv_conatt_work = s9q10_hiv_workself
	lab def hiv_conatt_work 0 "Would not be willing to work with HIV+ person" 1 "Would be willing to work with HIV+ person"
	lab var hiv_conatt_work "Willing to work with HIV+ person"
	lab val hiv_conatt_work yesnodkr
	
	gen hiv_conatt_house = s9q9_hiv_house
	lab var hiv_conatt_house "Willing to live with HIV+ person"
	lab val hiv_conatt_house yesnodkr
	
	gen hiv_conatt_share = 	s9q11_hiv_sharespouse + s9q11_hiv_sharefam + ///
							s9q11_hiv_sharefriend + s9q11_hiv_sharecowork
	lab var hiv_conatt_share "[0-4] Willing to share HIV+"
	
* Conative Norms

	gen hiv_connorm_work = s9q10_hiv_workcomm
	lab var hiv_connorm_work "Community work with HIV+ person"
	lab val hiv_connorm_work yesnodkr
	
* Cognitive Attitudes
	recode s9q8_hiv_famshare (0=1)(1=0)
	gen hiv_cogatt_nosecret = s9q8_hiv_famshare
	lab var hiv_cogatt_nosecret "[Reversed] Keep HIV status of family member a secret?"
	lab val hiv_cogatt_nosecret reversedyesno
	
	gen hiv_cogatt_football = s9q9_hiv_boy
	lab var hiv_cogatt_football "HIV+ boy should play football"
	lab val hiv_cogatt_football yesnodkr

* Priorities
	
	gen hiv_prior_list = .
	replace hiv_prior_list = 4 if s3q3_prior_hiv == 3
	replace hiv_prior_list = 3 if s3q3_prior_hiv == 2
	replace hiv_prior_list = 2 if s3q3_prior_hiv == 1
	replace hiv_prior_list = 1 if s3q3_prior_hiv == 0
	replace hiv_prior_list = 0 if s3q3_prior_hiv == -1
	

	
	replace hiv_prior_list = 4 if s3q3_prior_hiv == 3 & s3q3_prior_fm == 3
	replace hiv_prior_list = 3 if s3q3_prior_hiv == 2 & (s3q3_prior_fm == 3 | s3q3_prior_fm == 2)
	replace hiv_prior_list = 2 if s3q3_prior_hiv == 1 & (s3q3_prior_fm == 3 | s3q3_prior_fm == 2 | s3q3_prior_fm == 1)
	replace hiv_prior_list = 1 if s3q3_prior_hiv == 0 & (s3q3_prior_fm == 3 | s3q3_prior_fm == 2 | s3q3_prior_fm == 1 | s3q3_prior_fm == 0)
	lab var hiv_prior_list "Priority of HIV"
	lab val hiv_prior_list s3q3_prior_hiv
	
	gen hiv_prior_elect = votehiv_tot
	lab var hiv_prior_elect "Voted for candidate supporting HIV"
	lab val hiv_prior_elect yesnodkr
	gen hiv_prior_index = (hiv_prior_elect + (hiv_prior_list + 1)/4)/2

* FM ---------------------------------------------------------------------------

* Discuss
	
	gen fm_discuss = s2q4_discussions_fm
	lab var fm_discuss "Discussed FM"
	lab val fm_discuss yesnodkr

* Conative Attitudes

	gen fm_conatt_support = s10q2_fm_accept
	recode fm_conatt_support (0=1)(1=0)
	lab var fm_conatt_support "[Reversed] An 18 year-old daughter should accept the husband that her father decides for her"
	lab val fm_conatt_support reversedyesno
	
	gen fm_conatt_report = s4q3_fm_reportself
	lab var fm_conatt_report "Would report FM"
	lab val fm_conatt_report yesnodkr

* Conative Norms

	gen fm_norm_report = s4q3_fm_reportcomm
	lab var fm_norm_report "Community would report FM"
	lab val fm_norm_report yesnodkr

* Cognitive Attitudes

	gen fm_cogatt_girlchoice = s5q2_gh_marry
	lab var fm_cogatt_girlchoice "[REVERSED] A girl should not have a say in who she marries; it is best if her father decides for her"
	lab val fm_cogatt_girlchoice yesnodkr
	
	gen fm_cogatt_story = s4q1_fm_yesself
	lab var fm_cogatt_story "FM not acceptable"
	lab val fm_cogatt_story yesnodkr
	
	gen fm_cogatt_law = s4q2_fm_lawpref
	recode fm_cogatt_law (3=0)(1=1)(2=2)
	lab var fm_cogatt_law "Position on FM Law"
	lab def law 0 "No law" 1 "Ban FM at 15" 2 "Ban FM at 18+"
	lab val fm_cogatt_law law

* Cognitive Norms

	gen fm_cognorm_story = s4q1_fm_yescomm 
	replace fm_cognorm_story = 0 if fm_cognorm_story == .d // Don't know means not "Yes"
	lab var fm_cognorm_story "(Community) FM not acceptable"
	lab val fm_cognorm_story yesnodkr
	
* Priorities

	gen fm_prior_list = .
	replace fm_prior_list = 4 if s3q3_prior_fm == 3
	replace fm_prior_list = 3 if s3q3_prior_fm == 2
	replace fm_prior_list = 2 if s3q3_prior_fm == 1
	replace fm_prior_list = 1 if s3q3_prior_fm == 0
	replace fm_prior_list = 0 if s3q3_prior_fm == -1
	
	replace fm_prior_list = 4 if s3q3_prior_fm == 3 & s3q3_prior_hiv == 3
	replace fm_prior_list = 3 if s3q3_prior_fm == 2 & (s3q3_prior_hiv == 3 | s3q3_prior_hiv == 2)
	replace fm_prior_list = 2 if s3q3_prior_fm == 1 & (s3q3_prior_hiv == 3 | s3q3_prior_hiv == 2 | s3q3_prior_hiv == 1)
	replace fm_prior_list = 1 if s3q3_prior_fm == 0 & (s3q3_prior_hiv == 3 | s3q3_prior_hiv == 2 | s3q3_prior_hiv == 1 | s3q3_prior_hiv == 0)
stop
	lab var fm_prior_list "Priority of FM"
	lab val fm_prior_list s3q3_prior_fm
	
	gen fm_prior_elect = votefm_tot
	lab var fm_prior_elect "Voted for candidate supporting FM"
	lab val fm_prior_elect yesnodkr
	
	gen fm_prior_index = (fm_prior_elect + (fm_prior_list + 1)/4)/2

* IPV --------------------------------------------------------------------------

* Discuss
	
	gen ipv_discuss = s2q4_discussions_ipv
	lab var ipv_discuss "Discussed ipv"
	lab val ipv_discuss yesnodkr

* IPV Knowledge

	gen ipvknow_law = s11q3_ipv_knowlaw
	lab var ipvknow_law "Knows IPV against law"
	lab val ipvknow_law yesnodkr
	
* Conative Attitudes
	
	replace ipv_conatt_report = (s16q1_ipv_police + s16q1_ipv_vc + s16q1_ipv_parents)/3
	lab var ipv_conatt_report "[Avg of 3] Would you report instance of abuse?"

* Cognitive Attitudes

	gen ipv_cogatt_abuse = -1*(s8q3a_ipv_disobey + s8q3b_ipv_cheats + s8q3c_ipv_kids ///
							+ s8q3d_ipv_elders + s8q3f_ipv_gossip)/5 + 1
	lab var ipv_cogatt_abuse "[Avg of 5] Abuse not acceptable"

* Cognitive Norms

	gen ipv_cognorm_abuse = s11q1_ipv_hitnorm
	recode ipv_cognorm_abuse (0=1)(1=0)
	lab var ipv_cognorm_abuse "Community rejects abuse"
	lab val ipv_cognorm_abuse reversedyesno
	
	gen ipv_cognorm_react = s11q2_ipv_responsenorm
	recode ipv_cognorm_react (1=0)(2=1)(3=2)
	lab var ipv_cognorm_react "Community response to abuse"
	lab def ipvnorm 0 "Accept" 1 "Depends" 2 "Outraged"
	lab val ipv_cognorm_react ipvnorm

* Gender Hierarchy -------------------------------------------------------------

	gen gh_hhwork = s5q1_gh_eqkid
	lab var gh_hhwork "Husband and wife should split HH work"
	lab val gh_hhwork yesnodkr
	
	gen gh_earnings = s5q3_gh_earn
	recode gh_earnings (0=1)(1=0)
	lab var gh_earnings "Woman earning more is a problem"
	lab val gh_earnings reversedyesno
	
	gen gh_school = s5q4_gh_school
	recode gh_school (0=1)(1=0)
	lab var gh_school "Boy school more important"
	lab val gh_school reversedyesno
	
	gen gh_migrate = 1 if s15q2_mg_supdaught == 1 & s15q2_mg_supson == 1
	replace gh_migrate = 1 if s15q2_mg_supdaught == 1 & s15q2_mg_supson == 0
	replace gh_migrate = 0 if s15q2_mg_supdaught == 0 & s15q2_mg_supson == 1
	replace gh_migrate = 1 if s15q2_mg_supdaught == 0 & s15q2_mg_supson == 0
	lab def gh_migrate 0 "Prefer boy migration" 1 "Don't prefer boy migration"
	
	gen gh_index = (gh_hhwork + gh_earnings + gh_school + gh_migrate)/4

*-------------------------------------------------------------------------------
* Diff
*-------------------------------------------------------------------------------
gen b_s6q2_gh_marry_rev = b_s6q2_gh_marry
recode b_s6q2_gh_marry_rev (0 = 1)(1 = 0)

gen fm_diff = s5q2_gh_marry - b_s6q2_gh_marry_rev

*-------------------------------------------------------------------------------
* Village Level Variables
*-------------------------------------------------------------------------------

bys b_village_c : egen vill_gh = mean(gh_index)
bys b_village_c : egen vill_bfm = mean(b_s6q2_gh_marry)
bys b_village_c : egen vill_fmdiff = mean(fm_diff)

gen vill_bfm_dum = 1 if vill_bfm < .2
replace vill_bfm_dum = 0 if vill_bfm_dum == .

*rename b_district_c district_c
*rename b_ward_c ward_c
*rename b_village_c village_c

*-------------------------------------------------------------------------------
* Save
*-------------------------------------------------------------------------------
save "$pfm2/05_data/04_precheck/panganifm2_final.dta", replace
save "$stata/01 Data/pfm2_audioscreening_master.dta", replace

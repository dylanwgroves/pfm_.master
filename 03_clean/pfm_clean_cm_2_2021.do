
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survey 2 (November 2021)
Purpose: Clean Data
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023/10/28
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	*version 15
	clear all
	set maxvar 30000
	set more off

	
/* Load Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_nopii_cm_2_2021.dta", clear

	gen cm_2_2021 = 1
	
/* Vilalge Information _________________________________________________________*/

encode village_name_pull, gen (id_village)
	replace id_village = 0 if id_village == .

/* Respondent Information ______________________________________________________*/

/* Cleaning */

	replace resp_gender = enum_gender 	if resp_gender == . 
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Hamza Mtinangi"
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Jackson Bukuru"
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Kassim Abdallah"
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Kasimu Mohamed Abdallah"
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Lusekelo Andrew"
	replace resp_gender = 0 			if resp_gender == . & enum_name == "Rashid Seif"
	replace resp_gender = 1 			if resp_gender == . & enum_name == "Husna Majura"
	replace resp_gender = 1 			if resp_gender == . & enum_name == "Sheila Mlaki"
	replace resp_gender = 1 			if resp_gender == . & enum_name == "Silvana Karia"

	cap rename s3q21_religion resp_religion
	cap rename s3q21_religion_oth resp_religion_oth
	cap rename s3q21_religion_oth resp_religion_oth

	cap rename s3q21_tribe resp_tribe
	cap rename s3q21_tribe_oth resp_tribe_oth
	
	destring section_2_dur, replace

/* Crosstabs */
	tab resp_ppe
	tab resp_gender
	tab resp_howudoin
	tab resp_profession
	tab resp_profession_oth
	tab resp_married
	tab resp_religion

	sum section_2_dur


/* Respond Information, Extensive ______________________________________________*/

/* Cleaning */
	rename s3q1_age resp_age 
	rename s3q2_hh_relation resp_hhh_rltn 
	rename s3q2_oth resp_hhh_rltn_oth
	rename s3q3_status resp_relationship
	rename s3q3_status_oth resp_relationship_oth
	rename s3q4 resp_partner_age
	rename s3q5 resp_married_year

	tostring s3q6, gen(profession)
	replace resp_profession = profession if profession != ""

	rename s3q7_hhh_nbr resp_hh_nbr
	rename s3q8_hhh_children resp_hh_kids
	rename s3q11child_had resp_kidsborn
	rename s3q13_nbr_people resp_pplknow
	rename s3q14_vill_16 resp_vill16
	rename s3q15_city_town resp_visittown
	rename s3q16_school_grade resp_edu 
	rename s3q17_write_read resp_literate
	rename s3q19_language resp_language
	rename s3q19_language_oth resp_language_oth
	rename s3q20_oth_lang resp_2ndlanguage
	rename s3q20_oth_lang_oth resp_2ndlanguage_oth
	rename s3q20_tz_tribe resp_natid

	rename s3q21b_religiousschool resp_religiousschool
	rename s3q22_religious resp_religiosity
	
	sum section_3_dur


/* Climate Change Impact _______________________________________________________*/

/* Cleaning */
	rename ccimpact_problems_1 ccimpact_problems_drought
	rename ccimpact_problems_2 ccimpact_problems_storms
	rename ccimpact_problems_3 ccimpact_problems_floods
	rename ccimpact_problems_4 ccimpact_problems_heat
	rename ccimpact_problems_5 ccimpact_problems_unpredictrains
	rename ccimpact_problems_6 ccimpact_problems_crops
	rename ccimpact_problems_7 ccimpact_problems_forest
	rename ccimpact_problems_8 ccimpact_problems_coasterode
	rename ccimpact_problems_9 ccimpact_problems_saltwater
	rename ccimpact_problems_10 ccimpact_problems_mangrove
	rename ccimpact_problems_11 ccimpact_problems_fish
	rename ccimpact_problems_12 ccimpact_problems_rangeland
	rename ccimpact_problems_13 ccimpact_problems_waterscarcity
	rename ccimpact_problems_14 ccimpact_problems_landdegrade
	rename ccimpact_problems_15 ccimpact_problems_burnforest

	rename ccimpact_cause ccimpact_cause_main 
	
	rename ccimpact_cause_oth_1 ccimpact_cause_nature
	rename ccimpact_cause_oth_2 ccimpact_cause_god
	rename ccimpact_cause_oth_3 ccimpact_cause_forces
	rename ccimpact_cause_oth_4 ccimpact_cause_myvill
	rename ccimpact_cause_oth_5 ccimpact_cause_othvill
	rename ccimpact_cause_oth_6 ccimpact_cause_tz
	rename ccimpact_cause_oth_7 ccimpact_cause_othppl
	rename ccimpact_cause_oth_8 ccimpact_cause_othgov
	rename ccimpact_cause_oth_9 ccimpact_cause_locgov
	rename ccimpact_cause_oth_10 ccimpact_cause_natgov
	rename ccimpact_cause_oth_11 ccimpact_cause_none
	
	egen ccimpact_cause_oth_tot = rowtotal(ccimpact_cause_nature ccimpact_cause_god ccimpact_cause_forces ccimpact_cause_myvill ccimpact_cause_othvill ccimpact_cause_tz ccimpact_cause_othppl ccimpact_cause_othgov ccimpact_cause_locgov ccimpact_cause_natgov)
	


	rename cc_impact_problems ccimpact_problems_oth

/* Crosstabs */
	tab ccimpact_betterworse

	foreach var of varlist ccimpact_problems_*{
		di "`var'"
		tab `var' resp_gender, col
	}

	tab ccimpact_cause_main

	tab ccimpact_cause_oth

	foreach var of varlist ccimpact_cause_* {
		di "`var'"
		tab `var' resp_gender, col
	}
*/

/* Gender Equality  ____________________________________________________________*/

/* Cleaning */
	recode s6q1		(2=1 "Wont cause problems")(1=0 "Will cause problems"), gen(ge_equalearningok)

	*recode s6q2	(2=1 "Boys = Girls")(1=0 "Boys > Girls"), gen(ge_schooling)
	recode s6q5 	(2=1 "Boys = Girls")(1=0 "Boys > Girls"), gen(ge_jobs)
	recode s6q3 	(1=1 "Women just as good")(2=0 "Women not as good"), gen(ge_leadership)
	recode s6q4		(1=1 "Women just as good")(2=0 "Women not as good"), gen(ge_business)
	
	destring section_6_dur, replace

/* Crosstabs */
	foreach var of varlist ge_* {
		di "`var'"
		tab `var' resp_gender, col
	}

	tab vac_attitude
	tab vac_attitude_stick
	tab ipv_attitudes

	sum section_6_dur


/* Crime and Police ____________________________________________________________*/

/* Cleaning */
	rename section_17_dur duration_crime

	recode s17q1 (1=1 "Probably criminal")(2=0 "Maybe not criminal"), gen(crime_probcriminal)

	recode s17q2 (5 = 4 "Not at all likely")(3=3 "Somewhat likely")(2=2 "Likely")(1=1 "Very likely"), gen(crime_likelyaccused)
					
	recode s17q3 (1=1 "Beat theif")(2 = 0 "Leave to police")(3 4= .), gen(crime_whistle_man)
	recode s17q4 (1=1 "Beat theif")(2 = 0 "Leave to police")(3 4= .), gen(crime_whistle_woman)

/* Crosstabs */
	foreach var of varlist crime_* {
		di "`var'"
		tab `var' resp_gender, col
	}


/* Boda Boda - Citizens ________________________________________________________*/

/* Cleaning */
	* Aware GBV
	rename s4q5		bbctz_gbv_aware

	* Report GBV
	rename rich_nothing_txt 		t_bbctz_report_rich
		replace t_bbctz_report_rich = "Rich" if t_bbctz_report_rich == "rich"
		replace t_bbctz_report_rich = "Not Rich" if t_bbctz_report_rich == ""
		lab var t_bbctz_report_rich "T: Predator Rich/Not"
		
	rename young_old_rand_txt 		t_bbctz_report_age
		replace t_bbctz_report_age = "Boda Guy" if t_bbctz_report_age == "boda boda driver"
		replace t_bbctz_report_age = "Old Guy" if t_bbctz_report_age == "older man"
		replace t_bbctz_report_age = "Young Guy" if t_bbctz_report_age == "younger man"
		lab var t_bbctz_report_age "T: Predator Age"
		
	rename school_drop_txt 			t_bbctz_report_school
		replace t_bbctz_report_school = "School" if t_bbctz_report_school == "in secondary school"
		replace t_bbctz_report_school = "No School" if t_bbctz_report_school != "School"
		lab var t_bbctz_report_school "T: Victim School Status"
		
	rename give_promise_txt 		t_bbctz_report_promise
		replace t_bbctz_report_promise = "Money" if t_bbctz_report_promise == "he gives her money"
		replace t_bbctz_report_promise = "Marry" if t_bbctz_report_promise == "he has promised her he will marry her"
		replace t_bbctz_report_promise = "Famous" if t_bbctz_report_promise == "he is a famous person in the village"
		lab var t_bbctz_report_promise "T: Predator Promise"
		
	rename him_her_txt	   			t_bbctz_report_gender
		replace t_bbctz_report_gender = "Female" if t_bbctz_report_gender == "her"
		replace t_bbctz_report_gender = "Male" if t_bbctz_report_gender == "him"
		lab var t_bbctz_report_gender "T: Reporter Gender"
		
	rename s4q6		bbctz_report
		lab def report_new 1 "Police" 2 "No Action" 3 "Talk Girl" 4 "Religious" 5 "Parents" 6 "Matron/Patron" 8 "Wait" 9 "Vill Leader" 10 "Teacher"
		lab val bbctz_report report_new

	* Norms GBV
	rename s4q8		bbctz_report_norm
		lab val bbctz_report_norm report_new

	* Believe in Justice
	rename wealthy_nothing_txt		t_bbctz_belief_wealthy
		replace t_bbctz_belief_wealthy = "Wealthy" if t_bbctz_belief_wealthy == "wealthy"
		replace t_bbctz_belief_wealth = "Not wealthy" if t_bbctz_belief_wealthy == ""
	
	rename young_old3_rand_txt		t_bbctz_belief_age 
		replace  t_bbctz_belief_age = "Boda Guy" if  t_bbctz_belief_age == "boda boda driver"
		replace  t_bbctz_belief_age = "Old Guy" if  t_bbctz_belief_age == "older man"
		replace  t_bbctz_belief_age = "Young Guy" if  t_bbctz_belief_age == "younger man"

	recode s4q10	(1=0 "Go free")(2=1 "Punished"), gen(bbctz_belief)

	* Go to Court
	rename transport_rand_txt	t_bbctz_court_cost
		replace t_bbctz_court_cost = "0 TZS" if t_bbctz_court_cost == "The court will cover the transport fees"
		replace t_bbctz_court_cost = "2K TZS" if t_bbctz_court_cost == "the transport fees will cost 2,000"
		replace t_bbctz_court_cost = "5K TZS" if t_bbctz_court_cost == "the transport fees will cost 5,000"
	rename s4q11				bbctz_gocourt

	* BB Safe
	rename age3_rand_txt		t_bbctz_bbsafe_age
		lab var t_bbctz_bbsafe_age "Girl Age"

	recode s4q12				(0=0 "BB Unsafe")(1=1 "BB Safe"), gen(bbctz_bbsafe)

	foreach var of varlist bbctz_* {
		recode `var' (-999 = .d)(-888 = .r)
	}

/* Cross Tabs */
	tab bbctz_gbv_aware resp_gender, col

	tab bbctz_report resp_gender, col 

	foreach covar of varlist t_bbctz_report_* {
		tab bbctz_report `covar', col	
	}

	foreach covar of varlist t_bbctz_report_* {
		tab bbctz_report_norm `covar', col
	}

	tab bbctz_gocourt resp_gender, col
	tab bbctz_gocourt t_bbctz_court_cost, col
	
	tab bbctz_belief resp_gender, col 

	foreach covar of varlist t_bbctz_belief_* {
			di "`var'"
			tab bbctz_belief `covar', col
		}

	tab bbctz_bbsafe resp_gender, col
	tab bbctz_bbsafe t_bbctz_bbsafe_age, col

/* Boda Boda - Drivers ________________________________________________________*/

/* Cleaning */
	rename bb_transport_rand_txt 	t_bb_court_cost
		replace t_bb_court_cost = "0 TZS" if t_bb_court_cost == "The court will cover the transport fees"
		replace t_bb_court_cost = "2K TZS" if t_bb_court_cost == "the transport fees will cost 2,000"
		replace t_bb_court_cost = "5K TZS" if t_bb_court_cost == "the transport fees will cost 5,000"
	
	lab val bb_report report_new
		
	rename bb_npa bb_npa_aware
	
	replace bb_npa_attend = 0 if bb_npa_aware == 0 

	foreach var of varlist bb_* {
		cap recode `var' (-999 = .d)(-888 = .r)
	}
	
/* Crosstabs */
	tab bb_years
	tab bb_own 
	cap tab bb_awareness
	tab bb_request
	tab bb_request_norm
	tab bb_report 
	tab bb_court t_bb_court_cost, col
	tab bb_npa_aware
	tab bb_npa_attend
	tab bb_npa_attend_wouldya


/* Media Consumption ___________________________________________________________

Needed to change codeing, will go through this later same as previous survey

*/

/* Cleaning */
	rename s7q10_news			radio_news
	rename s7q2_listen_radio	radio_2wk

	recode radio_2wk (0 = 0 "Never")(1 2 3 = 1 "Some")(-888 = .r)(-999 = .d),gen(radio_any_2wk)

	rename s7q3_radio_3month	radio_any_3mon
	replace radio_any_3mon = 1 if radio_any_2wk == 1

	rename s7q6_listen_sm				radio_stations
		rename s7q6_listen_sm_1			radio_stations_voa
		rename s7q6_listen_sm_2			radio_stations_tbc
		rename s7q6_listen_sm_3			radio_stations_efm
		rename s7q6_listen_sm_4			radio_stations_breeze
		rename s7q6_listen_sm_5			radio_stations_pfm
		rename s7q6_listen_sm_6			radio_stations_clouds
		rename s7q6_listen_sm_7			radio_stations_rmaria
		rename s7q6_listen_sm_8			radio_stations_rone
		rename s7q6_listen_sm_9			radio_stations_huruma
		rename s7q6_listen_sm_10		radio_stations_mwambao
		rename s7q6_listen_sm_11		radio_stations_wasafi
		rename s7q6_listen_sm_12		radio_stations_nuru
		rename s7q6_listen_sm_13		radio_stations_uhuru
		rename s7q6_listen_sm_14		radio_stations_bbc
		rename s7q6_listen_sm_15		radio_stations_sya
		rename s7q6_listen_sm_16		radio_stations_tk
		rename s7q6_listen_sm_17		radio_stations_freeafrica
		cap rename s7q6_listen_sm_18		radio_stations_tbctaifa
		cap rename s7q6_listen_sm_19		radio_stations_abood
		cap rename s7q6_listen_sm_20		radio_stations_imani
		cap rename s7q6_listen_sm_21		radio_stations_kiss
		

	rename s7q7a_uhuru		radio_uhuru
	rename s7q7_panganifm	radio_pfm

	rename s7q8_programs_sm 			radio_pfm_shows
		rename s7q8_programs_sm_1		radio_pfm_shows_couples
		rename s7q8_programs_sm_2		radio_pfm_shows_soap
		rename s7q8_programs_sm_3		radio_pfm_shows_leaders
		rename s7q8_programs_sm_4		radio_pfm_shows_women
		rename s7q8_programs_sm_5		radio_pfm_shows_youth
	lab val radio_pfm_shows_* listen

	gen radio_accurate = .
		replace radio_accurate = s7q11_after if s7q11_after != .
		replace radio_accurate = s7q11_before if s7q11_before != .
		
	gen t_radio_accurate_after = 0 if s7q11_before != .
		replace t_radio_accurate_after = 1 if s7q11_after != .
		
	rename radio_rand_txt				t_radio_owner_station
	replace t_radio_owner_station = "Uhuru FM" if t_radio_owner_station == "Uhuru"

	destring s7q12_sm, replace
	*recode s7q12_sm (1 = 1 "Government")(2 = 2 "CCM")(3 = 3 "Private")(4 = 4 "NGO")(5 = 5 "Local")(-999 = 0 "Prompted DK"), gen(radio_owner)
	
	rename s7q12_sm_follow 				radio_owner_gov

	gen radio_owner_dk = (radio_owner == 0)
	lab var radio_owner_dk "(Unprompted) Dont know radio owner"
	
	destring section_16_dur, replace
	
	rename radio_accurate radio_inaccurate
	recode radio_inaccurate (4 = 1 "Very not accurate")(3 = 2 "Not accuarate")(2 = 3 "Accurate")(1 = 4 "Very accurate")(-999 = .d "Dont know"), gen(radio_accurate)

	foreach var of varlist radio_* {
		di "`var'"
		cap recode `var' (-999 = .d)(-888 = .r)
	}

/* Crosstabs 
	tab radio_accurate t_radio_accurate_after, col
	bys t_radio_owner_station : tabstat radio_accurate, by(t_radio_accurate_after)
	bys radio_any_2wk: tab radio_owner t_radio_owner_station, col
	bys radio_uhuru: tab radio_owner t_radio_owner_station, col
	bys radio_pfm: tab radio_owner t_radio_owner_station, col	
	sum section_16_dur
*/
/* Climate Change Awareness ____________________________________________________*/

/* Cleaning */
	* Heard of climate change 
	rename cc_meaning_1 cc_meaning_neg
	rename cc_meaning_2 cc_meaning_pos 
	rename cc_meaning_3 cc_meaning_oth
	rename cc_meaning__999 cc_meaning_dk
	rename cc_meaning_4 cc_meaning_unsure

	gen cc_meaning_correct = cc_meaning_neg
		replace cc_meaning_correct = 0 if cc_aware == 0
	
	/* This causes question has gotten messed around with a lot */
	foreach num of numlist 1/11 {
		cap gen cc_causeold_`num' = cc_cause_`num' if date_txt == "date2021-11-03"
		cap replace cc_causeold_`num' = cc_cause_`num' if date_txt == "date2021-11-04"
		replace cc_cause_`num' = . if date_txt == "date2021-11-03"
		replace cc_cause_`num' = . if date_txt == "date2021-11-04"
	}

	foreach num of numlist 999 888 {
		gen cc_causeold__`num' = cc_cause__`num' if date_txt == "date2021-11-03"
		replace cc_causeold__`num' = cc_cause__`num' if date_txt == "date2021-11-04"
		replace cc_cause__`num' = . if date_txt == "date2021-11-03"
		replace cc_cause__`num' = . if date_txt == "date2021-11-04"
	}

	rename cc_cause_1 cc_cause_nature
	rename cc_cause_2 cc_cause_god
	rename cc_cause_3 cc_cause_forces
	rename cc_cause_4 cc_cause_myvill
	rename cc_cause_5 cc_cause_othvill
	rename cc_cause_6 cc_cause_tz
	rename cc_cause_7 cc_cause_othppl
	rename cc_cause_8 cc_cause_othgov
	rename cc_cause_9 cc_cause_locgov
	rename cc_cause_10 cc_cause_natgov
	rename cc_cause_11 cc_cause_none
	
	foreach var of varlist cc_cause_* {
		tab `var' cc_treat, col
	}

	gen cc_cause_correct = 1 if cc_cause_othppl == 1 | cc_cause_othgov == 1 | cc_cause_tz == 1 | cc_cause_myvill == 1 | cc_cause_othvill == 1 | cc_cause_tz == 0 | cc_cause_othppl == 1 | cc_cause_othgov == 1 | cc_cause_locgov == 1 | cc_cause_natgov == 1
	replace cc_cause_correct = 0 if cc_cause_correct == .
	replace cc_cause_correct = 0 if cc_aware == 0

	rename cc_causeold_1 cc_causeold_haventheard
	rename cc_causeold_2 cc_causeold_humans 
	rename cc_causeold_3 cc_causeold_nature 
	rename cc_causeold_4 cc_causeold_humansnature 
	rename cc_causeold_5 cc_causeold_none 
	rename cc_causeold__999 cc_causeold_dontknow 
	rename cc_causeold__888 cc_causeold_refuse 
	
	recode cc_cause2 (1 -999 = 0 "Havent heard enough / DK")(3 = 1 "God or Nature")(4 = 2 "Human activity + Nature")(2 = 3 "Human activity"), gen(cc_cause_new)
	replace cc_cause_correct = 1 if cc_cause2 == 3 | cc_cause2 == 2
	replace cc_cause_correct = 0 if cc_cause2 == 0 | cc_cause2 == 1

gen cc_causeold_correct = cc_causeold_humans 
	replace cc_cause_correct = 1 if cc_causeold_humansnature == 1
	replace cc_cause_correct = 0 if cc_aware == 0 


* On Nov 4, we had "statement 1 (econ)", coded 1 and "statement 2 (enviro)", code 2
recode cc_priority (2  = 1)(1 = 0) if date_txt == "date2021-11-04"
* On Nov 5, we had (statement 1 (econ)", coded 0 and "statement 2 (enviro), coded 1"
recode cc_priority (2  = 1)(1 = 0) if date_txt == "date2021-11-05"
* Here
recode cc_priority (3 4 7 11 = 1)

lab def cc_priority 1 "Environment" 0 "Economy", replace
lab val cc_priority cc_priority

lab def cc_efficacy_community 0 "A lot" 1 "A little" 2 "Nothing" -333 "Not a prob" -999 "DK" -888 "Refuse", replace
lab val cc_efficacy_community cc_efficacy_community
recode cc_efficacy_community (0 1 = 1 "A lot / A little")(2 -333 -999 = 0 "Nothing / Not Important"), gen(cc_efficacy_community_dum)

replace cc_cause_outside = 0 if cc_aware == 0

recode cca_report_fish (2 = 0)
recode cca_report_fire (2 = 0)
lab def cc_report 1 "Report" 0 "Dont report"
lab val cca_report_fish cc_report
lab val cca_report_fire cc_report

foreach var of varlist cc_* {
	cap recode `var' (-999 = .d)(-888 = .r)
} 

egen cca_report_index = rowmean(cca_report_fish cca_report_fire)


	/* Crosstabs */
	encode cc_treat, gen(sb_cc)
		recode sb_cc (1 = 1 "cc_usa")(2 = 2 "cc_world")(3 = 0 "control"), gen(t_cc)
		drop sb_cc 
		
	gen t_cc_simple = 1 if t_cc == 1 | t_cc == 2
		replace t_cc_simple = 0 if t_cc == 0

	tab cc_aware cc_treat, col
	tab cc_meaning_correct cc_treat, col
	tab cc_cause_correct cc_treat, col
	tab cc_cause_outside cc_treat, col
	tab cc_efficacy_community_dum cc_treat, col m
	tab cc_priority cc_treat, col m
	tab cca_report_index cc_treat, col
	reg cca_report_index i.t_cc
	tab cca_report_fish cc_treat, col
	tab cca_report_fire cc_treat, col
	
	tab cca_firewood cc_treat, col
	tab cca_firewood_norm cc_treat, col


	foreach var of varlist cc_aware cc_meaning_correct cc_cause_correct cc_cause_outside cc_priority cc_efficacy_community_dum cca_firewood cca_firewood_norm cca_report_fish cca_report_fire cca_report_index {
		di "**** `var' ******"
		reg `var' i.t_cc svy_coast resp_gender
	} 

	
/* Feeling Thermometer _________________________________________________________*/

foreach var of varlist thermo_* {
	recode `var' (-999 = .d)(-888 = .r)
	replace `var' = `var' * 5
}

	/* Crosstabs */
	sum thermo_city
	sum thermo_chinese
	sum thermo_bodaboda
	sum thermo_muslims
	sum thermo_americans
	sum thermo_christians

	tabstat thermo_chinese, by(cc_treat)
	tabstat thermo_americans, by(cc_treat)

	destring section_thermometer_dur, replace
	sum section_thermometer_dur

	
/* Climate Change Actions ______________________________________________________*/

tab cca_meetings_attend cc_treat, col
	replace cca_meetings_attend = 0 if cca_meetings_any == 0
tab cca_meeetings_speakout resp_gender, col
	replace cca_meeetings_speakout = 0 if cca_meetings_attend == 0
rename cca_meeetings_speakout cca_meetings_speakout

	/* Crosstabs */
	foreach var of varlist cca_* {
		tab `var' resp_gender, col
	}
  
/* WPP Attitude ________________________________________________________________*/

	/* Clean */
	foreach var of varlist wpp_attitude wpp_norm wpp_behav_girl wpp_behav_boy {
		replace `var' = . if date_txt == "date2021-11-09" // clips were not working
	}
	
	
	/* Crosstabs */
	lab def wpp 1 "Most men" 2 "Most women" 3 "Equal"
	lab val wpp_attitude wpp 
	lab val wpp_norm wpp
	
	recode wpp_attitude (1 = 0 "Men") (2 3 = 1 "Equal/Women"), gen (wpp_attitude_dum)
	recode wpp_norm (1 = 0 "Men") (2 3 = 1 "Equal/Women"), gen (wpp_norm_dum)
	
	clonevar wpp_treat_corel = wpp_treat
		replace wpp_treat_corel = "both" if wpp_treat_corel == "wpp_ustadhpriest"
		replace wpp_treat_corel = "diwani" if wpp_treat_corel == "wpp_diwani"
		replace wpp_treat_corel = "citzien" if wpp_treat_corel == "wpp_citizen"

		replace wpp_treat_corel = "coreligion" if wpp_treat_corel == "wpp_ustadh" & resp_religion == 3
		replace wpp_treat_corel = "coreligion" if wpp_treat_corel == "wpp_priest" & ///
																		(resp_religion == 2 ///
																		| resp_religion == 4 ///
																		| resp_religion == 6 ///
																		| resp_religion == 7 ///
																		| resp_religion == 10)
		replace wpp_treat_corel = "noncoreligion" if wpp_treat_corel == "wpp_priest" & resp_religion == 3
		replace wpp_treat_corel = "noncoreligion" if wpp_treat_corel == "wpp_ustadh" & ///
																		(resp_religion == 2 ///
																		| resp_religion == 4 ///
																		| resp_religion == 6 ///
																		| resp_religion == 7 ///
																		| resp_religion == 10)	
		
		encode wpp_treat_corel, gen(sb_t_wpp)	
		recode sb_t_wpp (1 = 6 "both")(2 = 1 "citizen")(3 = 0 "control")(4 = 4 "coreligion")(5 = 2 "diwani")(6 = 3 "noncoreligion"), gen(t_wpp)
		
	tab wpp_attitude_dum wpp_treat_corel, col
	tab wpp_norm_dum wpp_treat_corel, col
	tab wpp_behav_girl wpp_treat_corel, col
	tab wpp_behav_boy wpp_treat_corel, col

	foreach var of varlist wpp_attitude_dum wpp_norm_dum wpp_behav_girl wpp_behav_boy {
		reg `var' i.t_wpp 
	}

/* Dev News ____________________________________________________________________*/
/*
replace dev_posterior2 = 0 if dev_posterior3 == 0 & dev_posterior3_no == 1
replace dev_posterior2 = 1 if dev_posterior3 == 0 & dev_posterior3_no == 0
replace dev_posterior2 = 3 if dev_posterior3 == 1 & dev_posterior3_yes == 0
replace dev_posterior2 = 4 if dev_posterior3 == 1 & dev_posterior3_yes == 1
*/
foreach var of varlist dev_prior2 dev_posterior2 {
	recode `var' (-999 = .d)(-888 = .r)
}

lab def dev_contribute 0 "Dont contribute" 1 "Contribute", replace
lab val dev_contribute dev_contribute 

foreach type in ngo natgov locgov businesses ccm {
	recode dev_attitude_`type'2 (-888 = .)
	recode dev_attitude_`type'2 (0 1 2 -999 = 0 "Don't Approve")( 3 4 = 1 "Approve"), gen(dev_attitude_`type'2_dum)
}

recode dev_responsibility (5 = 1 "National")(1 2 3 4 = 0 "Not national")(-999 = .d)(-888 = .r)(-222 = .o), gen(dev_responsibility_natgov)
recode dev_responsibility (2 3 = 1 "Local")(1 4 5 = 0 "Not local")(-999 = .d)(-888 = .r)(-222 = .o), gen(dev_responsibility_locgov)
recode dev_responsibility (1 = 1 "Citizens")(2 3 4 5 = 0 "Government")(-999 = .d)(-888 = .r)(-222 = .o), gen(dev_responsibility_vill)

egen dev_attitude_gov = rowmean(dev_attitude_natgov2_dum dev_attitude_ccm2_dum)

recode dev_prior2 (-999 = .d)(0 1 = 0 "No")(2 3 4 = 1 "Yes"), gen(dev_prior2_dum)
recode dev_posterior2 (-999 = .d )(0 1 = 0 "No")(2 3 4 = 1 "Yes"), gen(dev_posterior2_dum)

recode dev_speakout (0 = 1)(1 = 0)
lab def speakout 1 "Speak out" 0 "Don't speak out"
lab val dev_speakout speakout


/* Crosstabs */
	
	encode dev_treat, gen(sb_dev)
		recode sb_dev (1 = 0 "control")(2 = 2 "no response")(3 = 1 "gov response"), gen(t_dev)
	
	recode sb_dev (1 = . )(2 = 0 "no response")(3 = 1 "gov response"), gen(t_dev2)

	tab dev_posterior2_dum dev_treat, col
	
	tab dev_attitude_natgov2 dev_treat, col
	tab dev_attitude_ccm2 dev_treat, col

	bys dev_prior2_dum: tab dev_attitude_gov dev_treat, col
	tab dev_attitude_natgov2_dum dev_treat, col
	tab dev_attitude_locgov2_dum dev_treat, col
	tab dev_attitude_ccm2_dum dev_treat, col
	
	tab dev_contribute dev_treat, col
	tab dev_speakout dev_treat, col

	tab dev_responsibility dev_treat, col
	tab dev_responsibility_locgov dev_treat, col
	tab dev_responsibility_natgov dev_treat, col
	tab dev_responsibility_vill dev_treat, col

	tab dev_vote dev_treat, col
	
	foreach var of varlist 	dev_posterior2_dum ///
							dev_attitude_gov ///
							dev_attitude_natgov2_dum ///
							dev_attitude_locgov2_dum ///
							dev_attitude_ccm2_dum ///
							dev_attitude_ngo2_dum ///
							dev_attitude_businesses2_dum ///
							dev_contribute ///
							dev_speakout ///
							dev_responsibility_natgov ///
							dev_responsibility_vill {
		
		di "***** `var'"
		reg `var' i.t_dev2 

	}


/* EFM _________________________________________________________________________*/

tab fm_attitude_1
tab fm_attitude_2
tab fm_attitude_3

tab em_attitude_religion
tab em_attitude_pregnant


/* WPP - Economic Participation ________________________________________________

Something is messed up here

*/

/* Clean */

replace coupleswork_treat = "Neg" if coupleswork_treat == "coupleswork_neg"
replace coupleswork_treat = "Pos" if coupleswork_treat == "coupleswork_pos"

recode coupleswork_water (2 3 4 6 = 1 "Equal/Progressive") ///
						 (1 5 = 0 "Conservative"), ///
						gen(coupleswork_water_dum) 
		lab var coupleswork_water_dum "[1 = prog/bal] Who in HH is responsible for water?"
		
recode coupleswork_laundry  (2 3 4 6 = 1 "Equal/Progressive") ///
							(1 5 = 0 "Conservative"), ///
							gen(coupleswork_laundry_dum) 
		lab var coupleswork_laundry_dum "[1 = prog/bal] Who in HH is responsible for laundry?"
		
recode coupleswork_kids  	(2 3 4 6 = 1 "Equal/Progressive") ///
							(1 5 = 0 "Conservative"), ///
							gen(coupleswork_kids_dum) 
		lab var coupleswork_kids_dum "[1 = prog/bal] Who in HH is responsible for kids?"

recode coupleswork_money (1 3 5 6 = 1 "Equal/Progressive") ///
						 (2 4 = 0 "Conservative"), ///
						 gen(coupleswork_money_dum) 
		lab var coupleswork_money_dum "[1 = prog/bal] Who in HH is responsible for money?"
		
egen coupleswork_makemoney = rowmean(coupleswork_makemoney1 coupleswork_makemoney2 coupleswork_makemoney3 coupleswork_makemoney4)
egen coupleswork_chores = rowmean(coupleswork_water_dum coupleswork_laundry_dum coupleswork_kids_dum)


/* Coupels work */
tab coupleswork_makemoney coupleswork_treat, col
bys resp_gender: tab coupleswork_makemoney coupleswork_treat, col

tab coupleswork_money_dum coupleswork_treat, col
bys resp_gender: tab coupleswork_money_dum coupleswork_treat, col

tab coupleswork_consult coupleswork_treat, col
bys resp_gender: tab coupleswork_consult coupleswork_treat, col


tab coupleswork_chores coupleswork_treat, col
tab coupleswork_kids_dum coupleswork_treat, col
tab coupleswork_water_dum coupleswork_treat, col
tab coupleswork_laundry_dum coupleswork_treat, col



/* couples conflict */
rename couplesconflict_treat conflict_treat

rename couplesconflict_behavior_male_1 conflict_behavior_male_hhh
rename couplesconflict_behavior_male_2 conflict_behavior_male_hit
rename couplesconflict_behavior_male_3 conflict_behavior_male_pt
rename couplesconflict_behavior_male_4 conflict_behavior_male_nice
rename couplesconflict_behavior_male_5 conflict_behavior_male_rel
rename couplesconflict_behavior_male_6 conflict_behavior_male_vill
rename couplesconflict_behavior_male_7 conflict_behavior_male_prnts


foreach var of varlist conflict_behavior_male_* {
	di "`var'"
	tab `var'
	tab `var' conflict_treat, col
}



tab conflict_behavior_male_pt conflict_treat, col
tab conflict_behavior_male_nice conflict_treat, col

rename couplesconflict_behavior_female_ conflict_behavior_fem_listen 
rename v330 conflict_behavior_fem_shout 
rename v331 conflict_behavior_fem_talk	  
rename v332 conflict_behavior_fem_nice  
rename v333 conflict_behavior_fem_rel  
rename v334 conflict_behavior_fem_vill  
rename v335 conflict_behavior_fem_par  
rename v336 other 

foreach var of varlist conflict_behavior_fem_* {
	di "`var'"
	tab `var'
	tab `var' conflict_treat, col
}


recode couplesconflict_beliefs (2 = 1 "Mans Fault")(1 = 0 "Womans Fault"), gen(conflict_beliefs)
recode couplesconflict_norm (2 = 1 "Mans Fault")(1 = 0 "Womans Fault"), gen(conflict_norms)
recode couplesconflict_atttude1 (2 = 1 "Stand up")(1 = 0 "Give in"), gen(conflict_attitudes1)

tab conflict_beliefs conflict_treat, col
tab conflict_norms conflict_treat, col
tab conflict_attitudes1 conflict_treat, col
tab ipv_attitudes conflict_treat, col


bys resp_gender: tab conflict_beliefs conflict_treat, col
bys resp_gender: tab conflict_norms conflict_treat, col
bys resp_gender: tab conflict_attitudes1 conflict_treat, col
bys resp_gender: tab ipv_attitudes conflict_treat, col

* Save _________________________________________________________________________*/

	save "${data}/02_mid_data/pfm_cm_2_2021_clean.dta", replace
											
				
				

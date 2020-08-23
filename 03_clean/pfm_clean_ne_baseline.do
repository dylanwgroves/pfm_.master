/* Background -----------------------------------------------------------------
Project: Wellspring Tanzania, Natural Experiment
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/18
*/


/* Introduction ---------------------------------------------------------------*/
clear all
clear matrix
clear mata
set more off
version 15 
set maxvar 30000



/* Open -----------------------------------------------------------------*/
use "${data}\01_raw_data\03_surveys\pfm_ne_baseline_nopii.dta", clear

/* Labels */
lab def yesnodkr 0 "No" 1 "Yes" -999 "Dont Know" -888 "Refuse"

* Converting don't know/refuse/other to extended missing values
qui ds, has(type numeric)
recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

/* Drop */
drop deviceid subscriberid simid devicephonenum starttime endtime skipto* idstring time_*

/* Identifiers */
egen resp_id = concat(villstring id), punct(_)
gen village_c = village
gen ward_c = ward
gen district_c = district


/* Section 0: Consent ---------------------------------------------------------*/
rename audio_consent s0q1_consent_audio
rename consent s0q2_consent
rename enum_string s0q3_enumerator


/* Section 1: Background ------------------------------------------------------*/
rename date_time s1q1_date 
rename enum s1q2_enum
rename district s1q5_district
rename ward s1q6_ward
rename village s1q7_village
rename tracking s1q10_visits


/* Section 2: Respondent Information -------------------------------------------*/
rename sex_q2_1 s2q1_gender

rename day_q2_2 s2q2_howudoin
gen s2q2_goodday = s2q2_howudoin
recode s2q2_goodday (3=0)(2=1)(1=0)
lab var s2q2_goodday "Particularly good day today?"
lab val s2q2_goodday yesnodkr

rename age_q2_3 s2q3_age

* Head of household
rename rel_q2_4 s2q4_hhrltn
rename q2_4_oth s2q4_hhrltn_oth

gen s2q4_hhh = 1 if s2q4_hhrltn == 1
replace s2q4_hhh = 0 if s2q4_hhh == .
lab var s2q4_hhh "Head of Household?"
lab val s2q4_hhh yesnodkr

* Marital status
rename status_q2_5 s2q5_maritalstatus
rename q2_5_oth s2q5_maritalstatus_oth

gen s2q5_married = 1 if s2q5_maritalstatus == 1
replace s2q5_married  = 0 if s2q5_married  == .
lab var s2q5_married "Married?"
lab val s2q5_married yesnodkr

* Household members
rename members_q2_6 s2q6_numhh	

* Household members breakdown
rename child_q2_7 s2q7a_numkid
gen s2q7b_numadult = s2q6_numhh - s2q7a_numkid
								
rename older_q2_8 s2q8_numolder 

rename younger_q2_9 s2q9_numyounger

* Born
rename born_q2_10 s2q10_kidsever	
rename bornalive_q2_11 s2q11_bornalive

* Years in Village
rename vilyrs_q2_12 s2q12_yrsvill

* Know in village
rename vilnum_q2_13 s2q12_villknow
gen s2q12_villknow_all  = 1 if s2q12_villknow == 1 | s2q12_villknow == 2
replace s2q12_villknow_all = 0 if s2q12_villknow_all  == .

* Big city
rename big_city_q2_14 s2q14_bigcity
tab s2q14_bigcity

* Same village
rename vill16_q2_15 s2q16_samevillage

* Travel
rename travel_q2_17 s2q17_travel3hr

* Education					
rename edu_q2_18 s2q18_education
gen s2q18_standard7  = 1 if s2q18_education > 7
replace s2q18_standard7 = 0 if s2q18_standard7 == .
lab var s2q18_standard7 "At least standard 7 education?"
lab val s2q18_standard7 yesnodkr

* Read 
gen s2q19_readwrite = read_q2_19a if s2q18_education < 8								
replace s2q19_readwrite = read_q2_19b if s2q18_education > 7 
lab def readwrite -999 "Don't Know" -888 "Refuse" 1 "Read only" 2 "Write and read" 3 "Write only" 4 "None"
lab val s2q19_readwrite readwrite

gen s2q19a_literate = 1 if s2q19_readwrite == 2
replace s2q19a_literate = 0 if s2q19a_literate == .
lab var s2q19a_literate "Can read and write?"
lab val s2q19a_literate yesnodkr

* Language 
rename lang_q2_20 s2q20_lang_main
rename q2_20_oth s2q20_lang_main_oth
rename other_lang_q2_21 s2q21_lang_any													
split s2q21_lang_any
rename q2_21_oth s2q21_lang_any_oth

gen s2q21_lang_swahili = 1 if s2q20_lang_main == 1
replace s2q21_lang_any = subinstr(s2q21_lang_any, "10", "ten",.)				// Don't want to double count 10
replace s2q21_lang_swahili  = 1 if strpos(s2q21_lang_any, "1")
replace s2q21_lang_swahili = 0 if s2q21_lang_swahili == . 
lab var s2q21_lang_swahili "Respondent speaks Swahili?"
lab def yesno 1 "Yes" 0 "No"
lab val s2q21_lang_swahili yesno

/* Section 3 - Media & Activities ---------------------------------------------*/

* Activities
rename activity_q3_1 s3q1_activity
rename q3_1_oth s3q1_activity_oth

* Free time
rename free_time_q3_2 s3q2_freetime

	* Change strings to avoid double counting
	replace s3q2_freetime = subinstr(s3q2_freetime, "-222", "other",.)
	replace s3q2_freetime = subinstr(s3q2_freetime, "-999", "dk",.)
	replace s3q2_freetime = subinstr(s3q2_freetime, "-888", "refuse",.)

	* Free time dummies
	foreach act in rest bar sportwatch sportplay tv cell radio community other dk ref {
		gen s3q2_freetime_`act' = 0
		lab var s3q2_freetime_`act' "[`act'] Free time usage"
	}

	* Replace if any of the splitting responses match
	replace s3q2_freetime_rest = 1 	if strpos(s3q2_freetime, "1")
	replace s3q2_freetime_bar = 1 if strpos(s3q2_freetime, "2")
	replace s3q2_freetime_sportwatch = 1 	if strpos(s3q2_freetime, "3")
	replace s3q2_freetime_sportplay = 1 if strpos(s3q2_freetime, "4")
	replace s3q2_freetime_tv = 1 	if strpos(s3q2_freetime, "5")
	replace s3q2_freetime_cell = 1 if strpos(s3q2_freetime, "6")
	replace s3q2_freetime_radio = 1 if strpos(s3q2_freetime, "7")
	replace s3q2_freetime_community = 1 if strpos(s3q2_freetime, "8")
	replace s3q2_freetime_other = 1 if strpos(s3q2_freetime, "other")
	replace s3q2_freetime_dk = 1 if strpos(s3q2_freetime, "dk")
	replace s3q2_freetime_ref = 1 if strpos(s3q2_freetime, "refuse")

* Conversations
rename convers_q3_3 s3q3_converse

	* Change strings to avoid double counting
	replace s3q3_converse = subinstr(s3q3_converse, "-999", "dk",.)
	replace s3q3_converse = subinstr(s3q3_converse, "-888", "refuse",.)

	* Dummy for community conversations
	foreach conv in elec ipv discr vote water teachers dk ref {
		gen s3q3_converse_`conv' = 0
		lab var s3q3_converse_`conv' "[`conv'] Discussion with Community"
	}

	* Replace if any of the splitting responses match
	replace s3q3_converse_elec = 1 	if strpos(s3q3_converse, "1")
	replace s3q3_converse_ipv = 1 if strpos(s3q3_converse, "2")
	replace s3q3_converse_discr = 1 if strpos(s3q3_converse, "3")
	replace s3q3_converse_vote = 1 if strpos(s3q3_converse, "4")
	replace s3q3_converse_water = 1 if strpos(s3q3_converse, "5")
	replace s3q3_converse_teach = 1 if strpos(s3q3_converse, "6")
	replace s3q3_converse_dk = 1 if strpos(s3q3_converse, "dk")
	replace s3q3_converse_ref = 1 if strpos(s3q3_converse, "refuse")

* TV
rename watchtv_q4_1 s4q1_tv	
gen s4q1_tv_any = 0 if s4q1_tv == 6
replace s4q1_tv_any = 1 if s4q1_tv_any == .
lab var s4q1_tv_any  "Any TV Yesterday?"
lab val s4q1_tv_any  yesnodkr

* Radio
rename radio_q4_2 s4q2_radio  														
replace s4q2_radio = 0 if s4q2_radio == 6										// Change value of "None" from 6 to 0
replace s4q2_radio = . if s4q2_radio  == -888 | s4q2_radio  == -999
lab def s4q2_radio  0 "None", modify

* Cell
rename cell_q4_3 s4q3_cell

* Radio time
rename radiotime_q4_4 s4q4_radiotime

* Radio programs
rename radioprogram_q4_5 s4q5_radioprograms

	* Change strings to avoid double counting
	replace s4q5_radioprograms = subinstr(s4q5_radioprograms, "-999", "dk",.)
	replace s4q5_radioprograms = subinstr(s4q5_radioprograms, "-222", "other",.)
	replace s4q5_radioprograms = subinstr(s4q5_radioprograms, "-888", "refuse",.)

	* Types of Radio programs	
	foreach conv in music sport news romance social relig dk ref {
		gen s4q5_radioprograms_`conv' = 0
		lab var s4q5_radioprograms_`conv' "[`conv'] Types of radio programs"
	}

	* Replace if any of the splitting responses match
	replace s4q5_radioprograms_music = 1 if strpos(s4q5_radioprograms, "1")
	replace s4q5_radioprograms_sport = 1 if strpos(s4q5_radioprograms, "2")
	replace s4q5_radioprograms_news = 1 if strpos(s4q5_radioprograms, "3")
	replace s4q5_radioprograms_romance = 1 if strpos(s4q5_radioprograms, "4")
	replace s4q5_radioprograms_social = 1 if strpos(s4q5_radioprograms, "5")
	replace s4q5_radioprograms_relig = 1 if strpos(s4q5_radioprograms, "6")
	replace s4q5_radioprograms_dk = 1 if strpos(s4q5_radioprograms, "dk")
	replace s4q5_radioprograms_ref = 1 if strpos(s4q5_radioprograms, "refuse")

rename radioprogram_q4_5_oth s4q5_radioprograms_oth

* Rado Stations
rename radiostation_q4_6 s4q6_radiostations
rename radioprogram_q4_6_oth s4q6_radiostations_oth

* Radio communication
rename radiocomm_q4_7 s4q7_radiocommunity

* Radio news
rename news_q4_8 s4q8_radionews


/* Section 5: Living Conditions -----------------------------------------------*/
* Living Conditions
gen s5q1_livecond = .
	replace s5q1_livecond = 0 if living_worse_q5_1a == 3
	replace s5q1_livecond = 1 if living_worse_q5_1a == 2
	replace s5q1_livecond = 2 if living_worse_q5_1a == 1
	replace s5q1_livecond = 3 if living_worse_q5_1a == 2
	replace s5q1_livecond = 4 if living_better_q5_1b == 1
	replace s5q1_livecond = 5 if living_better_q5_1b == 2
	replace s5q1_livecond = 6 if living_better_q5_1b == 3
	replace s5q1_livecond = .d if living_cond_q5_1 == -999
	replace s5q1_livecond = .r if living_cond_q5_1 == -888
drop living_worse* living_better* living_cond*

* Future 
gen s5q2_future = .
	replace s5q2_future = 0 if future_worse_q5_2a == 3
	replace s5q2_future = 1 if future_worse_q5_2a == 2
	replace s5q2_future = 2 if future_worse_q5_2a == 1
	replace s5q2_future = 3 if future_worse_q5_2a == 2
	replace s5q2_future = 4 if future_better_q5_2b == 1
	replace s5q2_future = 5 if future_better_q5_2b == 2
	replace s5q2_future = 6 if future_better_q5_2b == 3
	replace s5q2_future = .d if future_q5_2 == -999
	replace s5q2_future = .r if future_q5_2 == -888
drop future_*

/* Section 6: Values ---------------------------------------------------------*/
rename help_q6_1 s6q1_help

rename newold_q6_2a s6q2_likechange
	replace s6q2_likechange = 0 if s6q2_likechange == 1
	replace s6q2_likechange = 1 if s6q2_likechange == 2
	replace s6q2_likechange = .d if s6q2_likechange == -999
lab def change 0 "Do things as they have been done" 1 "Try new things"
lab val s6q2_likechange change

rename money_q6_2b s6q2b_money
	replace s6q2b_money = 0 if s6q2b_money == 1
	replace s6q2b_money = 1 if s6q2b_money == 2
	replace s6q2b_money = .d if s6q2b_money == -999
lab def money 0 "Should try to save for future" 1 "Ok to spend"
lab val s6q2b_money money

rename tech_q6_3 s6q3_techgood													
	replace s6q3_techgood = 0 if s6q3_techgood == 1										
	replace s6q3_techgood = 1 if s6q3_techgood == 2
	replace s6q3_techgood = .d if s6q3_techgood == -999
lab def tech 0 "Bad - give people bad ideas" 1 "Great - show new things"
lab val s6q3_techgood tech


/* Section 7: Gender Hierarchy ------------------------------------------------*/

** Gender Hierarchy
rename achiever_q7_1 s7q1_gh_noeqkid 
recode s7q1_gh_noeqkid (0 = 1) (1 = 0)
lab var s7q1_gh_noeqkid "[REVERSED] 7.1)  A husband and wife should [NOT] both participate equally in raising children."

rename kneel_q7_3 s7q2_gh_dadpickhusband

rename woman_earns_q7_3 s7q3_gh_eqearnbad
lab val s7q3_gh_eqearnbad yesnodkr

rename women_school_q7_4 s7q4_gh_prefboyschool

rename women_leaders_q7_5 s7q5_gh_femlead
recode s7q5_gh_femlead (0 = 1) (1 = 0) (-999 = .d)
lab var s7q5_gh_femlead "[REVERSED] 6.4) Do you trust a woman leader to bring development to the community?"

recode familyprop_q7_7  (1 = 1) (2 = 0) (3 = 0) (4 = 1) (5 = 0) (6 = 0), gen(s7q7_gh_boypref)
lab def moreboy 1 "Preference for boys" 0 "No preference for boys" -999 "Don't Know" -888 "Refuse" 
lab val s7q7_gh_boypref moreboy 
lab var s7q7_gh_boypref "[Preference for boys] 6.5) Ideally, what proportion of them would you like to be boys?"

drop familysize* familyprop*

** Child marriage
destring randomdraw78or79, replace												// Changed Prices 

	* Treatment Variables
	gen s7q8_fm_t_scen = 1 if randomdraw78or79 <= 0.5
	replace s7q8_fm_t_scen = 0 if randomdraw78or79 > 0.5
	lab def moneyprobs 1 "Money problem" 0 "Daughter problem"
	lab val s7q8_fm_t_scen  moneyprobs
	lab var s7q8_fm_t_scen "[Randomized] Money problem or daughter problem situation"

	gen s7q8_fm_t_age = txt1
	lab var s7q8_fm_t_age "[Randomized] Age of daughter"

	gen s7q8_fm_t_outsidevill = 0 if txt2 == "ndani ya kijiji chao"
	replace s7q8_fm_t_outsidevill = 1 if txt2 == "nje ya kijiji chao"
	lab def outside 0 "Inside village" 1 "Inside village"
	lab val s7q8_fm_t_outsidevill outside 
	lab var s7q8_fm_t_outsidevill "[Randomized] Suitor from outside / inside the village"

	gen s7q8_fm_t_amnt = txt3
	lab var s7q8_fm_t_amnt "[Randomized] Amount offered"

	gen s7q8_fm_t_son = 0 if txt4 == "yeye"
	replace s7q8_fm_t_son = 1 if txt4 == "kijana wake wa kiume"
	lab def son 0 "him" 1 "his son"
	lab val s7q8_fm_t_son son 
	lab var s7q8_fm_t_son "[Randomized] Father or son"
	
	gen s7q8_fm_t_daughterissue = 1 if txt5 == "anafeli shuleni"
	replace s7q8_fm_t_daughterissue = 2 if txt5 == "ni vigumu kumdhibiti nyumbani"
	replace s7q8_fm_t_daughterissue = 3 if txt5 == "yuko kwenye hatari ya kupata mimba"
	lab def daughter 1 "Failing at school" 2 "Hard to control" 3 "At risk of pregnancy"
	lab val s7q8_fm_t_daughterissue daughter 
	lab var s7q8_fm_t_daughterissue "[Randomized] Challenge with daughter"
	
	drop txt*

	* Responses
	gen s7q8_fm_okself = friends_marry_q7_8a if randomdraw78or79 < 0.5
	replace s7q8_fm_okself = friends_marry_q7_9a if randomdraw78or79 > 0.5
	recode s7q8_fm_okself (1 = 0) (2 = 1)
	lab def fmok 0 "No, a family should never allow their daughter to marry at ${txt1} years old because she is too young too marry" 1 "Yes, a family should marry their daughter if they are offered ${txt3} shillings"
	lab val s7q8_fm_okself fmok
	lab var s7q8_fm_okself "[Vignette] EFM Acceptable?"
	
	gen s7q9_fm_okcomm = community_marry_q7_8b if randomdraw78or79 < 0.5
	replace s7q9_fm_okcomm = community_marry_q7_9b if randomdraw78or79 > 0.5
	recode s7q9_fm_okcomm (2 = 1) (1 = 0)
	lab val s7q9_fm_okcomm fmok
	lab var s7q9_fm_okcomm "[Vignette] Community thinks EFM Acceptable?"
	
	
/* Section 8: IPV -------------------------------------------------------------*/

* IPV Reporting
rename report_q8_1a_1 s8q1_ipv_police
replace s8q1_ipv_police = select_one_q8_1a_2 if s8q1_ipv_police == .

rename report_q8_1b_1 s8q1_ipv_vc
replace s8q1_ipv_vc = select_one_q8_1b_2 if s8q1_ipv_vc == .

rename report_q8_1c_1 s8q1_ipv_parents
replace s8q1_ipv_parents = select_one_q8_1c_2 if s8q1_ipv_parents == .

rename report_q8_1d_1 s8q1_ipv_femleader
replace s8q1_ipv_femleader = select_one_q8_1d_2 if select_one_q8_1d_2 == .

gen ipv_conatt_report = s8q1_ipv_police + s8q1_ipv_vc + s8q1_ipv_parents + s8q1_ipv_femleader
lab var ipv_conatt_report "[Sum of 4] Would you report instance of abuse?"

* IPV Acceptability
rename disobeys_q8_2a s8q2a_ipv_disobey

rename disobeys_yes_q8_2a_1 s8q2a1_ipv_hithard
replace s8q2a1_ipv_hithard = 0 if s8q2a_ipv_disobey == 0
recode s8q2a1_ipv_hithard (1 = 0) (2 = 1)
lab def hithard 0 "Slapped or less" 1 "More force"
lab val s8q2a1_ipv_hithard hithard

rename disobeys_no_q8_2a_1 s8q2a2_ipv_persists											// this has been missing for early varibales
replace s8q2a2_ipv_persists = 1 if s8q2a_ipv_disobey == 1

rename chat_q8_2b s8q2b_gossip
rename unfaithful_q8_2c s8q2c_cheats
rename children_q8_2d s8q2d_kids
rename housework_q8_2e s8q3e_housework

rename hit_community_q8_3 s8q3_ipv_communityaccept

rename family_together_q8_4 s8q4_ipv_wifereact

rename react_community_q8_5 s8q5_ipv_commreact

rename slap_law_q8_6 s8q6_ipv_knowlaw


/* Section 9 Citizenship --------------------------------------------------------*/

** Values
gen s9q1a_respectauthority = citizens_q9_1a_1
recode s9q1a_respectauthority (1 = 2) (2 = 1)
replace s9q1a_respectauthority  = citizens_q9_1a_2 if s9q1a_respectauthority == .
recode s9q1a_respectauthority (2 = 0)
lab def authority 0 "Citizens should be more active in questioning the actions of leaders" 1 "Citizens should show more respect for authority"
lab val s9q1a_respectauthority authority 
drop citizens_q9_1a*

gen s9q1b_individualism = government_q9_1b_1
recode s9q1b_individualism (2 = 1) (1 = 2)
replace s9q1b_individualism  = government_q9_1b_2 if s9q1b_individualism == .
recode s9q1b_individualism (2 = 0)
lab def individual 0 "Government is responsible for welfare" 1 "People are responsible for own well-being"
lab val s9q1b_individualism individual
drop government_q9_1b_1*

rename elders_q9_2a s9q2a_elders

rename property_q9_2b s9q2b_propoerty											// This is a hierarchy question

** Civic Enagement
rename comgov_q9_3a s9q3a_ca
rename contgov_q9_3b s9q3b_contactgov
rename contgov_q9_3c s9q3c_leaderlisten

/* Section 10 Teacher Absenteeism --------------------------------------------------------*/
* DROPPING FOR NOW BECAUSE IRRELEVANT
drop fire_teach_q10_1a pta_q10_2a fire_teach_q10_1b pta_q10_2b fire_teach_q10_1c pta_q10_2c fire_teach_q10_1d pta_q10_2d teachers_q10_3

/* Section 11 Police ----------------------------------------------------------*/
* DROPPING FOR NOW BECAUSE IRRELEVANT
drop robbed_police_q11_1 audio_sec12

/* Section 12: Abortion --------------------------------------------------------*/
drop involved_q12_1 involved_comm_q12_2 mother_health_q12_3a married_q12_3b raped_q12_3c turnback_q12_4

/* Section 13: Religion --------------------------------------------------------*/
rename religion_q13_1 s13q1_religion
rename q13_1_oth s13q1_religion_other
tab s13q1_religion

gen s13q1_christian = 1 if 		s13q1_religion == 2 | s13q1_religion == 4 | ///
								s13q1_religion == 5 | s13q1_religion == 6 | ///
								s13q1_religion == 7 | s13q1_religion == 8 | ///
								s13q1_religion == 9 | s13q1_religion == 10 | ///
								s13q1_religion_other == "Pentecost"
replace s13q1_christian = 0 if s13q1_religion == .
lab var s13q1_christian "Christian or Muslim"
lab def religion 0 "Muslim" 1 "Christian"
lab val s13q1_christian religion

rename religion_times_q13_2 s3q2_rel_attend

/* Section 14: Witchcraft and Police ------------------------------------------*/
* DROPPING FOR NOW BECAUSE NOT INCLUDED
drop witches_q14_1a witches_q14_1b randomdraw9 truck_q14_2a truck_q14_2b truck_beat1 truck_police1 randomdraw10 group_punish_q14_3a group_punish_q14_3b


/* Section 15: Housing --------------------------------------------------------*/

** Housing
rename dwelling_q15_1 s15q1_house_type
rename q15_1_oth s15q1_house_type_oth

gen s15q1a_multiplehuts = 1 if s15q1_house_type == 1
replace s15q1a_multiplehuts = 0 if s15q1_house_type == .
lab var s15q1a_multiplehuts  "Multiple huts in compound?"
lab val s15q1a_multiplehuts  yesnodkr

rename  rooms_q15_2 s15q2_house_rooms

rename walls_q15_3 s15q3_house_walls
lab def s11q3 11 "Mud and Sticks", add
rename q15_3_oth s15q3_house_walls_oth

gen s15q3a_mudwalls = s15q3_house_walls
recode s15q3a_mudwalls (1=1) (2 = 1) (3 = 0) (4 = 0) (5 = 0) (7 = 0) (11 = 1)
replace s15q3a_mudwalls = 0 if s15q3_house_walls == -222

rename roof_q15_4 s15q4_house_roof
rename q15_4_oth s15q4_house_roof_oth

rename floor_q15_5 s15q5_house_floor
rename q15_5_oth s15q5_house_floor_oth

rename light_q15_6 s15q6_house_light
rename q15_6_oth s15q6_house_light_oth

rename fuel_q15_7 s15q7_house_fuel
rename q15_7_oth s15q7_house_fuel_oth

rename kitchen_q15_8 s15q8_house_kitchen
rename water_q15_9 s15q9_house_water

/* Section 16: Assetts --------------------------------------------------------*/
rename radio_q16_1a s16q1_radio

rename radio_q16_1b_1 s16q1a_rad_num
recode s16q1a_rad_num (. = 0)	

rename radio_q14_1b_2 s16q1b_rad_wouldaccept

rename tv_q16_2 s16q2_tv
rename cellphone_q16_3 s16q3_cell
rename cellpone_internet_q16_3a s16q3a_cellinternet
replace s16q3a_cellinternet = 0 if s16q3_cell == 0
rename cellphone_battery_q16_3b s16q3b_cellbattery
replace s16q3b_cellbattery = 0 if s16q3_cell == 0
replace s16q3b_cellbattery = s16q3b_cellbattery / (60*60)
replace s16q3b_cellbattery = s16q3b_cellbattery / 60

rename chair_q16_4 s16q4_chair
rename sofa_q16_5 s16q5_sofa
rename table_q16_6 s16q6_table
rename motor_q16_7 s16q7_motorcycle
rename light_q16_8 s16q8_lantern


/* Survey Relationship ---------------------------------------------------------*/
rename person_q17_1 s17q1_svy_others

rename relationship_person_q17_2 s17q1_svy_others_who

rename followup_q17_3 s17q3_followup

rename observe_conditions_q17_4 s17q4_conditions

/* Drop -------------------------------------------------------------------------*/
drop q*


* Save -------------------------------------------------------------------------
save "${data}\02_mid_data\pfm_ne_baseline_clean.dta", replace
											
				
				
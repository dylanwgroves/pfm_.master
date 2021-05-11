/* Background -----------------------------------------------------------------
Project: Wellspring Tanzania, Natural Experiment
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/18
*/


/* Introduction ________________________________________________________________*/

clear all
clear matrix
clear mata
set more off
version 15 
set maxvar 30000


/* Load Data ________________________________________________________________*/

use "${data}/01_raw_data/03_surveys/pfm_ne_baseline_nopii.dta", clear


/* Labels _______________________________________________________________________*/

	lab def yesnodkr 0 "No" 1 "Yes" -999 "Dont Know" -888 "Refuse"
	lab def yesno 0 "No" 1 "Yes"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def reject_cat 0 "Always Acceptable" 1 "Sometimes Acceptable" 2 "Never Acceptable"

	
/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

	
/* Drop ________________________________________________________________________*/

	drop deviceid subscriberid simid devicephonenum starttime endtime skipto* idstring time_*

/* Survey Information __________________________________________________________*/

	/* Identifier */
	egen resp_id = concat(villstring id), punct(_)
	gen village_c = village
	gen ward_c = ward
	gen district_c = district

	
	/* Survey Information */
	rename audio_consent svy_consent_audio
	rename consent svy_consent
	rename enum_string svy_enum_string
	rename date_time svy_date 
	rename enum svy_enum
	rename district svy_district
	rename ward svy_ward
	rename village svy_village
	rename tracking svy_visits


/* Respondent Information ______________________________________________________*/

	rename sex_q2_1 resp_female
		recode resp_female (2=1)(1=0)
		lab val resp_female yesno
	
	rename day_q2_2 resp_howudoin
	
	gen resp_goodday = resp_howudoin
	recode resp_goodday (3=0)(2=1)(1=0)
	lab var resp_goodday "Particularly good day today?"
	lab val resp_goodday yesnodkr

	rename age_q2_3 resp_age
	lab var resp_age "Age"

	* Head of household
	rename rel_q2_4 resp_hhrltn
	rename q2_4_oth resp_hhrltn_oth

	gen resp_hhh = 1 if resp_hhrltn == 1
	replace resp_hhh = 0 if resp_hhh == .
	lab var resp_hhh "Head of Household?"
	lab val resp_hhh yesnodkr

	* Marital status
	rename status_q2_5 resp_maritalstatus
	rename q2_5_oth resp_maritalstatus_oth

	gen resp_married = 1 if resp_maritalstatus == 1
	replace resp_married  = 0 if resp_married  == .
	lab var resp_married "Married?"
	lab val resp_married yesnodkr

	* Household members
	rename members_q2_6 resp_numhh	

	* Household members breakdown
	rename child_q2_7 resp_numkid
	gen resp_numadult = resp_numhh - resp_numkid
									
	rename older_q2_8 resp_numolder 

	rename younger_q2_9 resp_numyounger

	* Born
	rename born_q2_10 resp_kidsever	
	rename bornalive_q2_11 resp_bornalive

	* Years in Village
	rename vilyrs_q2_12 resp_yrsvill

	* Know in village
	rename vilnum_q2_13 resp_villknow
	gen resp_villknow_all  = 1 if resp_villknow == 1 | resp_villknow == 2
	replace resp_villknow_all = 0 if resp_villknow_all  == .

	* Big city
	rename big_city_q2_14 resp_bigcity

	* Same village
	rename vill16_q2_15 resp_samevillage

	* Travel
	rename travel_q2_17 resp_travel3hr

	* Education					
	rename edu_q2_18 resp_education
	gen resp_standard7  = 1 if resp_education > 7
	replace resp_standard7 = 0 if resp_standard7 == .
	lab var resp_standard7 "At least standard 7 education?"
	lab val resp_standard7 yesnodkr

	* Read 
	gen resp_readwrite = read_q2_19a if resp_education < 8								
	replace resp_readwrite = read_q2_19b if resp_education > 7 
	lab def readwrite -999 "Don't Know" -888 "Refuse" 1 "Read only" 2 "Write and read" 3 "Write only" 4 "None"
	lab val resp_readwrite readwrite

	gen resp_literate = 1 if resp_readwrite == 2
	replace resp_literate = 0 if resp_literate == .
	lab var resp_literate "Can read and write?"
	lab val resp_literate yesnodkr

	* Language 
	rename lang_q2_20 resp_lang_main
	rename q2_20_oth resp_lang_main_oth
	rename other_lang_q2_21 resp_lang_any													
		split resp_lang_any
		rename q2_21_oth resp_lang_any_oth

	gen resp_lang_swahili = 1 if resp_lang_main == 1
	replace resp_lang_any = subinstr(resp_lang_any, "10", "ten",.)				// Don't want to double count 10
	replace resp_lang_swahili  = 1 if strpos(resp_lang_any, "1")
	replace resp_lang_swahili = 0 if resp_lang_swahili == . 
	lab var resp_lang_swahili "Respondent speaks Swahili?"
		lab val resp_lang_swahili yesno

/* Section 3 - Media & Activities ______________________________________________*/

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
	rename radio_q4_2 radio_listen														
	replace radio_listen = 0 if radio_listen == 6										// Change value of "None" from 6 to 0
	replace radio_listen = . if radio_listen == -888 | radio_listen == -999
	lab def radio_listen  0 "None", modify

	gen radio_any = 1 if radio_listen > 0
		replace radio_any = 0 if radio_listen == 0

	* Cell
	rename cell_q4_3 media_cell

	* Radio time
	rename radiotime_q4_4 radio_time

	* Radio programs
	rename radioprogram_q4_5 radio_programs

		* Change strings to avoid double counting
		replace radio_programs = subinstr(radio_programs, "-999", "dk",.)
		replace radio_programs = subinstr(radio_programs, "-222", "other",.)
		replace radio_programs = subinstr(radio_programs, "-888", "refuse",.)

		* Types of Radio programs	
		foreach conv in music sport news romance social relig dk ref {
			gen radio_programs_`conv' = 0
			lab var radio_programs_`conv' "[`conv'] Types of radio programs"
		}

		* Replace if any of the splitting responses match
		replace radio_programs_music = 1 if strpos(radio_programs, "1")
		replace radio_programs_sport = 1 if strpos(radio_programs, "2")
		replace radio_programs_news = 1 if strpos(radio_programs, "3")
		replace radio_programs_romance = 1 if strpos(radio_programs, "4")
		replace radio_programs_social = 1 if strpos(radio_programs, "5")
		replace radio_programs_relig = 1 if strpos(radio_programs, "6")
		replace radio_programs_dk = 1 if strpos(radio_programs, "dk")
		replace radio_programs_ref = 1 if strpos(radio_programs, "refuse")

	rename radioprogram_q4_5_oth radio_programs_oth

	* Rado Stations
	rename radiostation_q4_6 radio_stations
		gen radio_stations_pfm = (radio_stations == 4)

	* Radio communication
	rename radiocomm_q4_7 radio_community
		replace radio_community = 0 if radio_any == 0

	* Radio news
	rename news_q4_8 radio_news


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

/* Section 6: Values ____________________________________________________________*/

	rename help_q6_1 values_help

	rename newold_q6_2a values_likechange
		replace values_likechange = 0 if values_likechange == 1
		replace values_likechange = 1 if values_likechange == 2
		replace values_likechange = .d if values_likechange == -999
	lab def change 0 "Do things as they have been done" 1 "Try new things"
	lab val values_likechange change

	rename money_q6_2b values_money
		replace values_money = 0 if values_money == 1
		replace values_money = 1 if values_money == 2
		replace values_money = .d if values_money == -999
	lab def money 0 "Should try to save for future" 1 "Ok to spend"
	lab val values_money money

	rename tech_q6_3 values_techgood													
		replace values_techgood = 0 if values_techgood == 1										
		replace values_techgood = 1 if values_techgood == 2
		replace values_techgood = .d if values_techgood == -999
	lab def tech 0 "Bad - give people bad ideas" 1 "Great - show new things"
	lab val values_techgood tech


/* Forced Marriage _____________________________________________________________*/

	rename kneel_q7_3 fm_reject
		recode fm_reject (0=1)(1=0)
		lab var fm_reject "[REVERSED] A woman should not have a say in who she marries"
		lab val fm_reject agree
		
/* Gender Equality _____________________________________________________________*/

	rename achiever_q7_1 ge_raisekids

	rename woman_earns_q7_3 ge_earning
		recode ge_earning (0=1)(1=0)
		lab val ge_earning yesnodkr

	rename women_school_q7_4 ge_school
		recode ge_earning (0=1)(1=0)
	
	rename women_leaders_q7_5 ge_leadership
	
	recode familyprop_q7_7  (1 = 0) (2 = 1) (3 = 1) (4 = 0) (5 = 1) (6 = 1), gen(ge_noprefboy)
		lab def moreboy 0 "Preference for boys" 1 "No preference for boys" 
		lab val ge_noprefboy moreboy 
		lab var ge_noprefboy "[No preference for boys] 6.5) Ideally, what proportion of them would you like to be boys?"

	drop familysize* familyprop*
	
			lab var ge_raisekids "A husband and wife should both participate equally in raising children."
			lab var ge_earning "[Reversed] it always causes problem when a woman earns more than a man"
			lab var ge_leadership "In general, women make equally good village leaders as men"
			lab var ge_noprefboy "[No preference for boys] 6.5) Ideally, what proportion of them would you like to be boys?"
			
			lab var ge_raisekids agree
			lab var ge_earning agree
			lab var ge_leadership agree
			
	egen ge_index = rowmean(ge_raisekids ge_earning ge_leadership ge_noprefboy)

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
		lab def outside 0 "Inside village" 1 "Outisde village"
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
		gen em_reject_story = friends_marry_q7_8a if randomdraw78or79 < 0.5
			replace em_reject_story = friends_marry_q7_9a if randomdraw78or79 > 0.5
		recode em_reject_story (1 = 1) (2 = 0)
		lab val em_reject_story reject
		lab var em_reject_story "[Vignette] Reject EFM?"
		
		gen em_norm_reject = community_marry_q7_8b if randomdraw78or79 < 0.5
			replace em_norm_reject = community_marry_q7_9b if randomdraw78or79 > 0.5
		recode em_norm_reject (2 = 1) (1 = 0)
		lab val em_norm_reject reject
		lab var em_norm_reject "[Vignette] Community Reject EFM?"
	
	
/* Section 8: IPV ______________________________________________________________*/

	* IPV Reporting
	rename report_q8_1a_1 ipv_report_police
		replace ipv_report_police = select_one_q8_1a_2 if ipv_report_police == .

	rename report_q8_1b_1 ipv_report_vc
		replace ipv_report_vc = select_one_q8_1b_2 if ipv_report_vc == .
	
	rename report_q8_1c_1 ipv_report_parents
		replace ipv_report_parents = select_one_q8_1c_2 if ipv_report_parents == .

	rename report_q8_1d_1 ipv_report_femleader
		replace ipv_report_femleader = select_one_q8_1d_2 if ipv_report_femleader == .

	gen ipv_report_index = ipv_report_police + ipv_report_vc + ipv_report_parents + ipv_report_femleader
		lab var ipv_report_index "[Sum of 4] Would you report instance of abuse?"

	* IPV Reject
	rename disobeys_q8_2a ipv_rej_disobey
		recode ipv_rej_disobey (0=1)(1=0)
		lab val ipv_rej_disobey reject

	rename disobeys_yes_q8_2a_1 ipv_rej_hithard
		recode ipv_rej_hithard (2=1)(1=0)
		replace ipv_rej_hithard = 1 if ipv_rej_disobey == 1

	rename disobeys_no_q8_2a_1 ipv_rej_persists											// this has been missing for early varibales
		replace ipv_rej_persists = 1 if ipv_rej_disobey == 1

	rename chat_q8_2b ipv_rej_gossip
	rename unfaithful_q8_2c ipv_rej_cheats
	rename children_q8_2d ipv_rej_kids
	rename housework_q8_2e ipv_rej_work
	
	foreach ipv of varlist ipv_rej_gossip ipv_rej_cheats ipv_rej_kids ipv_rej_work {
		replace `ipv' = .d if `ipv' == -999
		replace `ipv' = .r if `ipv' == -888
		recode `ipv' (1=0)(0=1)
		lab val `ipv' reject	
	}
	
	egen ipv_rej_index = rowmean(ipv_rej_gossip ipv_rej_cheats ipv_rej_kids ipv_rej_work)


	rename hit_community_q8_3 ipv_norm_rej
		recode ipv_norm_rej (0=1)(1=0)
		lab val ipv_norm_rej reject

	rename family_together_q8_4 ipv_wifereact
	rename react_community_q8_5 ipv_commreact
	rename slap_law_q8_6 ipv_knowlaw


/* Section 9 Citizenship _______________________________________________________*/

	/* Values */
	gen values_respectauthority = citizens_q9_1a_1
	recode values_respectauthority (1 = 2) (2 = 1)
	replace values_respectauthority  = citizens_q9_1a_2 if values_respectauthority == .
	recode values_respectauthority (2 = 0)
	lab def authority 0 "Citizens should be more active in questioning the actions of leaders" 1 "Citizens should show more respect for authority"
	lab val values_respectauthority authority 
	drop citizens_q9_1a*

	gen values_individualism = government_q9_1b_1
	recode values_individualism (2 = 1) (1 = 2)
	replace values_individualism  = government_q9_1b_2 if values_individualism == .
		recode values_individualism (2 = 0)
		lab def individual 0 "Government is responsible for welfare" 1 "People are responsible for own well-being"
		lab val values_individualism individual
		drop government_q9_1b_1*

	rename elders_q9_2a values_elders

	rename property_q9_2b values_property										// This is a hierarchy question

	/* Civic Enagement */
	rename comgov_q9_3a ptixpart_collact
	rename contgov_q9_3b ptixpart_contactgov
	rename contgov_q9_3c ptixpart_leaderlisten



/* Section 13: Religion --------------------------------------------------------*/

	rename religion_q13_1 resp_religion
	rename q13_1_oth resp_religion_other
	tab resp_religion

	gen resp_muslim = 0 if 			resp_religion == 2 | resp_religion == 4 | ///
									resp_religion == 5 | resp_religion == 6 | ///
									resp_religion == 7 | resp_religion == 8 | ///
									resp_religion == 9 | resp_religion == 10 | ///
									resp_religion_other == "Pentecost"
	replace resp_muslim = 1 if resp_muslim == .
	lab var resp_muslim "Muslim?"
	lab def religion 1 "Muslim" 0 "Christian"
	lab val resp_muslim religion

	rename religion_times_q13_2 resp_religiosity

/* Section 15: Housing --------------------------------------------------------*/

	/* Housing */
	rename dwelling_q15_1 asset_housetype
	rename q15_1_oth asset_housetype_oth

	gen asset_multiplehuts = 1 if asset_housetype == 1
	replace asset_multiplehuts = 0 if asset_housetype == .
	lab var asset_multiplehuts  "Multiple huts in compound?"
	lab val asset_multiplehuts  yesnodkr

	rename  rooms_q15_2 asset_rooms

	rename walls_q15_3 asset_walls
	lab def s11q3 11 "Mud and Sticks", add
	rename q15_3_oth asset_walls_oth

	gen asset_mudwalls = asset_walls
	recode asset_mudwalls (1=1) (2 = 1) (3 = 0) (4 = 0) (5 = 0) (7 = 0) (11 = 1)
	replace asset_mudwalls = 0 if asset_walls == -222

	rename roof_q15_4 asset_roof
	rename q15_4_oth asset_roof_oth

	rename floor_q15_5 asset_floor
	rename q15_5_oth asset_floor_oth

	rename light_q15_6 asset_light
	rename q15_6_oth asset_light_oth

	rename fuel_q15_7 asset_fuel
	rename q15_7_oth asset_fuel_oth

	rename kitchen_q15_8 asset_kitchen
	rename water_q15_9 asset_water

	/* Section 16: Assetts */
	rename radio_q16_1a asset_radio

	rename radio_q16_1b_1 asset_radio_num
	recode asset_radio_num (. = 0)	

	rename radio_q14_1b_2 asset_radio_accept

	rename tv_q16_2 asset_tv
	rename cellphone_q16_3 asset_cell
	rename cellpone_internet_q16_3a asset_cellinternet
		replace asset_cellinternet = 0 if asset_cell == 0
	rename cellphone_battery_q16_3b asset_cellbattery
		replace asset_cellbattery = 0 if asset_cell == 0
		replace asset_cellbattery = asset_cellbattery / (60*60)
		replace asset_cellbattery = asset_cellbattery / 60

	rename chair_q16_4 	asset_chair
	rename sofa_q16_5 	asset_sofa
	rename table_q16_6 	asset_table
	rename motor_q16_7 	asset_motorcycle
	rename light_q16_8 	asset_lantern
	
	rename observe_conditions_q17_4 asset_conditions

/* Survey Relationship _________________________________________________________*/
	
	rename person_q17_1 vy_others
		rename relationship_person_q17_2 svy_others_who

	rename followup_q17_3 svy_followup


/* Drop ________________________________________________________________________*/
	
	drop q*


* Save -------------------------------------------------------------------------
save "${data}/02_mid_data/pfm_ne_baseline_clean.dta", replace
											
				
				

/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Baseline Pilot Import and Cleaning
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This imports piloting data
_______________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	*version 15
	clear all
	set maxvar 30000
	set more off

	
/* Import Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_pii_as_baseline.dta", clear

	
/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def reject_cat 0 "Always Acceptable" 1 "Sometimes Acceptable" 2 "Never Acceptable"


/* Converting don't know/refuse/other to extended missing valuesv_______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)


/* Clean up _____________________________________________________________________*/

	drop subscriberid simid devicephonenum username duration rand_bc
	order cases_label fo


/* High Level Data ______________________________________________________________*/
	
	bysort fo: egen survey_num_fo = count(key)
	bysort s1q5 fo: egen survey_num_fovl = count(key)

	
/* Section 1: Background ________________________________________________________*/
	
	gen team = fo
	recode team (3 = 1) (4 = 0) (5 = 0) (9 = 1)(11 = 0)(12 = 1)(13 = 0)(14 = 1)(15 =0)(20 = 1)

	
/* Section 1: Background ________________________________________________________*/
	rename s1q1 s1q1_date
	rename s1q3 district_c
	rename district_name district_n
	rename s1q4 ward_c
	rename ward_name ward_n
	rename village_c_pull village_c
	rename village_name village_n
	rename id resp_c

	drop village_id_pull village

	rename s1q6 s1q9_subvillage
	rename s1q7 s1q10_visits

	
* Section 2: Respondent Information ____________________________________________*/
	rename s2q1 resp_gender															

	rename s2q2 resp_howudoin

	gen resp_goodday =  resp_howudoin
	recode resp_goodday (3=0)(2=1)(1=0)
	lab var resp_goodday "Particularly good day today?"
	lab val resp_goodday yesnodkr

	rename s2q3 resp_age
																
	rename s2q4 resp_hhrltn

	* Generate Head of Household Variable
	gen resp_hhh = 1 if resp_hhrltn == 1
	replace resp_hhh = 0 if resp_hhh == .
	lab var resp_hhh "Head of Household?"
	lab val resp_hhh yesnodkr
												
	rename s2q5 resp_maritalstatus

	* Generate Marital Status Variable
	gen resp_married = 1 if resp_maritalstatus == 1
	replace resp_married  = 0 if resp_married  == .
	lab var resp_married "Married?"
	lab val resp_married yesnodkr

	rename s2q6 resp_numhh	
															
	rename s2q7 resp_numkid
	gen resp_numadult = resp_numhh - resp_numkid

	rename s2q8 resp_numolder 

	rename s2q9 resp_numyounger

	rename s2q10 resp_kidsever	

	rename s2q12 resp_yrsvill																										

	rename s2q13 resp_villknow
	gen resp_villknow_all  = 1 if resp_villknow == 1 | resp_villknow == 2
	replace resp_villknow_all = 0 if resp_villknow_all  == .

	rename city_rand_txt resp_t_citytype
	rename s2q14a resp_livecity_dum
	rename s2q14b resp_livecity_num
	replace resp_livecity_num = 0 if resp_livecity_dum == 0
	rename time_txt resp_livecity_firstlast

	rename s2q14c resp_livecity_where
	rename s2q14c_oth resp_livecity_where_oth

	rename s2q15a resp_livecity_why
	rename s2q15a_oth resp_livecity_why_oth

	rename s2q15b resp_samevillage
										
	rename s2q16a resp_visit_city
	gen resp_nevervisitcity = 1 if resp_visit_city == 1
	replace resp_nevervisitcity = 0 if resp_nevervisitcity ==.
	lab var resp_nevervisitcity "Never visits city?"
	lab val resp_nevervisitcity  yesnodkr

	rename s2q16b resp_visit_town
	gen resp_nevervisittown = 1 if resp_visit_town == 1
	replace resp_nevervisittown = 0 if resp_nevervisittown ==.
	lab var resp_nevervisittown "Never visits town?"
	lab val resp_nevervisittown  yesnodkr
						
	rename s2q17 resp_education
	gen resp_standard7  = 1 if resp_education > 7
	replace resp_standard7 = 0 if resp_standard7 == .
	lab var resp_standard7 "At least standard 7 education?"
	lab val resp_standard7 yesnodkr

	rename s2q17_oth resp_education_oth

	gen resp_readwrite = s2q18a if resp_education < 8								
	replace resp_readwrite = s2q18b if resp_education > 7 
	lab def readwrite 1 "Read only" 2 "Write and read" 3 "Write only" 4 "None"
	lab val resp_readwrite readwrite

	gen resp_literate = 1 if resp_readwrite == 2
	replace resp_literate = 0 if resp_literate == .
	lab var resp_literate "Can read and write?"
	lab val resp_literate yesnodkr

	rename s2q19 resp_lang_main
	rename s2q19_oth resp_lang_main_oth
	rename s2q20_sm resp_lang_any													
	split resp_lang_any
	rename s2q20_sm_oth resp_lang_any_oth

	gen resp_lang_swahili = 1 if resp_lang_main == 1
	replace resp_lang_any = subinstr(resp_lang_any, "10", "ten",.)				// Don't want to double count 10
	replace resp_lang_swahili  = 1 if strpos(resp_lang_any, "1")
	replace resp_lang_swahili = 0 if resp_lang_swahili == . 
	lab var resp_lang_swahili "Respondent speaks Swahili?"
	lab val resp_lang_swahili yesno

	gen resp_lang_swahilimain = 1 if resp_lang_main == 1
	replace resp_lang_swahilimain = 0 if resp_lang_swahilimain == .
	lab var resp_lang_swahilimain "Swahili main language?"
	lab val resp_lang_swahilimain yesnodkr


* Section 3: Religion __________________________________________________________*/
	rename s3q1 resp_religion
	rename s3q1_oth respreligion_other	

	gen resp_muslim = 0 if 			resp_religion == 2 | resp_religion == 4 | ///
									resp_religion == 5 | resp_religion == 6 | ///
									resp_religion == 7 | resp_religion == 8 | ///
									resp_religion == 9 | resp_religion == 10
	replace resp_muslim = 0 if resp_muslim == .
	lab var resp_muslim "Muslim?"
	lab def religion 1 "Muslim" 0 "Christian"
	lab val resp_muslim religion

	rename s3q2 resp_religiosity
	replace resp_religiosity = .r if resp_religiosity == 999							
	replace resp_religiosity = .r if resp_religiosity == -999	
	replace resp_religiosity = .d if resp_religiosity == -888	

* Section 4: Media _____________________________________________________________*/

	rename s4q1 media_tv	
	gen media_tv_any = 0 if media_tv == 6
	replace media_tv_any = 1 if media_tv_any == .
	lab var media_tv_any  "Any TV Yesterday?"
	lab val media_tv_any  yesnodkr

	rename s4q2 radio_listen  														
	replace radio_listen = 0 if radio_listen == 6										// Change value of "None" from 6 to 0
	replace radio_listen = . if radio_listen == -888 | radio_listen == -999
	lab def s4q2 0 "None", modify
		
	rename s4q3 radio_any												
	replace radio_any = 1 if radio_listen > 0 & radio_listen < 6	
	replace radio_any = 0 if radio_any == .
	replace radio_any = 0 if radio_any == -999

	* Favorite Topics At Different Times of Day
	rename s4q6_sm_1 radio_time_morning												
	rename s4q6_sm_2 radio_time_noon
	rename s4q6_sm_3 radio_time_evening
	rename s4q6_sm_4 radio_time_late
/*
	foreach time in morn noon eve late {

	* Change strings to avoid double counting
	replace s4q6_radio`time' = subinstr(s4q6_radio`time', "10", "ten",.)			// Don't want to double count eg 1 and 10
	replace s4q6_radio`time' = subinstr(s4q6_radio`time', "11", "eleven",.)
	replace s4q6_radio`time' = subinstr(s4q6_radio`time', "-222", "other",.)
	replace s4q6_radio`time' = subinstr(s4q6_radio`time', "-999", "dk",.)
	replace s4q6_radio`time' = subinstr(s4q6_radio`time', "-888", "refuse",.)

	* Create dummy for each type of show in the morn								// High Frequency Check Ideas: (1) Number of options clicked by enumerator
	gen s4q6_radio`time'_music = 0													
	gen s4q6_radio`time'_sport = 0
	gen s4q6_radio`time'_news = 0
	gen s4q6_radio`time'_romance = 0
	gen s4q6_radio`time'_comm = 0
	gen s4q6_radio`time'_religion = 0
	gen s4q6_radio`time'_tech = 0
	gen s4q6_radio`time'_culture = 0
	gen s4q6_radio`time'_enviro = 0
	gen s4q6_radio`time'_econ = 0
	gen s4q6_radio`time'_weather = 0
	gen s4q6_radio`time'_dk = 0
	gen s4q6_radio`time'_refuse = 0

	* Replace if any of the splitting responses match
	replace s4q6_radio`time'_music = 1 	if strpos(s4q6_radio`time', "1")
	replace s4q6_radio`time'_sport = 1 if strpos(s4q6_radio`time', "2")
	replace s4q6_radio`time'_news = 1 	if strpos(s4q6_radio`time', "3")
	replace s4q6_radio`time'_romance = 1 if strpos(s4q6_radio`time', "4")
	replace s4q6_radio`time'_comm = 1 	if strpos(s4q6_radio`time', "5")
	replace s4q6_radio`time'_religion = 1 if strpos(s4q6_radio`time', "6")
	replace s4q6_radio`time'_tech = 1 if strpos(s4q6_radio`time', "7")
	replace s4q6_radio`time'_culture = 1 if strpos(s4q6_radio`time', "8")
	replace s4q6_radio`time'_enviro = 1 if strpos(s4q6_radio`time', "9")
	replace s4q6_radio`time'_weather = 1 if strpos(s4q6_radio`time', "10")
	replace s4q6_radio`time'_dk = 1 if strpos(s4q6_radio`time', "dk")
	replace s4q6_radio`time'_refuse = 1 if strpos(s4q6_radio`time', "refuse")	

	lab val s4q6_radio`time'_* yesnodkr

	egen s4q6_radio`time'_tot = rowtotal(s4q6_radio`time'_*)
	}

	* Total amount of listening for each radio type
	foreach radiotype in music sport news romance comm religion tech culture enviro weather dk refuse {
		egen s4q6_radio_`radiotype'_tot = rowtotal(s4q6_radiomorn_`radiotype' s4q6_radionoon_`radiotype' s4q6_radioeve_`radiotype' s4q6_radiolate_`radiotype')
		lab var s4q6_radio_`radiotype'_tot "Total times per day listen to `radiotype'"
	}
	egen s4q6_radtop_tot = rowtotal(s4q6_radiomorn_tot s4q6_radionoon_tot s4q6_radioeve_tot s4q6_radiolate_tot)
	label var s4q6_radtop_tot "Total radio topics reported listening to in morning, noon, evening, and night"
*/

	* 4.7 - Radio Stations												// HFC: Number of radio stations listened to
	rename s4q7_sm radio_stations																												
	replace radio_stations = subinstr(radio_stations, "-222", "other",.)	// Switch out subtrings 
	replace radio_stations = subinstr(radio_stations, "-999", "dontknow",.)
	replace radio_stations = subinstr(radio_stations, "-888", "refuse",.)
	replace radio_stations = subinstr(radio_stations, "10", "ten",.)		// Depending on how many radio stations there are, can keep adding these		
	replace radio_stations = subinstr(radio_stations, "11", "eleven",.)
	replace radio_stations = subinstr(radio_stations, "12", "twelve",.)
	replace radio_stations = subinstr(radio_stations, "13", "thirteen",.)
	replace radio_stations = subinstr(radio_stations, "14", "fourteen",.)

	* Create Dummy For stations														
	gen radio_stations_clouds = 0												
	gen radio_stations_tanga = 0
	gen radio_stations_voa = 0
	gen radio_stations_pfm = 0
	gen radio_stations_hisani = 0
	gen radio_stations_mwambao = 0
	gen radio_stations_radioone = 0
	gen radio_stations_tbc = 0
	gen radio_stations_safina = 0
	gen radio_stations_breeze = 0
	gen radio_stations_tk = 0
	gen radio_stations_catholic = 0
	gen radio_stations_radioafrica = 0
	gen radio_stations_dk = 0
																
	replace radio_stations_clouds = 1 if strpos(radio_stations, "1") 		 
	replace radio_stations_tanga = 1 if strpos(radio_stations, "2")
	replace radio_stations_voa = 1 if strpos(radio_stations, "3")
	replace radio_stations_pfm = 1 if strpos(radio_stations, "4")
	replace radio_stations_hisani = 1 if strpos(radio_stations, "5")
	replace radio_stations_mwambao = 1 if strpos(radio_stations, "6")
	replace radio_stations_radioone = 1 if strpos(radio_stations, "7")
	replace radio_stations_tbc = 1 if strpos(radio_stations, "8")
	replace radio_stations_safina = 1 if strpos(radio_stations, "9")
	replace radio_stations_breeze = 1 if strpos(radio_stations, "ten")
	replace radio_stations_tk = 1 if strpos(radio_stations, "eleven")
	replace radio_stations_catholic = 1 if strpos(radio_stations, "twelve")
	replace radio_stations_radioafrica = 1 if strpos(radio_stations, "thirteen")
	replace radio_stations_dk = 1 if strpos(radio_stations, "dontknow")
	lab val radio_stations_* yesnodkr												
	egen radio_stations_tot = rowtotal(radio_stations_*)	

	rename s4q8 radio_community	

	gen radio_community_ever = 0 if radio_community == 8
	replace radio_community_ever = 1 if radio_community_ever == .
	replace radio_community_ever = 0 if radio_any	 == 0
	replace radio_community_ever = .d if radio_community == -999
	lab var radio_community_ever "Ever listen to radio with community?"
	lab val radio_community_ever yesnodkr																									
	
	rename s4q9 media_news
	gen media_news_never = 1 if media_news == 1
		replace media_news_never = 0 if media_news_never == .
		lab var media_news_never  "Never listen to news or current events?"
		lab val media_news_never  yesnodkr

	gen media_news_daily = 1 if media_news == 5
		replace media_news_daily  = 0 if media_news_daily  == .
		lab var media_news_daily "Listen to news or current events every day?"
		lab val media_news_daily yesnodkr

	rename s4q10 radio_call
	gen radio_call_ever = 0 if radio_call == 1
	replace radio_call_ever = 1 if radio_call_ever == .
	lab var radio_call_ever "Ever call or text radio programs?"
	lab val radio_call_ever yesnodkr

			
* Section 5: General Values ____________________________________________________*/

	rename s5q1 values_likechange														
	replace values_likechange = 0 if values_likechange == 1
	replace values_likechange = 1 if values_likechange == 2
	replace values_likechange = .d if values_likechange == -999
	lab def change 0 "Do things as they have been done" 1 "Try new things"
	lab val values_likechange change

	rename s5q3 values_techgood														
	replace values_techgood = 0 if values_techgood == 1										
	replace values_techgood = 1 if values_techgood == 2
	replace values_techgood = .d if values_techgood == -999
	lab def tech 0 "Bad - give people bad ideas" 1 "Great - show new things"
	lab val values_techgood tech


/* Forced Married ______________________________________________________________*/

	rename s6q2 fm_reject
		recode fm_reject (0=1)(1=0)
		lab val fm_reject reject
		lab var fm_reject "[reversed] A father should choose daughter's husband"
		
		
* Section 6: Gender Hierarchy __________________________________________________*/

	rename s6q1 ge_raisekids

	rename s6q3 ge_earning
		recode ge_earning (1=0)(0=1)

	rename s6q4 ge_leadership

	rename s6q6 s6q5_gh_kidpref												
	recode s6q5_gh_kidpref	(1 = 0) (2 = 1) (3 = 1) (4 = 0) (5 = 1) (6 = 1), gen(ge_noprefboy)
		lab def moreboy 0 "Preference for boys" 1 "No preference for boys" 
		lab val ge_noprefboy moreboy 
		lab var ge_noprefboy "[No preference for boys] 6.5) Ideally, what proportion of them would you like to be boys?"

	lab var ge_raisekids "A husband and wife should both participate equally in raising children."
	lab var ge_earning "[Reversed] it always causes problem when a woman earns more than a man"
	lab var ge_leadership "In general, women make equally good village leaders as men"
	lab var ge_noprefboy "[No preference for boys] Ideally, what proportion of them would you like to be boys?"
			
	lab var ge_raisekids agree
	lab var ge_earning agree
	lab var ge_leadership agree
			
	egen ge_index = rowmean(ge_raisekids ge_earning ge_leadership ge_noprefboy)

/* Section 7: Society ___________________________________________________________*/
	
	rename s7q1 values_respectauthority												
		recode values_respectauthority (1 = 0) (2 = 1) (-999 = .d)
		lab def authority 0 "Citizens should be more active in questioning the actions of leaders" 1 "Citizens should show more respect for authority"
		lab val values_respectauthority authority 

	rename s7q2 values_trustelders													


* Section 8: HIV/AIDS ----------------------------------------------------------
	rename s8q1 hiv_aware														

	rename s8q2a hiv_excsoc
	rename s8q2b hiv_excfam
	rename s8q2c hiv_excgos
	rename s8q2d hiv_excvis
	egen hiv_exctot = rowtotal(hiv_excsoc hiv_excfam hiv_excgos hiv_excvis)

	rename s8q3 hiv_safe
		recode hiv_safe (2 = 0)
		lab val hiv_safe agree

	rename s8q4 hiv_bus	


/* Section 9: Mob Violence  ___________________________________________________*/

	rename s9q1 s9q1_mob_trustaccusers														
	lab define mobaccuse 1 "Person is probably a criminal" 2 "Does not mean that the person is actually a criminal"
	recode s9q1_mob_trustaccusers (-999 = .d)
	lab val s9q1_mob_trustaccusers mobaccuse
	lab var s9q1_mob_trustaccusers "9.1) [Which statement do you agree with] If most people in a community think that a person is a criminal..."

	rename s9q2 s9q2_mob_falseaccuse

	destring s9_q3_4_rand, replace
	gen s9q3_mob_treat_male = 1 if s9_q3_4_rand < 0.5
	replace s9q3_mob_treat_male = 0 if s9_q3_4_rand > 0.5
	lab def mob_treat 1 "Male Treatment Condition" 0 "Female Treatment Condition"
	lab val s9q3_mob_treat_male mob_treat

	rename s9q3a s9q3_mob_accuseresponse
	recode s9q3_mob_accuseresponse (-999 = 0)											
	replace s9q3_mob_accuseresponse = s9q3b if s9q3_mob_accuseresponse == .
	lab var s9q3_mob_accuseresponse  "9.3a) Imagine the following: A [man/woman] from your community is blowing the whistle, because [she/he] saw someone stealing food and a box of cold drinks from his yard. The neighbors come running and one them gets hold of the thief. Again, which of the following do you believe the neighbors should do?"
	lab def mob_neighbor 1 "The neighbors should beat the thief there and then" 2 "The neighbors should call the police and leave it to them to deal with the thief."
	lab val s9q3_mob_accuseresponse mob_neighbor 


/* Section 10: Witchcraft  _____________________________________________________*/

	rename s10q1 s10q1_witch_blf
	recode s10q1_witch_blf (-999 = .d)

																						
	rename s10q2 s10q2_witch_vis
	recode s10q2_witch_vis (-999= .d)
								
	rename s10q3 s10q3_witch_mem
	rename s10q3_oth s10q3_witch_mem_oth	

	rename s10q4 s10q4_witch_shock
	recode s10q4_witch_shock (-999 = .d)

	rename s10q5 s10q5_witch_cope
	recode s10q5_witch_cope (-999 = .d) (. = 0)

	rename s10q6 s10q6_witch_ptix
	recode s10q6_witch_ptix (-999 = .d)

 
/* Section 11: Housing  ________________________________________________________*/

	rename s11q1 asset_housetype
	gen asset_multiplehuts = 1 if asset_housetype == 1
	replace asset_multiplehuts = 0 if asset_multiplehuts  == .
		lab var asset_multiplehuts "Multiple huts in compound?"
		lab val asset_multiplehuts yesnodkr
		rename s11q1_oth asset_housing_oth

	rename s11q2 asset_rooms

	rename s11q3 asset_walls	
		lab def s11q3 11 "Mud and Sticks", add
		recode asset_walls (-222 = .o)

	gen asset_mudwalls = asset_walls	
	recode asset_mudwalls (1=1)(2=1)(3=0)(4=0)(5=0) (7=0)(11=1)
	replace asset_mudwalls  = 0 if asset_mudwalls == .o
		
	rename s11q3_oth asset_walls_oth


/* Section 12: Assets  __________________________________________________________*/
	
	rename s12q1 asset_radio														

	rename s12q2 asset_radio_num
		recode asset_radio_num (. = 0)	
																															
	rename s12q3 asset_radio_listen										

	rename s12q4 asset_tv															
	rename s12q5 asset_cell															
	rename s12q6 asset_cellint
	recode asset_cellint (. = 0)(-999 = 0)
	rename s12q7 asset_battery

	gen asset_battery_weeks = asset_battery
	recode asset_battery_weeks (4 = 1) (3 = 0) (2 = 0) (1 = 0) (. = 0)

/* Section 13: Conclusion  _____________________________________________________*/

	rename s13q1 svy_followup	
		recode svy_followup (-999 = .d)													
	
	rename s13q2 svy_screen
		recode svy_screen (-999 = .d) 
		
	rename s13q4 svy_otherspresent	
		
	rename s13q3 asset_livingconditions
	
	gen asset_worseconditions = 1 if asset_livingconditions	== 1 | 	asset_livingconditions == 2						

* Fix Unique ID_________________________________________________________________*/

	replace resp_c = "98" if resp_name == "Julieth martin livinga"
	replace resp_c = "93" if resp_name == "Maria joachim Edward"
	replace resp_c = "88" if resp_name == "Hussein Rajabu Kiluwa"

* Save _________________________________________________________________________*/

	save "${data}/02_mid_data/pfm_as_baseline_clean.dta", replace
											
				
				

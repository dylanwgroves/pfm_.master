/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Baseline Pilot Import and Cleaning
	Date: 7/5/2019
	Author: Dylan Groves, dgroves@poverty-action.org
	Overview: This imports piloting data
_______________________________________________________________________________*/


* Introduction -----------------------------------------------------------------
clear all
set maxvar 30000
set more off

* Import Data ------------------------------------------------------------------
use "${data}/01_raw_data/03_surveys/pfm_pii_as_baseline.dta", clear

* Variable Labels --------------------------------------------------------------
#d ;
lab define yesnodkr
0 "No"
1 "Yes"
-999 "Don't Know"
-888 "Refuse" ;
#d cr


* Converting don't know/refuse/other to extended missing values
qui ds, has(type numeric)
recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

* Clean up ---------------------------------------------------------------------
drop subscriberid simid devicephonenum username duration rand_bc
order cases_label fo

* High Level Data --------------------------------------------------------------
bysort fo: egen survey_num_fo = count(key)
bysort s1q5 fo: egen survey_num_fovl = count(key)

* Section 1: Background --------------------------------------------------------
gen team = fo
recode team (3 = 1) (4 = 0) (5 = 0) (9 = 1)(11 = 0)(12 = 1)(13 = 0)(14 = 1)(15 =0)(20 = 1)

* Section 1: Background --------------------------------------------------------
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

* Section 2: Respondent Information --------------------------------------------
rename s2q1 s2q1_gender															

rename s2q2 s2q2_howudoin

gen s2q2_goodday =  s2q2_howudoin
recode s2q2_goodday (3=0)(2=1)(1=0)
lab var s2q2_goodday "Particularly good day today?"
lab val s2q2_goodday yesnodkr

rename s2q3 s2q3_age
															
rename s2q4 s2q4_hhrltn

* Generate Head of Household Variable
gen s2q4_hhh = 1 if s2q4_hhrltn == 1
replace s2q4_hhh = 0 if s2q4_hhh == .
lab var s2q4_hhh "Head of Household?"
lab val s2q4_hhh yesnodkr
											
rename s2q5 s2q5_maritalstatus

* Generate Marital Status Variable
gen s2q5_married = 1 if s2q5_maritalstatus == 1
replace s2q5_married  = 0 if s2q5_married  == .
lab var s2q5_married "Married?"
lab val s2q5_married yesnodkr

rename s2q6 s2q6_numhh	
														
rename s2q7 s2q7a_numkid
gen s2q7b_numadult = s2q6_numhh - s2q7a_numkid

rename s2q8 s2q8_numolder 

rename s2q9 s2q9_numyounger

rename s2q10 s2q10_kidsever	

rename s2q12 s2q11_yrsvill																										

rename s2q13 s2q12_villknow
gen s2q12_villknow_all  = 1 if s2q12_villknow == 1 | s2q12_villknow == 2
replace s2q12_villknow_all = 0 if s2q12_villknow_all  == .

rename city_rand_txt s2q13_t_citytype
rename s2q14a s2q13_livecity_dum
rename s2q14b s2q13_livecity_num
replace s2q13_livecity_num = 0 if s2q13_livecity_dum == 0
rename time_txt s2q13_livecity_firstlast

rename s2q14c s2q15a_livecity_where
rename s2q14c_oth s2q15a_livecity_where_oth

rename s2q15a s2q15b_livecity_why
rename s2q15a_oth s2q15b_livecity_why_oth

rename s2q15b s2q16_samevillage
									
rename s2q16a s2q17_visit_city
gen s2q17_nevervisitcity = 1 if s2q17_visit_city == 1
replace s2q17_nevervisitcity = 0 if s2q17_nevervisitcity ==.
lab var s2q17_nevervisitcity "Never visits city?"
lab val s2q17_nevervisitcity  yesnodkr

rename s2q16b s2q18_visit_town
gen s2q18_nevervisittown = 1 if s2q18_visit_town == 1
replace s2q18_nevervisittown = 0 if s2q18_nevervisittown ==.
lab var s2q18_nevervisittown "Never visits town?"
lab val s2q18_nevervisittown  yesnodkr
					
rename s2q17 s2q19_education
gen s2q19_standard7  = 1 if s2q19_education > 7
replace s2q19_standard7 = 0 if s2q19_standard7 == .
lab var s2q19_standard7 "At least standard 7 education?"
lab val s2q19_standard7 yesnodkr

rename s2q17_oth s2q19_education_oth

gen s2q19a_readwrite = s2q18a if s2q19_education < 8								
replace s2q19a_readwrite = s2q18b if s2q19_education > 7 
lab def readwrite -999 "Don't Know" -888 "Refuse" 1 "Read only" 2 "Write and read" 3 "Write only" 4 "None"
lab val s2q19a_readwrite readwrite

gen s2q19a_literate = 1 if s2q19a_readwrite == 2
replace s2q19a_literate = 0 if s2q19a_literate == .
lab var s2q19a_literate "Can read and write?"
lab val s2q19a_literate yesnodkr

rename s2q19 s2q19_lang_main
rename s2q19_oth s2q19_lang_main_oth
rename s2q20_sm s2q20_lang_any													
split s2q20_lang_any
rename s2q20_sm_oth s2q2_lang_any_oth

gen s2q20_lang_swahili = 1 if s2q19_lang_main == 1
replace s2q20_lang_any = subinstr(s2q20_lang_any, "10", "ten",.)				// Don't want to double count 10
replace s2q20_lang_swahili  = 1 if strpos(s2q20_lang_any, "1")
replace s2q20_lang_swahili = 0 if s2q20_lang_swahili == . 
lab var s2q20_lang_swahili "Respondent speaks Swahili?"
lab def yesno 1 "Yes" 0 "No"
lab val s2q20_lang_swahili yesno

gen s2q20_lang_swahilimain = 1 if s2q19_lang_main == 1
replace s2q20_lang_swahilimain = 0 if s2q20_lang_swahilimain == .
lab var s2q20_lang_swahilimain "Swahili main language?"
lab val s2q20_lang_swahilimain yesnodkr


* Section 3: Religion ----------------------------------------------------------
rename s3q1 s3q1_religion
rename s3q1_oth s3q1_religion_other	

gen s3q1_religion_christ = 1 if s3q1_religion == 2 | s3q1_religion == 4 | ///
								s3q1_religion == 5 | s3q1_religion == 6 | ///
								s3q1_religion == 7 | s3q1_religion == 8 | ///
								s3q1_religion == 9 | s3q1_religion == 10
replace s3q1_religion_christ = 0 if s3q1_religion_christ == .
lab var s3q1_religion_christ "Christian or Muslim"
lab def religion 0 "Muslim" 1 "Christian"
lab val s3q1_religion_christ religion

gen s3q1_religion_muslim = 1 if s3q1_religion == 3 | s3q1_religion == 12 | s3q1_religion == 13 | s3q1_religion == 14 | s3q1_religion == 15 
replace s3q1_religion_muslim  = 0 if s3q1_religion_muslim  == .

rename s3q2 s3q2_rel_attend
replace s3q2_rel_attend = .r if s3q2_rel_attend == 999							
replace s3q2_rel_attend = .r if s3q2_rel_attend == -999	
replace s3q2_rel_attend = .d if s3q2_rel_attend == -888	

* Section 4: Media -------------------------------------------------------------
rename s4q1 s4q1_tv	
gen s4q1_tv_any = 0 if s4q1_tv == 6
replace s4q1_tv_any = 1 if s4q1_tv_any == .
lab var s4q1_tv_any  "Any TV Yesterday?"
lab val s4q1_tv_any  yesnodkr

rename s4q2 s4q2_radio  														
replace s4q2_radio = 0 if s4q2_radio == 6										// Change value of "None" from 6 to 0
replace s4q2_radio = . if s4q2_radio  == -888 | s4q2_radio  == -999
lab def s4q2 0 "None", modify
	
rename s4q3 s4q3_radio_any												
replace s4q3_radio_any = 1 if s4q2_radio > 0 &  s4q2_radio < 6	
replace s4q3_radio_any = 0 if s4q3_radio_any == .
replace s4q3_radio_any = 0 if s4q3_radio_any == -999

* Favorite Topics At Different Times of Day
rename s4q6_sm_1 s4q6_radiomorn													
rename s4q6_sm_2 s4q6_radionoon
rename s4q6_sm_3 s4q6_radioeve
rename s4q6_sm_4 s4q6_radiolate

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


* 4.7 - Radio Stations												// HFC: Number of radio stations listened to
rename s4q7_sm s4q7_radstns																												
replace s4q7_radstns = subinstr(s4q7_radstns, "-222", "other",.)	// Switch out subtrings 
replace s4q7_radstns = subinstr(s4q7_radstns, "-999", "dontknow",.)
replace s4q7_radstns = subinstr(s4q7_radstns, "-888", "refuse",.)
replace s4q7_radstns = subinstr(s4q7_radstns, "10", "ten",.)		// Depending on how many radio stations there are, can keep adding these		
replace s4q7_radstns = subinstr(s4q7_radstns, "11", "eleven",.)
replace s4q7_radstns = subinstr(s4q7_radstns, "12", "twelve",.)
replace s4q7_radstns = subinstr(s4q7_radstns, "13", "thirteen",.)
replace s4q7_radstns = subinstr(s4q7_radstns, "14", "fourteen",.)

* Create Dummy For stations														
gen s4q7_radstns_clouds = 0												
gen s4q7_radstns_tanga = 0
gen s4q7_radstns_voa = 0
gen s4q7_radstns_pfm = 0
gen s4q7_radstns_hisani = 0
gen s4q7_radstns_mwambao = 0
gen s4q7_radstns_radioone = 0
gen s4q7_radstns_tbc = 0
gen s4q7_radstns_safina = 0
gen s4q7_radstns_breeze = 0
gen s4q7_radstns_tk = 0
gen s4q7_radstns_catholic = 0
gen s4q7_radstns_radioafrica = 0
gen s4q7_radstns_dk = 0
															
replace s4q7_radstns_clouds = 1 if strpos(s4q7_radstns, "1") 		 
replace s4q7_radstns_tanga = 1 if strpos(s4q7_radstns, "2")
replace s4q7_radstns_voa = 1 if strpos(s4q7_radstns, "3")
replace s4q7_radstns_pfm = 1 if strpos(s4q7_radstns, "4")
replace s4q7_radstns_hisani = 1 if strpos(s4q7_radstns, "5")
replace s4q7_radstns_mwambao = 1 if strpos(s4q7_radstns, "6")
replace s4q7_radstns_radioone = 1 if strpos(s4q7_radstns, "7")
replace s4q7_radstns_tbc = 1 if strpos(s4q7_radstns, "8")
replace s4q7_radstns_safina = 1 if strpos(s4q7_radstns, "9")
replace s4q7_radstns_breeze = 1 if strpos(s4q7_radstns, "ten")
replace s4q7_radstns_tk = 1 if strpos(s4q7_radstns, "eleven")
replace s4q7_radstns_catholic = 1 if strpos(s4q7_radstns, "twelve")
replace s4q7_radstns_radioafrica = 1 if strpos(s4q7_radstns, "thirteen")
replace s4q7_radstns_dk = 1 if strpos(s4q7_radstns, "dontknow")
lab val s4q7_radstns_* yesnodkr												
egen s4q7_radstns_tot = rowtotal(s4q7_radstns_*)	

rename s4q8 s4q8_radiocommunity	

gen s4q8_radcomm_ever = 0 if s4q8_radiocommunity == 8
replace s4q8_radcomm_ever = 1 if s4q8_radcomm_ever == .
replace s4q8_radcomm_ever = 0 if s4q3_radio_any	 == 0
replace s4q8_radcomm_ever = .d if s4q8_radiocommunity == -999
lab var s4q8_radcomm_ever "Ever listen to radio with community?"
lab val s4q8_radcomm_ever yesnodkr																									
rename s4q9 s4q9_news
gen s4q9_news_never = 1 if s4q9_news == 1
replace s4q9_news_never = 0 if s4q9_news_never == .
lab var s4q9_news_never  "Never listen to news or current events?"
lab val s4q9_news_never  yesnodkr

gen s4q9_news_daily = 1 if s4q9_news == 5
replace s4q9_news_daily  = 0 if s4q9_news_daily  == .
lab var s4q9_news_daily "Listen to news or current events every day?"
lab val s4q9_news_daily yesnodkr

rename s4q10 s4q10_callradio
gen s4q10_callradio_ever = 0 if s4q10_callradio == 1
replace s4q10_callradio_ever = 1 if s4q10_callradio_ever == .
lab var s4q10_callradio_ever "Ever call or text radio programs?"
lab val s4q10_callradio_ever yesnodkr

		
* Section 5: General Values------------------------------------------------------
rename s5q1 s5q1_likechange														
replace s5q1_likechange = 0 if s5q1_likechange == 1
replace s5q1_likechange = 1 if s5q1_likechange == 2
replace s5q1_likechange = .d if s5q1_likechange == -999
lab def change 0 "Do things as they have been done" 1 "Try new things"
lab val s5q1_likechange change

rename s5q3 s5q2_techgood														
replace s5q2_techgood = 0 if s5q2_techgood == 1										
replace s5q2_techgood = 1 if s5q2_techgood == 2
replace s5q2_techgood = .d if s5q2_techgood == -999
lab def tech 0 "Bad - give people bad ideas" 1 "Great - show new things"
lab val s5q2_techgood tech


* Section 6: Gender Hierarchy --------------------------------------------------
rename s6q1 s6q1_gh_noeqkid	
recode s6q1_gh_noeqkid (0 = 1) ///
					 (1 = 0)
lab var s6q1_gh_noeqkid "[REVERSED] 6.1)  A husband and wife should [NOT] both participate equally in raising children."

rename s6q2 s6q2_gh_marry

rename s6q3 s6q3_gh_earn 
lab val s6q3_gh_earn yesnodkr

rename s6q4 s6q4_gh_lead
recode s6q4_gh_lead (0 = 1) ///
					(1 = 0) ///d
					(-999 = .d)
lab var s6q4_gh_lead "[REVERSED] 6.4) Do you trust a woman leader to bring development to the community?"

rename s6q6 s6q5_gh_kidpref												
recode s6q5_gh_kidpref	(1 = 1) (2 = 0) (3 = 0) (4 = 1) (5 = 0) (6 = 0), gen(s6q5_gh_prefboy)
lab def moreboy 1 "Preference for boys" 0 "No preference for boys" -999 "Don't Know" -888 "Refuse" 
lab val s6q5_gh_prefboy moreboy 
lab var s6q5_gh_prefboy "[Preference for boys] 6.5) Ideally, what proportion of them would you like to be boys?"


* Section 7: Society -----------------------------------------------------------
rename s7q1 s7q1_respectauthority												
recode s7q1_respectauthority (1 = 0) (2 = 1) (-999 = .d)
lab def authority 0 "Citizens should be more active in questioning the actions of leaders" 1 "Citizens should show more respect for authority"
lab val s7q1_respectauthority authority 

rename s7q2 s7q2_trustelders													


* Section 8: HIV/AIDS ----------------------------------------------------------
rename s8q1 s8q1_hiv_aware														

rename s8q2a s8q2_hiv_excsoc
rename s8q2b s8q2_hiv_excfam
rename s8q2c s8q2_hiv_excgos
rename s8q2d s8q2_hiv_excvis
egen s8q2_hiv_exctot = rowtotal(s8q2_hiv_excsoc s8q2_hiv_excfam s8q2_hiv_excgos s8q2_hiv_excvis)

rename s8q3 s8q3_hiv_safe
recode s8q3_hiv_safe (2 = 0)
lab def hiv 0 "Disagree" 1 "Agree"
lab val s8q3_hiv_safe hiv

rename s8q4 s8q4_hiv_bus	


* Section 9: Mob Violence  -----------------------------------------------------
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


* Section 10: Witchcraft  ------------------------------------------------------
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

 
* Section 11: Housing  ---------------------------------------------------------
rename s11q1 s11q1_house_type
gen s11q1_multiplehuts = 1 if s11q1_house_type == 1
replace s11q1_multiplehuts = 0 if s11q1_multiplehuts  == .
lab var s11q1_multiplehuts "Multiple huts in compound?"
lab val s11q1_multiplehuts yesnodkr
rename s11q1_oth s11q1_housing_oth

rename s11q2 s11q2_house_rooms

rename s11q3 s11q3_house_walls	
lab def s11q3 11 "Mud and Sticks", add
recode s11q3_house_walls (-222 = .o)

gen s11q3_mudwalls = s11q3_house_walls	
recode s11q3_mudwalls (1=1) (2 = 1) (3 = 0) (4 = 0) (5 = 0) (7 = 0) (11 = 1)
replace s11q3_mudwalls  = 0 if s11q3_mudwalls == .o
	
rename s11q3_oth s11q3_house_walls_oth


* Section 12: Assets  ----------------------------------------------------------
rename s12q1 s12q1_rad														

rename s12q2 s12q1a_rad_num
recode s12q1a_rad_num (. = 0)	
																														
rename s12q3 s12q1b_rad_list											

rename s12q4 s12q2_tv															
rename s12q5 s12q3_cell															
rename s12q6 s12q3a_cellint
recode s12q3a_cellint (. = 0)(-999 = 0)
rename s12q7 s12q3b_battery

gen s12q3b_battery_weeks = s12q3b_battery
recode s12q3b_battery_weeks (4 = 1) (3 = 0) (2 = 0) (1 = 0) (. = 0)

* Section 13: Conclusion  ------------------------------------------------------
rename s13q1 s13q1_followup	
recode s13q1_followup (-999 = .d)													
rename s13q2 s13q2_screen
recode s13q2_screen (-999 = .d) 												
rename s13q3 s13q3_livingconditions
gen s13q3_worseconditions = 1 if s13q3_livingconditions	== 1 | 	s13q3_livingconditions == 2						
rename s13q4 s13q4_otherspresent	

* Fix Unique ID_________________________________________________________________*/
replace resp_c = "98" if resp_name == "Julieth martin livinga"
replace resp_c = "93" if resp_name == "Maria joachim Edward"
replace resp_c = "88" if resp_name == "Hussein Rajabu Kiluwa"

* Save -------------------------------------------------------------------------
save "${data}/02_mid_data/pfm_as_baseline_clean.dta", replace
											
				
				

/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Baseline Pilot Import and Cleaning
	Date: 2023.10.28
	Author: Dylan Groves, dylanwgroves@gmail.com
	Overview: This imports piloting data
_______________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	*version 15
	clear all
	set maxvar 30000
	set more off

	
/* Load Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_nopii_as2_endline_partner.dta", clear
	gen as2_endline_partner = 1
	
/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"

/* Pulled Data / Confirmations _________________________________________________*/

	* IDs 
	replace resp_id = "2_101_5_04" if resp_id == "2_101_5_004"
	
	* gender 
	destring resp_female, replace
	*lab def resp_female 0 "Male" 1 "Female"
	lab val resp_female resp_female 
	
		* check that resp_female was correctly replaced if gender was not confirmed from pull
		rename gender_correction correction_gender
		gen check_gender = (gender_confirm == 0)
		tab resp_female correction_gender if check_gender == 1 
		drop check_gender
	
	tab info_confirm														

	rename info_correction_1	correction_name
	rename info_correction_3	correction_marital
	rename info_correction_4	correction_village
	rename info_correction_5	correction_subvillage

	* clean by hand the strings, as need eye check: correct_name correct_village correct_subvillage
	
/*
	* Age
		destring resp_age , replace
		gen age_check = resp_age if correction_age == 0 
		replace age_check = correct_age if correction_age == 1 & resp_age < correct_age & correct_age != . 
		gen check_age = (age_check != resp_age)
		tab resp_age age_check if check_age == 1 
		
		drop age_check check_age
		
	* Marital status
 */

		
	
/* Survey Information __________________________________________________________*/

	rename visits_nbr svy_visitsnum
	
	rename enum svy_enum 
	rename consent svy_consent 
	
	
/* Respondent Information ______________________________________________________*/

	tab resp_describe_day, m
	tab resp_tribe, m
	
	tab values_tzvstribe, m
	recode values_tzvstribe	(1 2 = 1 "TZ > Tribe") (3 4 5 = 0 "TZ <= Tribe"), gen(values_tzovertribe_dum)
	

/* GBV Travel ______________________________________________________________________*/

	tab resp_visitcity, m
		
		rename resp_visitcity gbv_visitcity_any 
		
	tab resp_visitcity_activities, m

	rename resp_visitcity_activities_1 		gbv_visitcity_fam 
	rename resp_visitcity_activities_2 		gbv_visitcity_friend 
	rename resp_visitcity_activities_3 		gbv_visitcity_job 
	rename resp_visitcity_activities_4 		gbv_visitcity_biz 
	rename resp_visitcity_activities_5 		gbv_visitcity_buy 
	rename resp_visitcity_activities_6 		gbv_visitcity_sell 
	rename resp_visitcity_activities_7 		gbv_visitcity_relig 
	rename resp_visitcity_activities_8 		gbv_visitcity_famevent 
	rename resp_visitcity_activities_9 		gbv_visitcity_ngos 
	rename resp_visitcity_activities_10		gbv_visitcity_villact 
	rename resp_visitcity_activities_11		gbv_visitcity_self 
	rename resp_visitcity_activities_12 	gbv_visitcity_health 
	rename resp_visitcity_activities_13 	gbv_visitcity_skill 
	rename resp_visitcity_activities__888 	gbv_visitcity_refuse
	 
	rename resp_visitcity_activities_oth gbv_visitcity_other


	tab resp_visitcity_transport, m												
	tab resp_visitcity_transport_oth

		rename resp_visitcity_transport gbv_howvisitcity 
		rename resp_visitcity_transport_oth gbv_howvisitcity_oth

	tab resp_boda_safe, m

		rename resp_boda_safe_1 	gbv_bodsafe_helment 
		rename resp_boda_safe_2 	gbv_bodsafe_passhelmet 
		rename resp_boda_safe_3 	gbv_bodsafe_vest 
		rename resp_boda_safe_4 	gbv_bodsafe_station 
		rename resp_boda_safe_5 	gbv_bodsafe_know 
		rename resp_boda_safe_6 	gbv_bodsafe_famknow 
		rename resp_boda_safe_7 	gbv_bodsafe_helpknow 
		rename resp_boda_safe__222 	gbv_bodsafe_oth 
		rename resp_boda_safe__999 	gbv_bodsafe_dk 
		rename resp_boda_safe__888 	gbv_bodsafe_refuse 
		
	tab resp_boda_safe_cost, m

		rename resp_boda_safe_cost gbv_safebodacostly 
		
	tab withinvillage_friend, m
	tab withinvillage_location, m

		rename withinvillage_friend gbv_visitfriends_num
		rename withinvillage_location gbv_visitfriends_where


/* Kids ________________________________________________________________________*/

	tab kids_anykids, m
	tab kids_anydaughter14yo, m
	tab kids_num, m

/* Elections ___________________________________________________________________*/

	* Treatments 

	* Election 1
		gen t_elect_gbv_name1 = rand_cand1_txt
		gen t_elect_gbv_name2 = rand_cand2_txt

		gen t_elect_gbv_muslim1 = .
			replace t_elect_gbv_muslim1 = 0 if t_elect_gbv_name1 == "Mr. John"
			replace t_elect_gbv_muslim1 = 0 if t_elect_gbv_name1 == "Mrs. Rose"
			replace t_elect_gbv_muslim1 = 1 if t_elect_gbv_name1 == "Mrs. Mwanaidi"
			replace t_elect_gbv_muslim1 = 1 if t_elect_gbv_name1 == "Mr. Salim"
			
		gen t_elect_gbv_muslim2 = .
			replace t_elect_gbv_muslim2 = 0 if t_elect_gbv_name2 == "Mr. John"
			replace t_elect_gbv_muslim2 = 0 if t_elect_gbv_name2 == "Mrs. Rose"
			replace t_elect_gbv_muslim2 = 1 if t_elect_gbv_name2 == "Mrs. Mwanaidi"
			replace t_elect_gbv_muslim2 = 1 if t_elect_gbv_name2 == "Mr. Salim"

		gen t_elect_gbv_female1 = .
			replace t_elect_gbv_female1 = 0 if t_elect_gbv_name1 == "Mr. John"
			replace t_elect_gbv_female1 = 1 if t_elect_gbv_name1 == "Mrs. Rose"
			replace t_elect_gbv_female1 = 1 if t_elect_gbv_name1 == "Mrs. Mwanaidi"
			replace t_elect_gbv_female1 = 0 if t_elect_gbv_name1 == "Mr. Salim"	
			
		gen t_elect_gbv_female2 = .
			replace t_elect_gbv_female2 = 0 if t_elect_gbv_name2 == "Mr. John"
			replace t_elect_gbv_female2 = 1 if t_elect_gbv_name2 == "Mrs. Rose"
			replace t_elect_gbv_female2 = 1 if t_elect_gbv_name2 == "Mrs. Mwanaidi"
			replace t_elect_gbv_female2 = 0 if t_elect_gbv_name2 == "Mr. Salim"	
			
		gen t_elect_gbv_first = .
			replace t_elect_gbv_first = 1 if rand_order_1st_txt == "first"
			replace t_elect_gbv_first = 0 if rand_order_1st_txt == "second"
			
	* Election 2
		gen t_elect_enviro_name1 = rand_cand3_txt
		gen t_elect_enviro_name2 = rand_cand4_txt

		gen t_elect_enviro_muslim1 = .
			replace t_elect_enviro_muslim1 = 0 if t_elect_enviro_name1 == "Mr. John"
			replace t_elect_enviro_muslim1 = 0 if t_elect_enviro_name1 == "Mrs. Rose"
			replace t_elect_enviro_muslim1 = 1 if t_elect_enviro_name1 == "Mrs. Mwanaidi"
			replace t_elect_enviro_muslim1 = 1 if t_elect_enviro_name1 == "Mr. Salim"
			
		gen t_elect_enviro_muslim2 = .
			replace t_elect_enviro_muslim2 = 0 if t_elect_enviro_name2 == "Mr. John"
			replace t_elect_enviro_muslim2 = 0 if t_elect_enviro_name2 == "Mrs. Rose"
			replace t_elect_enviro_muslim2 = 1 if t_elect_enviro_name2 == "Mrs. Mwanaidi"
			replace t_elect_enviro_muslim2 = 1 if t_elect_enviro_name2 == "Mr. Salim"

		gen t_elect_enviro_female1 = .
			replace t_elect_enviro_female1 = 0 if t_elect_enviro_name1 == "Mr. John"
			replace t_elect_enviro_female1 = 1 if t_elect_enviro_name1 == "Mrs. Rose"
			replace t_elect_enviro_female1 = 1 if t_elect_enviro_name1 == "Mrs. Mwanaidi"
			replace t_elect_enviro_female1 = 0 if t_elect_enviro_name1 == "Mr. Salim"	
			
		gen t_elect_enviro_female2 = .
			replace t_elect_enviro_female2 = 0 if t_elect_enviro_name2 == "Mr. John"
			replace t_elect_enviro_female2 = 1 if t_elect_enviro_name2 == "Mrs. Rose"
			replace t_elect_enviro_female2 = 1 if t_elect_enviro_name2 == "Mrs. Mwanaidi"
			replace t_elect_enviro_female2 = 0 if t_elect_enviro_name2 == "Mr. Salim"	
			
		gen t_elect_enviro_first = .
			replace t_elect_enviro_first = 1 if rand_order_2nd_txt == "first"
			replace t_elect_enviro_first = 0 if rand_order_2nd_txt == "second"

		* GBV
		gen gbv_elect = s3q4a_1 
			replace gbv_elect = 0 if gbv_elect == 2
			replace gbv_elect = 1 if s3q4a_2 == 2
			replace gbv_elect = 0 if s3q4a_2 == 1
			*lab def gbv_elect 1 "Stop GBV Vote" 0 "Other Vote"
			lab val gbv_elect gbv_elect 
			
		* Enviro
		gen enviro_elect = s3q4b_1 
			replace enviro_elect = 0 if enviro_elect == 2
			replace enviro_elect = 1 if s3q4b_2 == 2 
			replace enviro_elect = 0 if s3q4b_2 == 1
			*lab def enviro_elect 1 "Enviro Vote" 0 "Other Vote"
			lab val enviro_elect enviro_elect 
			
		fre gbv_elect 
		fre enviro_elect

	
/* Political Preferences _______________________________________________________*/ 


	* GBV 
		forval i = 1/3 {
			gen ptixpref1_rank_`i' = .
			replace ptixpref1_rank_`i' = 3 if ppref1_card1 == `i'
			replace ptixpref1_rank_`i' = 2 if ppref1_card2 == `i'
			replace ptixpref1_rank_`i' = 1 if ppref1_card3 == `i'

		}
			rename ptixpref1_rank_1 ptixpref1_rank_gbv
			rename ptixpref1_rank_2 ptixpref1_rank_water
			rename ptixpref1_rank_3 ptixpref1_rank_cell 
			
		rename ppref1_partner ptixpref1_partner
		gen ptixpref1_partner_gbv = (ptixpref1_partner == 1)
		
	* Enviro 
		forval i = 1/3 {
			gen ptixpref2_rank_`i' = .
			replace ptixpref2_rank_`i' = 3 if ppref2_card1 == `i'
			replace ptixpref2_rank_`i' = 2 if ppref2_card2 == `i'
			replace ptixpref2_rank_`i' = 1 if ppref2_card3 == `i'

		}
			rename ptixpref2_rank_1 ptixpref2_rank_enviro
			rename ptixpref2_rank_2 ptixpref2_rank_health
			rename ptixpref2_rank_3 ptixpref2_rank_ag
				
		rename ppref2_partner ptixpref2_partner
		gen ptixpref2_partner_enviro = (ptixpref2_partner == 1)	
		
	foreach var of varlist ptixpref* {
		cap fre `var'
	}
	

/* Environment Causes __________________________________________________________*/
		
	recode env_ccknow_mean (1 2 3 = 1)(4 5 6 7 -888 -999 = 0), gen(enviro_ccknow_mean_dum)
	lab var enviro_ccknow_mean_dum "Dummy: Know meaning of climate change"
	
	rename env_cause_second_1 enviro_cause_second_nature
	rename env_cause_second_2 enviro_cause_second_god
	rename env_cause_second_3 enviro_cause_second_othersuper
	rename env_cause_second_4 enviro_cause_second_vill
	rename env_cause_second_5 enviro_cause_second_othvill
	rename env_cause_second_6 enviro_cause_second_othtz
	rename env_cause_second_7 enviro_cause_second_intl
	rename env_cause_second_8 enviro_cause_second_gov
	rename env_cause_second_9 enviro_cause_second_none
	rename env_cause_second_10 enviro_cause_second_refuse
	cap rename env_cause_seccon_999 enviro_cause_second_dk
	
	egen env_cause_second_num = rowtotal(enviro_cause_second_*)

	egen enviro_cause_second_humans = 	rowmax(enviro_cause_second_vill ///
											enviro_cause_second_othvill ///
											enviro_cause_second_othtz ///
											enviro_cause_second_intl ///
											enviro_cause_second_gov)
																
	recode env_cause (4 5 6 7 8 = 2)(1 2 3 9 10 -222 -999 = 0), gen(enviro_cause_human)		// DWG: for outcome measure, do we want to set this to zero if they got the meaning of climate change wrong
	lab var enviro_cause_human "Environmental problems primarily caused by humans, secondarily, or not at all"
	replace enviro_cause_human = 1 if enviro_cause_second_humans == 1 & enviro_cause_human == 0
	
	recode env_cause (7 = 1)(1 2 3 4 5 6 8 9 10 -222 -999 = 0), gen(enviro_cause_intl)
	lab var enviro_cause_intl "Dummy: enviro prob caused by international folks"
	replace enviro_cause_intl = 1 if enviro_cause_second_intl == 1 
	
	foreach var of varlist enviro_* {
		cap fre enviro_*
	}


/* Gender ______________________________________________________________________*/

	fre ge_school
	recode ge_school (2 = 1)(1 = 0)
	*lab def ge_school_new 1 "Girls Equal Edu" 0 "Boys > Girls Edu"
	lab val ge_school ge_school_new
	
	recode ipv_attitudes (1=0 "Accept IPV (gossip)")(0=1 "Reject IPV (gossip)"), gen(ipv_reject_gossip)	// DWG
	gen ipv_reject_long_gossip = 0 if ipv_hithard == 2
		replace ipv_reject_long_gossip = 1 if ipv_hithard == 1 & ipv_reject_gossip == 0
		replace ipv_reject_long_gossip = 2 if ipv_reject_gossip == 1 & ipv_persist == 1
		replace ipv_reject_long_gossip = 3 if ipv_reject_gossip == 1 & ipv_persist == 0
		*lab def ipv_reject_long_gossip 0 "More than slap" 1 "Slap" 2 "If persists" 3 "Never"
		lab val ipv_reject_long_gossip ipv_reject_long_gossip
		
	foreach var of varlist ge_* ipv_* {
		cap fre `var'
	}
		
		
/* GBV _________________________________________________________________________*/
	
	* risky travel att + norm
	recode gbv_safe_travel (2 = 1 "Generally risky")(1 = 0 "Generally safe"), gen(gbv_travel_risky_short)
	
	gen gbv_travel_risky_long = gbv_travel_risky_short
	replace gbv_travel_risky_long = 1 if gbv_safe_travel_bu==1
	replace gbv_travel_risky_long = 2 if gbv_safe_travel_bd==2
	replace gbv_travel_risky_long = 3 if gbv_safe_travel_bd==3
	cap lab def gbv_travel_risky_long 0 "Very safe" 1 "Safe enough" 2 "Quite risky" 3 "Very risky"
	lab val gbv_travel_risky_long gbv_travel_risky_long
	
	recode gbv_safe_travel_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_travel_risky_norm)

	tab 	end_gbv_norm_rand_txt
	tab 	gbv_travel_risky_norm end_gbv_norm_rand_txt

																	
	* risky boda att + norm
	recode gbv_safe_boda (2 = 1 "Generally risky")(1 = 0 "Generally safe"), gen(gbv_boda_risky_short)
	

	gen gbv_boda_risky_long = gbv_boda_risky_short
	replace gbv_boda_risky_long = 1 if gbv_safe_boda_bu==1
	replace gbv_boda_risky_long = 2 if gbv_safe_boda_bd==2
	replace gbv_boda_risky_long = 3 if gbv_safe_boda_bd==3
	cap lab def gbv_boda_risky_long 0 "Very safe" 1 "Safe enough" 2 "Quite risky" 3 "Very risky"
	lab val gbv_boda_risky_long gbv_boda_risky_long


	recode gbv_safe_boda_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_boda_risky_norm)

	* Party
	tab gbv_safe_party_self if resp_female == 1, m
	tab gbv_safe_party_norm, m
	
	* Streets																	// DWG: Not sure need only when dark
	tab gbv_resp_streets_self if resp_female == 1, m
	rename gbv_resp_streets_self gbv_safe_streets_self_short 
	
*	if pilot == 1 {
*	recode gbv_safe_streets_self_short (1 = 2 "Yes")(0 = 0 "Never")(3 = 1 "Only when dark"), gen(gbv_safe_streets_long) 
*	replace gbv_safe_streets_long = 1 if gbv_resp_streets_self_branch == 1
*	}
*	else {	
*	}
	
	* GBV Response
	gen gbv_response_gov = (gbv_response == 2)

	gen gbv_response_norm_gov = (gbv_response_norm == 2)
	
	* Court 
	recode court_boda_sex (1 = 1 "Testify")(2 = 0 "Don't testify"), gen(gbv_testify)
	recode court_boda_sex_norm (1 = 1 "Testify")(2 = 0 "Don't testify"), gen(gbv_testify_norm)
	
	
	foreach var of varlist gbv_* {
		cap fre `var'
	}


/* Environment Outcomes ________________________________________________________*/

	recode envatt_general (1 = 1 "Enviro > Dev Projects")(2 = 0 "Dev Projects > Enviro"), gen(enviro_attitudes)
		lab var enviro_attitudes "Enviro over dev projects"
		
	recode envnorm_community (1 = 1 "Enviro > Dev Projects")(2 = 0 "Dev Projects > Enviro"), gen(enviro_norm)
		lab var enviro_norm "Enviro over dev projects"
	
	recode envoutcm_politician (1 = 0 "Sell the forest land")(2 = 1 "Protect the land"), gen(enviro_voteenviro)
		lab var enviro_voteenviro "Enviro vote (not vignette)"

		
/* Social Preferences __________________________________________________________*/

	* Enviro
	forval i = 1/4 {
		gen socpref1_rank_`i' = .
		replace socpref1_rank_`i' = 4 if spref1_card1 == `i'
		replace socpref1_rank_`i' = 3 if spref1_card2 == `i'
		replace socpref1_rank_`i' = 2 if spref1_card3 == `i'
		replace socpref1_rank_`i' = 1 if spref1_card4 == `i'

	}
		rename socpref1_rank_1 socpref1_rank_enviro
		rename socpref1_rank_2 socpref1_rank_baddads
		rename socpref1_rank_3 socpref1_rank_bribes 
		rename socpref1_rank_4 socpref1_rank_nofaith 
		
		rename spref1_partner socpref1_partner
		gen socpref1_partner_enviro = (socpref1_partner == 1)

	* GBV
	forval i = 1/4 {
		gen socpref2_rank_`i' = .
		replace socpref2_rank_`i' = 4 if spref2_card1 == `i'
		replace socpref2_rank_`i' = 3 if spref2_card2 == `i'
		replace socpref2_rank_`i' = 2 if spref2_card3 == `i'
		replace socpref2_rank_`i' = 1 if spref2_card4 == `i'

	}
		rename socpref2_rank_1 socpref2_rank_women
		
		rename socpref2_rank_2 socpref2_rank_alcohol
		rename socpref2_rank_3 socpref2_rank_noloan 
		rename socpref2_rank_4 socpref2_rank_badkids
		
		rename spref2_partner socpref2_partner
		gen socpref2_partner_gbv = (socpref2_partner == 1)	
		
	
/* Relationships _______________________________________________________________*/

	bys resp_marital_status: tab rship_discuss									// DWG: are we sure that only 21 of 42 people should be qualifying for this answer? Maybe bc enumerators mostlly didnt quality?
	
	rename rship_discuss_1 rship_discuss_ptix 
	rename rship_discuss_2 rship_discuss_school 
	rename rship_discuss_3 rship_discuss_whowork 
	rename rship_discuss_9 rship_discuss_none 
	rename rship_discuss__999 rship_discuss_dk 
	rename rship_discuss__888 rship_discuss_refuse

/* old 

	fre rship_perm_w															// DWG: everyone says yes -- BM: good, it's what we need from women because no one believes us when we say this!
	fre rship_perm_w_branched
	fre rship_perm_m															// BM: men maybe we'll find some var
	fre rship_perm_m_branched 												// DWG: everyone says yes

	gen rship_perm = .
	lab def rship_perm 0 "No friend" 1 "Friend ok, no market" 2 "Market ok, no town" 3 "Town ok" 
	lab val rship_perm rship_perm 
	replace rship_perm = 2 if rship_perm_w_branched == 1
	replace rship_perm = 1 if rship_perm_w_branched == 0
	replace rship_perm = 0 if rship_perm_w_branched_c == 0
	replace rship_perm = 3 if rship_perm_w_branched_f == 1
	
	replace rship_perm = 2 if rship_perm_m_branched == 1
	replace rship_perm = 1 if rship_perm_m_branched == 0
	replace rship_perm = 0 if rship_perm_m_branched_c == 0
	replace rship_perm = 3 if rship_perm_m_branched_f == 1	

	if pilot == 1 {
		tab relationship_decision		
	}
	
*/

	tab rship_perm_w_branched_f , m
	tab rship_perm_m_branched_f , m
	
	
	/*
	fre parenting_permission
	fre parenting_talk
	*/

	foreach var of varlist rship_* parenting_* {
		cap fre `var'
	}
	
	
/* Womens Political Participation ______________________________________________*/

	recode wpp_leaders_men (1 = 1 "Women just as good")(2 = 0 "Women not as good"), gen(wpp_attitude2_dum)
	
	rename wpp_behavior wpp_behavior 
	rename wpp_intention_woman wpp_behavior_self
	gen wpp_behavior_self_short = wpp_behavior_self/3 
	rename wpp_intention_man wpp_behavior_wife
	egen wpp_behavior_adult = rowmean(wpp_behavior_self_short wpp_behavior_wife)
	
/* Openness ____________________________________________________________________*/
	
*	if pilot == 1 {
*		tab neighbor_homosexual
*	}
		tab neighbor_hiv
		tab neighbor_unmarried
		tab neighbor_albino
		
/* Kid Marry ___________________________________________________________________*/

	tab kidmarry_notreligion
	tab kidmarry_nottribe
	tab kidmarry_nottz
	*tab kidmarry_nottz2
	*	rename kidmarry_nottz2 kidmarry_city
		
	foreach var of varlist neighbor_* kidmarry_* {
		tab `var'
	}
			
/* Political participation and attitudes _______________________________________*/
	
	
	rename ppart_meeting ptixpart_raiseissue
	lab var ptixpart_raiseissue "Raised issue with gov't official in last year"
	
	rename ppart_meeting_which_1 ptixpart_raiseissue_gbv
	lab var ptixpart_raiseissue_gbv "Raised issue of GBV with gov't official"
	
	rename ppart_meeting_which_2 ptixpart_raiseissue_enviro
	lab var ptixpart_raiseissue_enviro "Raised issue of environment with gov't official"
	
	rename ppart_meeting_which_3 ptixpart_raiseissue_corrupt
	lab var ptixpart_raiseissue_corrupt "Raised issue of corruption with gov't official"
	
	rename ppart_meeting_which_4 ptixpart_raiseissue_safe
	lab var ptixpart_raiseissue_safe "Raised issue of safety with gov't official"
	
	foreach var of varlist ptixpart_raiseissue_* {
		replace `var' = 0 if ptixpart_raiseissue == 0
	}
	
	recode ppart_ccm_perfomance (1 = 2 "Very good")(2 = 1 "Ok")(3 = 0 "Not enough"), gen(ppart_ccm_perform)
	
	recode crime_national (2 = 0 "Rare")(1 = 1 "Widespread"), gen(crime_natl)
		drop crime_national
		

	

/* Political knowledge and interest ____________________________________________*/

	recode pknow_interest (1 = 3 "Very interested")(2 = 2 "Somewhat interested")(3 = 1 "Not very interested")(4 = 0 "Not at all interested"), gen(ptixpart_interest)
	
	tab pknow_vp	
		rename pknow_vp sb_pknow_vp
		recode sb_pknow_vp (3 = 1 "Correct") (.o .d 4 2 1 -999 -222 = 0 "Wrong"), gen(ptixknow_natl_vp)
		
		rename pknow_ruto sb_pknow_ruto												// Decide whether to recode
		recode sb_pknow_ruto (2 = 1 "Correct") (.o .d 1 -999 -222 -888 = 0 "Wrong"), gen(ptixknow_fopo_ruto)
			
	lab var pknow_ports "Heard DP World story"
	gen ptixknow_natl_ports = pknow_ports
	
	rename pknow_responsibility ptixpref_resp

	tab ptixpref_resp
		tab ptixpref_resp, gen(ptixpref_resp_)
		rename ptixpref_resp_1 ptixpref_resp_vill
		rename ptixpref_resp_2 ptixpref_resp_locgov 
		rename ptixpref_resp_3 ptixpref_resp_district 
		rename ptixpref_resp_4 ptixpref_resp_natgov
		
	gen ptixpref_resp_gov = ptixpref_resp_locgov + ptixpref_resp_natgov
	
	tab pknow_trust
		tab pknow_trust, gen(pknow_trust_)
		rename pknow_trust_1 ptixknow_trustloc
		rename pknow_trust_2 ptixknow_trustnat
		rename pknow_trust_3 ptixknow_trustrel
		rename pknow_trust_4 ptixknow_trustradio
		cap rename pknow_trust_0 ptixknow_trustnone
		
	foreach var of varlist pknow_* {
		cap fre `var'
	}
	
	
	
/* Media Consumption ___________________________________________________________*/

	* two weeks
	fre media_listen_radio
	rename media_listen_radio radio_listen
	gen radio_listen_twoweek = 1 if radio_listen == 1 | radio_listen == 2 | radio_listen == 3
			replace radio_listen_twoweek = 0 if radio_listen == 0
			
	gen radio_listen_hrperday = 1 if radio_listen == 2 | radio_listen == 3
		replace radio_listen_hrperday = 0 if radio_listen == 0 | radio_listen == 1

	* 3 months
	rename media_radio_3month radio_ever
		replace radio_ever = 1 if  			radio_listen == 1 | ///
											radio_listen == 2 | ///
											radio_listen == 3 

	rename media_listen_radio_time radio_listen_hrs 
		replace radio_listen_hrs = 0 if radio_listen == 0


	egen media_programs_total = rowtotal(media_programs_sm_*)	
	
		rename media_programs_sm_1 radio_type_music
		rename media_programs_sm_7 radio_type_religmusic 
		rename media_programs_sm_2 radio_type_sports 
		rename media_programs_sm_3 radio_type_ptix 
		rename media_programs_sm_4 radio_type_romance 
		rename media_programs_sm_5 radio_type_community 
		rename media_programs_sm_6 radio_type_religious 
		rename media_programs_sm__999 radio_type_dk 
		rename media_programs_sm__888 radio_type_refuse 
		
	foreach var of varlist radio_type_* {
		
		replace `var' = 0 if radio_ever == 0
		
	}

	tab media_programs_oth														// DWG: until July 28, this was not being asked to all people who listne to radio due to surveycto error

	rename media_listen_sm_oth radio_stations_other
	egen radio_stations_total = rowtotal(media_listen_sm_*)	

		rename media_listen_sm_1 radio_stations_voa
		rename media_listen_sm_2 radio_stations_tbc
		rename media_listen_sm_3 radio_stations_tbctaifa
		rename media_listen_sm_4 radio_stations_efm
		rename media_listen_sm_5 radio_stations_breeze
		rename media_listen_sm_6 radio_stations_clouds
		rename media_listen_sm_7 radio_stations_maria
		rename media_listen_sm_8 radio_stations_rone
		rename media_listen_sm_9 radio_stations_huruma
		rename media_listen_sm_10 radio_stations_mwambao
		rename media_listen_sm_11 radio_stations_wasafi
		rename media_listen_sm_12 radio_stations_nuru
		rename media_listen_sm_13 radio_stations_uhuru
		rename media_listen_sm_14 radio_stations_bbc
		rename media_listen_sm_15 radio_stations_sautiyaamerica
		rename media_listen_sm_16 radio_stations_tk
		rename media_listen_sm_17 radio_stations_pfm
		rename media_listen_sm_18 radio_stations_ihsaan
		rename media_listen_sm_19 radio_stations_nuur
		rename media_listen_sm_20 radio_stations_rfa
		rename media_listen_sm_21 radio_stations_eastafricaradio
		rename media_listen_sm_22 radio_stations_othrelig
		rename media_listen_sm_23 radio_stations_kenyan
		rename media_listen_sm_24 radio_stations_imani
		rename media_listen_sm_25 radio_stations_safina
		rename media_listen_sm_26 radio_stations_utume
		rename media_listen_sm_27 radio_stations_kiss
		rename media_listen_sm_28 radio_stations_abood

		tab radio_stations_other														// DWG: Add to HFCs
		
			foreach var of varlist radio_stations_* {
		
				cap replace `var' = 0 if radio_ever == 0
		
			}
			
		rename media_hearleader_natl radio_natleader

	
/* Thermometer _________________________________________________________________*/

	gen thermo_local_leader_num = thermo_local_leader*5
	gen thermo_business_num = thermo_business*5
	gen thermo_boda_num = thermo_boda*5
	gen thermo_ccm_num = thermo_ccm*5
	gen thermo_chinese_num = thermo_chinese*5
	gen thermo_mamasamia_num = thermo_mamasamia*5
	gen thermo_samiahassan_num = thermo_samiahassan*5
	
	egen thermo_samia_num = rowmax(thermo_samiahassan_num thermo_mamasamia_num)
	
	tab thermo_local_leader_num
	tab thermo_business_num
	tab thermo_boda_num
	tab thermo_ccm_num
	tab thermo_chinese_num
	tab thermo_samia_num
	
	sum thermo_local_leader_num thermo_business_num thermo_boda_num thermo_ccm_num thermo_chinese_num thermo_samia_num
	
	foreach var of varlist thermo_* {

		tab `var', m
		tabstat `var', m

	}

/* Agricultural Work ___________________________________________________________*/

	tab resp_agr_work, m
	tab agr_married resp_female, m
	tab agr_cropsnow, m

		rename agr_cropsnow_1 agr_cropsnow_sisal 
		rename agr_cropsnow_2 agr_cropsnow_cashew 
		rename agr_cropsnow_3 agr_cropsnow_fruit 
		rename agr_cropsnow_4 agr_cropsnow_maize 
		rename agr_cropsnow_5 agr_cropsnow_beans 
		rename agr_cropsnow_6 agr_cropsnow_spices 
		rename agr_cropsnow_7 agr_cropsnow_cassava 
		rename agr_cropsnow_8 agr_cropsnow_banana 
		rename agr_cropsnow_9 agr_cropsnow_coconuts 
		rename agr_cropsnow_10 agr_cropsnow_swtpotato 
		rename agr_cropsnow_11 agr_cropsnow_choloko 
		rename agr_cropsnow_12 agr_cropsnow_peas 
		rename agr_cropsnow_13 agr_cropsnow_kunde 
		rename agr_cropsnow_14 agr_cropsnow_sgrcane 
		rename agr_cropsnow_15 agr_cropsnow_cotton 
		rename agr_cropsnow_16 agr_cropsnow_wheat 
		rename agr_cropsnow__222 agr_cropsnow_other 
		rename agr_cropsnow__888 agr_cropsnow_refuse

		foreach var of varlist agr_cropsnow_* {
			cap replace `var' = .r if agr_cropsnow_refuse == .r
		}


		rename agr_cropspast_1 agr_cropspast_sisal 
		rename agr_cropspast_2 agr_cropspast_cashew 
		rename agr_cropspast_3 agr_cropspast_fruit 
		rename agr_cropspast_4 agr_cropspast_maize 
		rename agr_cropspast_5 agr_cropspast_beans 
		rename agr_cropspast_6 agr_cropspast_spices 
		rename agr_cropspast_7 agr_cropspast_cassava 
		rename agr_cropspast_8 agr_cropspast_banana 
		rename agr_cropspast_9 agr_cropspast_coconuts 
		rename agr_cropspast_10 agr_cropspast_swtpotato 
		rename agr_cropspast_11 agr_cropspast_choloko 
		rename agr_cropspast_12 agr_cropspast_peas 
		rename agr_cropspast_13 agr_cropspast_kunde 
		rename agr_cropspast_14 agr_cropspast_sgrcane 
		rename agr_cropspast_15 agr_cropspast_cotton 
		rename agr_cropspast_16 agr_cropspast_wheat 
		rename agr_cropspast__222 agr_cropspast_other 
		rename agr_cropspast__888 agr_cropspast_refuse

		foreach var of varlist agr_cropspast_* {
			cap replace `var' = .r if agre_cropspast_refuse == .r
		}


	tab agr_productivity, m
	tab agr_productivity_branched, m
	tab agr_productivity_branched_oth, m
	
		gen agr_productivity_climate = (agr_productivity_branched_3 == 1 | ///
									agr_productivity_branched_4 == 1 | ///
									agr_productivity_branched_5 == 1 | /// 
									agr_productivity_branched_6 == 1 | ///
									agr_productivity_branched_7 == 1 | ///
									agr_productivity_branched_9 == 1 | /// 
									agr_productivity_branched_10 == 1)
		cap la de agr_productivity_climate 0 "not climate change" 1 "climate change"
		la val agr_productivity_climate agr_productivity_climate
		
		rename agr_productivity_branched_1 agr_prod_seeds
		rename agr_productivity_branched_2 agr_prod_insects
		rename agr_productivity_branched_3 agr_prod_rainy
		rename agr_productivity_branched_4 agr_prod_dry
		rename agr_productivity_branched_5 agr_prod_unprerain
		rename agr_productivity_branched_6 agr_prod_hot
		rename agr_productivity_branched_7 agr_prod_soil
		rename agr_productivity_branched_8 agr_prod_betterweat		
		rename agr_productivity_branched_9 agr_prod_othweat		
		rename agr_productivity_branched_10 agr_prod_othcc	
		rename agr_productivity_branched_11 agr_prod_othnotcc	
		rename agr_productivity_branched__888 agr_prod_refuse	
		
		foreach var of varlist agr_prod_* {
			cap replace `var' = .r if agr_prod_refuse == .r
		}
		
	tab agr_conseq , m

*	if pilot == 1 {
*		rename agr_conseq_1 agr_conseq_more 
*		rename agr_conseq_2 agr_conseq_less 
*		rename agr_conseq_3 agr_conseq_lesstime 
*		rename agr_conseq_4 agr_conseq_moretime 
*		rename agr_conseq_98 agr_conseq_morewomen 
*		rename agr_conseq_99 agr_conseq_womenoutside 
*		rename agr_conseq_5 agr_conseq_loans 
*		rename agr_conseq_6 agr_conseq_kids 
*	}
	
*	else {
		rename agr_conseq_1 	agr_conseq_lessmoney 
		rename agr_conseq_98 	agr_conseq_morewomen 
		rename agr_conseq_99 	agr_conseq_womenoutside 
		rename agr_conseq_2 	agr_conseq_kids 
		rename agr_conseq_3 	agr_conseq_lesstime 
		rename agr_conseq_4 	agr_conseq_moretime 
*		}
		
	tab agr_exp, m

/* Willingness to Pay equivalent conjoint ______________________________________*/

		gen resp_coupled = (resp_marital_status == "1" | resp_marital_status == "2" | resp_marital_status == "3")

*
																				* BM:  need to clean let her go!!!

		* merge answers from different subject pools, and create dependent variables
		
			* first question
			gen wtp_choice_a1 = .
				replace wtp_choice_a1 = . if sc_wtpconj_1rep == 0 | sc_wtpconj_um_1rep == 0 | sc_wtpconj_w_1rep == 0 | sc_wtpconj_w_um_1rep == 0
				replace wtp_choice_a1 = 1 if sc_wtpconj_1rep == 1 | sc_wtpconj_um_1rep == 1 | sc_wtpconj_w_1rep == 1 | sc_wtpconj_w_um_1rep == 1
				replace wtp_choice_a1 = 0 if sc_wtpconj_1rep == 2 | sc_wtpconj_um_1rep == 2 | sc_wtpconj_w_1rep == 2 | sc_wtpconj_w_um_1rep == 2
				
				cap la de wtp_choice_a1 	1 "Chosen" 0 "Not Chosen"
				la val wtp_choice_a1 	wtp_choice_a1
			
			recode wtp_choice_a1 (1 = 0)(0 = 1), gen(wtp_choice_b1)
			
			tab wtp_choice_a1 wtp_choice_b1
			
			* second question 		
			gen wtp_choice_a2 = .
				replace wtp_choice_a2 = . if sc_wtpconj_2rep == 0 | sc_wtpconj_um_2rep == 0 | sc_wtpconj_w_2rep == 0 | sc_wtpconj_w_um_2rep == 0
				replace wtp_choice_a2 = 1 if sc_wtpconj_2rep == 1 | sc_wtpconj_um_2rep == 1 | sc_wtpconj_w_2rep == 1 | sc_wtpconj_w_um_2rep == 1
				replace wtp_choice_a2 = 0 if sc_wtpconj_2rep == 2 | sc_wtpconj_um_2rep == 2 | sc_wtpconj_w_2rep == 2 | sc_wtpconj_w_um_2rep == 2
				
				cap la de wtp_choice_a2 	1 "Chosen" 0 "Not Chosen"
				la val wtp_choice_a2 	wtp_choice_a2
			
			recode wtp_choice_a2 (1 = 0)(0 = 1), gen(wtp_choice_b2)		
			
			tab wtp_choice_a2 wtp_choice_b2
			
			
		* create choice profile
		
		rename rand_price1_txt wtp_price_a1 
		rename rand_price2_txt wtp_price_b1 
		rename rand_price3_txt wtp_price_a2 
		rename rand_price4_txt wtp_price_b2 
		
		rename rand_safety1_txt wtp_safety_a1
		rename rand_safety2_txt wtp_safety_b1
		rename rand_safety3_txt wtp_safety_a2
		rename rand_safety4_txt wtp_safety_b2
		
	/*
	preserve	
		
		reshape long 	wtp_choice_a wtp_choice_b ///
						wtp_price_a wtp_price_b ///
						wtp_safety_a wtp_safety_b, i(resp_id) j(wtp_choicenum)
						
		rename wtp_choice_a wtp_choice_1 
		rename wtp_choice_b wtp_choice_2
		rename wtp_price_a wtp_price_1
		rename wtp_price_b wtp_price_2
		rename wtp_safety_a wtp_safety_1 
		rename wtp_safety_b wtp_safety_2 
		
		tostring wtp_choicenum, replace
		gen wtp_choice_uid = resp_id + "_" + wtp_choicenum
		reshape long wtp_choice_ wtp_price_ wtp_safety_, i(wtp_choice_uid) j(wtp_profilenum)
		
		
		keep resp_id resp_female resp_coupled treat wtp_* treat
		
		rename *_ *
		drop if wtp_choice == .

		la de wtp_choice 	1 "Chosen" 0 "Not Chosen"
		la val wtp_choice 	wtp_choice
		
		gen wtp_safety_c = (wtp_safety == "WHOM WE KNOW AND TRUST")
		la de wtp_safety_c 	1 "Safe" 0 "[blank]"
		la val wtp_safety_c wtp_safety_c
		
		destring wtp_price, replace
		
		* check results
		
		*reg wtp_choice wtp_price treat##wtp_safety_c, cluster(resp_id)	
		*reg wtp_choice wtp_price wtp_safety_c, cluster(resp_id)		

		tab wtp_choice wtp_safety_c
		*table  wtp_safety_c , stat(mean wtp_choice)		
		bys resp_female : tab wtp_choice wtp_safety_c
		
		*reg wtp_choice treat##c.wtp_price treat##wtp_safety_c, cluster(resp_id)		
		tab wtp_choice treat, m
		*table  treat , stat(mean wtp_choice)		

		save "${data_endline}/pfm5_endline_cleaned_field_research_wtp.dta" , replace
	restore	
	*/
		
/* Willingness to Pay______________________________________
		
    rename  boda_15_sec1_2_1   boda_0
	rename  boda_15_sec1_2_3   boda_1000
	rename  boda_15_sec1_2_5   boda_2750
	rename  boda_15_sec1_2_7   boda_4500
	rename  boda_15_sec1_2_9   boda_6250
	rename  boda_15_sec1_2_11  boda_8000
	rename  boda_15_sec1_2_13  boda_9750
	rename  boda_15_sec1_2_15  boda_11500 
	rename  boda_15_sec1_2_17  boda_13250
	rename  boda_15_sec1_2_19  boda_15000

	rename  boda_15_sec1_2_32a max_wtp
	la var  max_wtp "maximum willigness to pay"
	
	gen max_wtp_abovemkt = (max_wtp >= 9750)

*/
	
/* Radio distribution compliance _______________________________________________*/

	rename s30q1 rd_receive
	rename s30q2 rd_receive_stillhave
	rename s30q3 rd_receive_whylost
	rename s30q4 rd_receive_stillhave_confirm
	rename s30q5 rd_receive_stillhave_working
	rename s30q6 rd_receive_stillhave_whynowork
	rename s30q7 rd_receive_wholisten 
	rename s30q8 rd_receive_primarycontrol
	
	foreach var of varlist rd_receive_* {
		tab `var', m
	}
	
/* Audio screening compliance __________________________________________________*/

	fre compliance_topic
	fre compliance_discuss
	fre compliance_topic

	
	/* Re-insert village_uids ______________________________________________________


	replace id_village_uid = "2_121_5" if village_pull == "Chepete"
	replace id_village_uid = "8_91_5" if village_pull == "Churwa"
	replace id_village_uid = "2_81_5" if village_pull == "Kwakibomi"
	replace id_village_uid = "2_121_1" if village_pull == "Madala"
	replace id_village_uid = "8_141_2" if village_pull == "Mapatano"
	replace id_village_uid = "8_91_2" if village_pull == "Mhinduro"
	replace id_village_uid = "3_11_2" if village_pull == "Misozwe"
	replace id_village_uid = "2_81_3" if village_pull == "Msasa"
	replace id_village_uid = "8_141_3" if village_pull == "Mtakuja"
	replace id_village_uid = "3_11_4" if village_pull == "Mwarimba"
	replace id_village_uid = "2_101_7" if village_pull == "Welei"
	replace id_village_uid = "2_181_1" if village_pull == "Kwemanolo"
	replace id_village_uid = "2_181_2" if village_pull == "Mali"
	replace id_village_uid = "2_101_5" if village_pull == "Masange"
	replace id_village_uid = "2_91_7" if village_pull == "Shalaka"
	replace id_village_uid = "2_91_1" if village_pull == "Kwemshai"
	replace id_village_uid = "2_201_2" if village_pull == "Changalikwa"
	replace id_village_uid = "2_201_1" if village_pull == "Makole"
		
	replace id_village_uid = "2_191_7" if village_pull == "Gombalamu"
	replace id_village_uid = "2_191_1" if village_pull == "Mafuleta"
	replace id_village_uid = "1_71_3" if village_pull == "Nkamai"
	replace id_village_uid = "1_71_4" if village_pull == "Mponde"
	replace id_village_uid = "1_421_4" if village_pull == "Kwendoghoi"
	replace id_village_uid = "1_421_1" if village_pull == "Kwamzuza"	
	
	replace id_village_uid = "8_181_1" if village_pull == "Boma kichakamiba"
	replace id_village_uid = "8_181_2" if village_pull == "Subutuni"
	replace id_village_uid = "8_211_1" if village_pull == "Kibewani"
	replace id_village_uid = "8_211_2" if village_pull == "Kilulu - Duga"
	replace id_village_uid = "8_191_2" if village_pull == "Parungu Kasera"
	replace id_village_uid = "8_191_3" if village_pull == "Mzingi Mwagogo"

	replace id_village_uid = "8_81_2" if village_pull == "Vunge Manyinyi"
	replace id_village_uid = "8_81_4" if village_pull == "Dima"
	replace id_village_uid = "8_61_1" if village_pull == "Kichalikani"
	replace id_village_uid = "8_61_2" if village_pull == "Mongavyeru"	

*/
	
/* Save ________________________________________________________________________*/	
	
	drop treat treat_original treat_rd treat_rd_original 

	save "${data}/02_mid_data/pfm_as2_endline_clean_partner.dta" , replace
	*use "${data_endline}/pfm5_endline_cleaned_field_research.dta" , clear

	
	
/*
	
	/* GBV Indices _________________________________________________________________*/


		* Keep 
		#d ;
		keep 					resp_id
								treat
								gbv_travel_risky_short
								gbv_boda_risky_short
								gbv_worry_ride
								gbv_safe_streets_self_short
								gbv_safe_party_self
								gbv_travel_risky_norm 
								gbv_boda_risky_norm
								gbv_safe_party_norm
								gbv_response
								gbv_response_gov
								gbv_testify
								gbv_response_norm
								gbv_response_norm_gov
								gbv_testify_norm
								ptixpart_raiseissue_gbv
								ptixpart_raiseissue_safe
								gbv_elect 
								ptixpref1_rank_gbv 
								socpref2_rank_women
								thermo_boda_num
								ptixpref1_partner_gbv
								socpref2_partner_gbv
								ge_school	
								ipv_reject_gossip
								parenting_permission
								;
		#d cr 

		* GBV Index 
		rename gbv_travel_risky_* gbv_risky_travel_* 
		rename gbv_boda_risky_* gbv_risky_boda_* 
			rename gbv_worry_ride gbv_suspect_ride 
			
		egen gbv_risk_index = rowmean(gbv_risky_travel_short gbv_risky_boda_short ///
										gbv_suspect_ride gbv_safe_party_self gbv_safe_streets_self_short)
		
		egen gbv_risk_norm_index = rowmean(gbv_risky_travel_norm gbv_risky_boda_norm ///
											gbv_safe_party_norm)
			

		egen gbv_response_index = rowmean(gbv_response_gov gbv_testify)		
		egen gbv_response_norm_index = rowmean(gbv_response_norm_gov gbv_testify_norm)
		
		gen ptixpref1_rank_gbv_short = (ptixpref1_rank_gbv-1)/2 
		gen socpref2_rank_women_short = (socpref2_rank_women-1)/3
		
		egen gbv_prior_index = rowmean(gbv_elect ptixpref1_rank_gbv_short ///
										socpref2_rank_women_short)
		
		egen gbv_partner_prior_index = rowmean(ptixpref1_partner_gbv socpref2_partner_gbv)
		
		gen gbv_parent_permission = (parenting_permission-1)/3
		
		gen thermo_boda_short = thermo_boda_num/100
		
		rename * e_*
		rename e_resp_id resp_id 
		rename e_treat treat

		save "${data_bb}/pfm_gbv_endline_p.dta", replace

		
	/* Enviro Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_cleaned_field_research_p.dta", clear
		
		gen enviro_ccknow_short = enviro_ccknow_mean_dum
		gen enviro_cause_human_short = enviro_cause_human/2
		egen enviro_know_index = rowmean(enviro_ccknow_mean_dum enviro_cause_human_short enviro_cause_intl)

		
		egen enviro_attitudes_index = rowmean(enviro_attitudes enviro_voteenviro)
			
		gen ptixpref2_rank_enviro_short = (ptixpref2_rank_enviro-1)/2 
		gen socpref1_rank_enviro_short = (socpref1_rank_enviro-1)/3
		egen enviro_prior_index = rowmean(enviro_elect ptixpref2_rank_enviro_short ///
										socpref1_rank_enviro_short)
										
		egen enviro_partner_prior_index = rowmean(ptixpref2_partner_enviro socpref1_partner_enviro)
		
		gen socpref1_rank_bribes_short = socpref1_rank_bribes/4
		gen thermo_leader_short = thermo_local_leader_num/100
		egen corruption_index = rowmean(ppart_corruption socpref1_rank_bribes_short thermo_leader_short)	
		
		

		
		* Keep 

		#d ;
		keep 					resp_id
								treat
								enviro_know_index
								enviro_ccknow_short 
								enviro_cause_human_short
								enviro_cause_intl
								enviro_attitudes_index
								enviro_attitudes
								enviro_voteenviro
								enviro_norm
								ptixpart_raiseissue_enviro
								ptixpart_raiseissue_corrupt
								enviro_prior_index
								enviro_elect
								ptixpref2_rank_enviro_short
								socpref1_rank_enviro_short
								enviro_partner_prior_index
								ptixpref2_partner_enviro
								socpref1_partner_enviro
								thermo_business
								corruption_index
								ppart_corruption
								socpref1_rank_bribes
								thermo_leader
								;
		#d cr
		
		rename * e_*
		rename e_treat treat
		rename e_resp_id resp_id 
		
		
		save "${data_env}/pfm_enviro_endline_p.dta", replace

		
	/* WPP Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_cleaned_field_research_p.dta", clear
		
		
		#d ;
		keep 					resp_id
								wpp_behavior 
								wpp_behavior_self_short
								wpp_behavior_wife 
								wpp_behavior_adult 
								wpp_attitude2_dum 
								;
		#d cr
		
		rename * yr_* 
		rename yr_resp_id resp_id 
		
		save "${data_wpp}/pfm_wpp_endline_p.dta", replace						
				
				

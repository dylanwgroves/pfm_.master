/*______________________________________________________________________________

	Project: Pangani FM 2
	File: AS2 Endline Cleaning
	Date: 2023.11
	Author: 
		Dylan Groves, dylanwgroves@gmail.com
		Beatrice Montano, bm2955@columbia.com
_______________________________________________________________________________*/


/* Stata Prep ___________________________________________________________________*/

	clear all 	
	clear matrix
	clear mata
	set more off 
	set maxvar 30000
	version 16

/* Set Seed ___________________________________________________________*/

	set seed 1956
	
/* Load Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_nopii_as2_endline.dta", clear
	
	gen as2_endline = 1

/* ID information  _________________________________________________________*/

	replace resp_id = "2_101_5_01" if resp_id == "2_101_5_001"
	replace resp_id = "2_101_5_04" if resp_id == "2_101_5_004"

	drop resp_id_pull id id_re 
	
	replace id_village_uid 			= substr(resp_id, 1, (strlen(resp_id)-4))
	gen 	id_ward_uid 			= substr(id_village_uid, 1, (strlen(id_village_uid)-2))
			
	gen id_resp_c 				= substr(resp_id, -3, 3)
			lab var id_resp_c "Respondent Code"
	
		
/* Pulled treatment assignment _________________________________________________*/

	destring treat_pull, replace
	rename treat_pull treat
	la de treat 0 "env" 1 "gbv"
	la val treat treat

	gen treat_rd = radio_treat 
	la de treat_rd 0 "flashlight" 1 "radio"
	la val treat_rd treat_rd
	drop rd_sample treat_rd_pull


/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"

/* Pulled Data / Confirmations _________________________________________________*/

	tab info_confirm														

	rename info_correction_1	correction_name
	rename info_correction_2	correction_age
	rename info_correction_3	correction_marital
	rename info_correction_4	correction_village
	rename info_correction_5	correction_subvillage
	
	* gender 
	destring resp_female, replace
	lab def resp_female 0 "Male" 1 "Female"
	lab val resp_female resp_female 
	drop gender_correction gender_confirm gender_pull gender_pull_txt resp_sex
	
	* name
	* eye check: correct_name // all good, it's just spelling for all of them
	*replace resp_name = name_pull if resp_name == ""
	*replace resp_name = correct_name if correct_name != ""
	*drop correction_name correct_name name_pull
	
	* village
	* eye check: correct_village correct_subvillage
	 *drop village_pull correction_village correct_village sub_village_pull correction_subvillage correct_subvillage
	 
	* age
	destring resp_age , replace
	destring age_pull , replace
	replace resp_age = age_pull if resp_age == .
	replace resp_age = correct_age if correction_age == 1 & resp_age < correct_age & correct_age != . 
	drop age_pull correct_age correction_age
	
	* marital status
	destring resp_marital_status, replace
	replace resp_marital_status = correct_marital_status if correction_marital == 1
	lab val resp_marital_status correct_marital_status
	drop correction_marital correct_marital_status resp_mar_sta_pull_txt_sw resp_marital_status_pull resp_marital_status_pull_txt 
	
	* religion: resp_religion_txt_pull
	drop resp_religion_txt_swa_pull
	
/* Survey Information __________________________________________________________*/

	rename visits_nbr svy_visitsnum
	
	label define enum 1 "Robert Mwandumbya" 2 "Neema Msechu" 3 "Management" 4 "Atwisile Jackson" 5 "Yasinta Moshi" 6 "Kassim Abdallah" 7 "Lusekelo Andrew" 8 "Frank Simon" 9 "Mary Temba" 10 "Silvana Karia" 11 "Charles Nzota" 12 "Michael Mwaigombe" 13 "Jenister Anthony" 14 "Husna Majura" 15 "Jackline Joseph" 16 "Rashid Seif" 17 "Aneth Juma" 18 "Aisha Amiri" 19 "Cosmas Sway" 20 "Jackson Bukuru" , modify
	label values enum enum
	drop  enum_followup
	rename enum svy_enum

	rename consent svy_consent 
	
	
/* Respondent Information ______________________________________________________*/

	tab resp_describe_day, m
	
	gen resp_tribe_sambaa = (resp_tribe == 32)
	gen resp_tribe_digo = (resp_tribe == 38)
	
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
	drop kids_anydaughter14yo
	tab kids_num, m
		replace kids_num = 0 if kids_anykids == 0 

	
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
			lab def gbv_elect 1 "Stop GBV Vote" 0 "Other Vote"
			lab val gbv_elect gbv_elect 
			
		* Enviro
		gen enviro_elect = s3q4b_1 
			replace enviro_elect = 0 if enviro_elect == 2
			replace enviro_elect = 1 if s3q4b_2 == 2 
			replace enviro_elect = 0 if s3q4b_2 == 1
			lab def enviro_elect 1 "Enviro Vote" 0 "Other Vote"
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
		
	recode env_ccknow_mean (1 2 3 = 1)(4 5 6 7 -888 -999 .d = 0), gen(enviro_ccknow_mean_dum)
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
	lab def ge_school_new 1 "Girls Equal Edu" 0 "Boys > Girls Edu"
	lab val ge_school ge_school_new
	
	recode ipv_attitudes (1=0 "Accept IPV (gossip)")(0=1 "Reject IPV (gossip)"), gen(ipv_reject_gossip)	// DWG
	gen ipv_reject_long_gossip = 0 if ipv_hithard == 2
		replace ipv_reject_long_gossip = 1 if ipv_hithard == 1 & ipv_reject_gossip == 0
		replace ipv_reject_long_gossip = 2 if ipv_reject_gossip == 1 & ipv_persist == 1
		replace ipv_reject_long_gossip = 3 if ipv_reject_gossip == 1 & ipv_persist == 0
		lab def ipv_reject_long_gossip 0 "More than slap" 1 "Slap" 2 "If persists" 3 "Never"
		lab val ipv_reject_long_gossip ipv_reject_long_gossip
		
	foreach var of varlist ge_* ipv_* {
		cap fre `var'
	}
		
		
/* GBV _________________________________________________________________________*/
	
	
	* worry ride
	recode gbv_worry_ride (2=1 "Risky") (1=0 "Safe"), gen(gbv_worry_ride_short)
	
	* risky travel att + norm
	recode gbv_safe_travel (2 = 1 "Risky")(1 = 0 "Safe"), gen(gbv_travel_risky_short)
	
	gen gbv_travel_risky_long = gbv_travel_risky_short
	replace gbv_travel_risky_long = 0 if gbv_safe_travel_bu==0
	replace gbv_travel_risky_long = 1 if gbv_safe_travel_bu==1
	replace gbv_travel_risky_long = 2 if gbv_safe_travel_bd==2
	replace gbv_travel_risky_long = 3 if gbv_safe_travel_bd==3
	lab def gbv_travel_risky_long 0 "Very safe" 1 "Safe enough" 2 "Quite risky" 3 "Very risky"
	lab val gbv_travel_risky_long gbv_travel_risky_long
	
	recode gbv_safe_travel_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_travel_risky_norm)

	tab 	end_gbv_norm_rand_txt
	tab 	gbv_travel_risky_norm end_gbv_norm_rand_txt

																				
	* risky boda att + norm
	recode gbv_safe_boda (2 = 1 "Generally risky")(1 = 0 "Generally safe"), gen(gbv_boda_risky_short)
	
	gen gbv_boda_risky_long = gbv_boda_risky_short
	replace gbv_boda_risky_long = 0 if gbv_safe_boda_bu==0
	replace gbv_boda_risky_long = 1 if gbv_safe_boda_bu==1
	replace gbv_boda_risky_long = 2 if gbv_safe_boda_bd==2
	replace gbv_boda_risky_long = 3 if gbv_safe_boda_bd==3
	lab def gbv_boda_risky_long 0 "Very safe" 1 "Safe enough" 2 "Quite risky" 3 "Very risky"
	lab val gbv_boda_risky_long gbv_boda_risky_long

	recode gbv_safe_boda_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_boda_risky_norm)
	
	tab 	end_gbv_norm_rand_txt
	tab 	gbv_boda_risky_norm end_gbv_norm_rand_txt

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
	
	gen prej_yesnbr_hiv = neighbor_hiv
	gen prej_yesnbr_unmarried = neighbor_unmarried
	gen prej_yesnbr_albino = neighbor_albino
	egen prej_yesnbr_index = rowmean(prej_yesnbr_hiv prej_yesnbr_unmarried prej_yesnbr_albino)
		
/* Kid Marry ___________________________________________________________________*/

	gen prej_kidmarry_notrelig = kidmarry_notreligion
	gen prej_kidmarry_nottribe = kidmarry_nottribe
	gen prej_kidmarry_nottz = kidmarry_nottz
	egen prej_kidmarry_index = rowmean(prej_kidmarry_notrelig prej_kidmarry_nottribe prej_kidmarry_nottz)

	
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
		
	foreach var of varlist ppart_* crime_* {
		fre `var'
	}
		
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


/* Radio ownership _____________________________________________________________*/

	tab radiown_ccm_1 rand_ownership_ccm_1_txt
		gen radioown_ccm_tbc 			= radiown_ccm_1 if rand_ownership_ccm_1_txt == "TBC"
		gen radioown_ccm_tbctaifa		= radiown_ccm_1 if rand_ownership_ccm_1_txt == "TBC Taifa"
		gen radioown_ccm_uhuru 			= radiown_ccm_1 if rand_ownership_ccm_1_txt == "Uhuru"

	rename radiown_ccm_2 radioown_ccm_rfa 
	rename radiown_ccm_3 radioown_ccm_tk
	
	tab radiown_ccm_4 rand_ownership_ccm_4_txt
		gen radioown_ccm_clouds 	= radiown_ccm_4 if rand_ownership_ccm_4_txt == "Clouds"
		gen radioown_ccm_eastafrica = radiown_ccm_4 if rand_ownership_ccm_4_txt == "East Africa Radio"
		gen radioown_ccm_rone 		= radiown_ccm_4 if rand_ownership_ccm_4_txt == "Radio One"
		gen radioown_ccm_voa 		= radiown_ccm_4 if rand_ownership_ccm_4_txt == "Voice of Africa"
		
	gen radiown_cap = (radioown_ccm_rfa+radioown_ccm_tk)/2
	sum radiown_ccm_1 radiown_cap radiown_ccm_4
	
	gen radiown_gov_biased = 0
	replace radiown_gov_biased = 1 if radioown_bias_1st==1 | radioown_bias_1st_norfa==1 | radioown_bias_1st_notk==1 | radioown_bias_1st_noind==1
	tab radiown_gov_biased
	
	gen radiown_rfa_biased = 0
	replace radiown_rfa_biased = 1 if radioown_bias_1st==2 | radioown_bias_1st_noccm==2 | radioown_bias_1st_notk==2 | radioown_bias_1st_noind==2
	tab radiown_rfa_biased
	
	gen radiown_tk_biased = 0
	replace radiown_tk_biased = 1 if radioown_bias_1st==3 | radioown_bias_1st_noccm==3 | radioown_bias_1st_notk==3 | radioown_bias_1st_noind==3
	tab radiown_tk_biased
	
	gen radiown_ind_biased = 0
	replace radiown_ind_biased = 1 if radioown_bias_1st==4 | radioown_bias_1st_noccm==4 | radioown_bias_1st_notk==4 | radioown_bias_1st_noind==4
	tab radiown_ind_biased
	
	gen radiown_cap_biased = (radiown_rfa_biased+radiown_tk_biased)/2
	
	sum radiown_gov_biased radiown_cap_biased radiown_ind_biased
	
	
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
		la de agr_productivity_climate 0 "not climate change" 1 "climate change"
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
		

/* Willingness to Pay equivalent conjoint ______________________________________*/

		gen resp_coupled = (resp_marital_status == 1 | resp_marital_status == 2 | resp_marital_status == 3)

*
		* BM:  need to clean let her go!!!

		* merge answers from different subject pools, and create dependent variables
		
			* first question
			gen wtp_choice_a1 = .
				replace wtp_choice_a1 = . if sc_wtpconj_1rep == 0 | sc_wtpconj_um_1rep == 0 | sc_wtpconj_w_1rep == 0 | sc_wtpconj_w_um_1rep == 0
				replace wtp_choice_a1 = 1 if sc_wtpconj_1rep == 1 | sc_wtpconj_um_1rep == 1 | sc_wtpconj_w_1rep == 1 | sc_wtpconj_w_um_1rep == 1
				replace wtp_choice_a1 = 0 if sc_wtpconj_1rep == 2 | sc_wtpconj_um_1rep == 2 | sc_wtpconj_w_1rep == 2 | sc_wtpconj_w_um_1rep == 2
				
				la de wtp_choice_a1 	1 "Chosen" 0 "Not Chosen"
				la val wtp_choice_a1 	wtp_choice_a1
			
			recode wtp_choice_a1 (1 = 0)(0 = 1), gen(wtp_choice_b1)
			
			tab wtp_choice_a1 wtp_choice_b1
			
			* second question 		
			gen wtp_choice_a2 = .
				replace wtp_choice_a2 = . if sc_wtpconj_2rep == 0 | sc_wtpconj_um_2rep == 0 | sc_wtpconj_w_2rep == 0 | sc_wtpconj_w_um_2rep == 0
				replace wtp_choice_a2 = 1 if sc_wtpconj_2rep == 1 | sc_wtpconj_um_2rep == 1 | sc_wtpconj_w_2rep == 1 | sc_wtpconj_w_um_2rep == 1
				replace wtp_choice_a2 = 0 if sc_wtpconj_2rep == 2 | sc_wtpconj_um_2rep == 2 | sc_wtpconj_w_2rep == 2 | sc_wtpconj_w_um_2rep == 2
				
				la de wtp_choice_a2 	1 "Chosen" 0 "Not Chosen"
				la val wtp_choice_a2 	wtp_choice_a2
			
			recode wtp_choice_a2 (1 = 0)(0 = 1), gen(wtp_choice_b2)		
			
			tab wtp_choice_a2 wtp_choice_b2
			
			
		* create choice profile
		
		gen wtp_price_a1 = rand_price1_txt 
		gen wtp_price_b1 = rand_price2_txt 
		gen wtp_price_a2 = rand_price3_txt 
		gen wtp_price_b2 = rand_price4_txt 
		
		gen wtp_safety_a1 = rand_safety1_txt 
		gen wtp_safety_b1 = rand_safety2_txt 
		gen wtp_safety_a2 = rand_safety3_txt 
		gen wtp_safety_b2 = rand_safety4_txt 
		
	/* preserve	
	preserve		
		reshape long 	wtp_choice_a wtp_choice_b ///
						wtp_price_a wtp_price_b ///
						wtp_safety_a wtp_safety_b, i(resp_id) j(wtp_choicenum)
						
		gen wtp_choice_1  = wtp_choice_a 
		gen wtp_choice_2 = wtp_choice_b 
		gen wtp_price_1 = wtp_price_a 	
		gen wtp_price_2 = wtp_price_b 
		gen wtp_safety_1  = wtp_safety_a 
		gen wtp_safety_2  = wtp_safety_b 
		
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
		*reg wtp_choice wtp_price wtp_safety_c, cluster(resp_id)		
		*reg wtp_choice wtp_price##wtp_safety_c, cluster(resp_id)		

		tab wtp_choice wtp_safety_c
		*table  wtp_safety_c , stat(mean wtp_choice)		
		bys resp_female : tab wtp_choice wtp_safety_c
		
		reg wtp_choice treat##c.wtp_price treat##wtp_safety_c, cluster(resp_id)		
		reg wtp_choice treat##c.wtp_safety_c, cluster(resp_id)
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
		replace rd_receive = 0 if rd_sample_pull == "1" & rd_receive != 1
	rename s30q2 rd_stillhave
		replace rd_stillhave = 0 if rd_receive == 0
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
	fre compliance_discuss_who

	rename compliance_discuss_who_1 compliance_discuss_spouse
	rename compliance_discuss_who_2 compliance_discuss_kid
	rename compliance_discuss_who_3 compliance_discuss_sibling
	rename compliance_discuss_who_4 compliance_discuss_father
	rename compliance_discuss_who_5 compliance_discuss_mother
	rename compliance_discuss_who_6 compliance_discuss_auntuncle
	rename compliance_discuss_who_7 compliance_discuss_gparent
	rename compliance_discuss_who_8 compliance_discuss_cousin
	rename compliance_discuss_who_9 compliance_discuss_leader
	rename compliance_discuss_who_10 compliance_discuss_othercomm

	
/* Audio screening ethics ______________________________________________________*/

	fre bb_ethics_sample
	fre bb_ethics
	fre bb_ethics_trouble
  

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

	sort id_* *_id
	order id_ward_uid id_village_uid resp_id svy_enum  
	
	drop treat treat_rd
	
	label drop enum
	
	save "${data}/02_mid_data/pfm_as2_endline_clean.dta", replace

	
	
	
/*
	save "${data_endline}/pfm5_endline_cleaned_field_research_nomergedinfo.dta", replace
	

	/* Map locations ___________________________________________________________*/
	
	drop if treat == . 
	duplicates drop id_village_uid, force 

	keep treat id_village_uid village_pull Ward_Name District_N gpslongitude gpslatitude
	
	
	export delimited using "${data_bb}\pfm_bb_map.csv", replace
	
	recode treat (0=1)(1=0)
	export delimited using "${data_env}\pfm_enviro_map.csv", replace
	

	/* GBV Indices _____________________________________________________________*/
	
		* load data
		use "${data_endline}/pfm5_endline_cleaned_field_research.dta", clear 
		
		* keep certain variables 
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
								startdate
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
		
		save "${data_bb}/pfm_gbv_endline.dta", replace

		
	/* Enviro Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_endline_cleaned_field_research.dta", clear
		
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
		
		
		rename * e_*
		rename e_resp_id resp_id 
		
		* Keep 
		rename e_treat treat
		#d ;
		keep 					resp_id
								treat
								e_enviro_know_index
								e_enviro_ccknow_short 
								e_enviro_cause_human_short
								e_enviro_cause_intl
								e_enviro_attitudes_index
								e_enviro_attitudes
								e_enviro_voteenviro
								e_enviro_norm
								e_ptixpart_raiseissue_enviro
								e_ptixpart_raiseissue_corrupt
								e_enviro_prior_index
								e_enviro_elect
								e_ptixpref2_rank_enviro_short
								e_socpref1_rank_enviro_short
								e_enviro_partner_prior_index
								e_ptixpref2_partner_enviro
								e_socpref1_partner_enviro
								e_thermo_business
								e_corruption_index
								e_ppart_corruption
								e_socpref1_rank_bribes
								e_thermo_leader
								e_startdate
								;
		#d cr
		
		
		save "${data_env}/pfm_enviro_endline.dta", replace

		
	/* WPP Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_endline_cleaned_field_research.dta", clear
		
		
		#d ;
		keep 					resp_id
								wpp_behavior 
								wpp_behavior_self_short
								wpp_behavior_wife 
								wpp_behavior_adult 
								wpp_attitude2_dum 
								startdate
								;
		#d cr
		
		rename * yr_* 
		rename yr_resp_id resp_id 
		
		save "${data_wpp}/pfm_wpp_endline.dta", replace

	
*/
											
				
				

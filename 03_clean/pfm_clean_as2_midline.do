/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Midline Cleaning
	Date: 2023.10.28
	Author: Dylan Groves, dylanwgroves@gmail.com
_______________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	*version 15
	clear all
	set maxvar 30000
	set more off

	
/* Load Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_pii_as2_midline.dta", clear
	gen as2_midline = 1
	
/* Remove Labels _______________________________________________________________*/

	cap drop *_label

	
/* ID information  _________________________________________________________*/

*	replace resp_id = "2_101_5_001" if resp_id == "2_101_5_01"
*	replace resp_id = "2_101_5_004" if resp_id == "2_101_5_04"

	gen id_village_uid 			= substr(resp_id, 1, (strlen(resp_id)-4))
	gen id_ward_uid 			= substr(id_village_uid, 1, (strlen(id_village_uid)-2))
			
		gen id_resp_c = id_re
			lab var id_resp_c "Respondent Code"
			
			
/* Village information  ________________________________________________________	
** WHERE IS RESPONDENT NAME**
/*
		gen id_resp_n = b_resp_name
			lab var id_resp_n "Respondent Name"

		egen id_ward_uid = concat(district_code ward_code), punct("_")
			lab var id_ward_uid "Ward Unique ID"
			
		egen id_village_uid = concat(district_code ward_code village_code), punct("_")
			lab var id_village_uid "Village Unique ID"
			
		egen id_resp_uid = concat(id_village_uid id_resp_c), punct("_")				
			lab var id_resp_uid "Respondent Unique ID"
*/			
/*WHERE IS OBJECT ID
		gen id_objectid = objectid
			lab var id_objectid "(TZ Census) Object ID"
*/
*/		



/* Respondent Information ______________________________________________________*/

	*rename resp_wear_ppe resp_ppe
	rename resp_female resp_female 
	rename resp_describe_day resp_howudoin
	
	foreach var of varlist resp_* {
	
		cap recode `var' (-999 = .d)(-888 = .r)(-222 = .o)
		
	}
	
	
	rename resp_sect_1 resp_muslim_hanfi 
	rename resp_sect_2 resp_muslim_hanbali 
	rename resp_sect_3 resp_muslim_maliki 
	rename resp_sect_4 resp_muslim_shafii 
	rename resp_sect_5 resp_muslim_salafi 
	rename resp_sect_6 resp_muslim_answali 
	rename resp_sect_7 resp_muslim_hamadia 
	rename resp_sect_8 resp_muslim_hana 
	rename resp_sect_9 resp_muslim_suni 
	rename resp_sect_10 resp_muslim_anashriki 
	rename resp_sect_11 resp_muslim_bakwata 
	rename resp_sect_12 resp_muslm_swala 
	rename resp_sect__222 resp_muslim_oth 
	rename resp_sect__999 resp_muslim_ref 
	rename resp_sect__888 resp_muslim_dk

	foreach var of varlist resp_muslim_* {
	
		tab `var'
		
	}


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
	
	/*
	gen t_elect_enviro_altcrime = .
		replace t_elect_enviro_altcrime = 
	*/

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
	

/* Environment Causes __________________________________________________________*/

	gen enviro_ccknow_dum = (env_ccknow == 1)
		lab var enviro_ccknow_dum "Dummy: 1 = Knows of climate change"
		
	recode env_ccknow_mean (1 2 3 = 1)(4 5 6 7 -888 -999 = 0), gen(enviro_ccknow_mean_dum)
	lab var enviro_ccknow_mean_dum "Dummy: Know meaning of climate change"
	
	gen enviro_ccknow_long = enviro_ccknow_mean_dum + 1
		replace enviro_ccknow_long = 0 if enviro_ccknow_dum == 0 
		lab def enviro_ccknow_long 0 "Never Heard of CC" 1 "Heard of CC but no meaning" 2 "Heard of CC + know meaning"
		lab val enviro_ccknow_long enviro_ccknow_long 
		lab var enviro_ccknow_long "Long (0-2): Know of climate change"
	
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
	
	egen enviro_cause_second_humans = 	rowmax(enviro_cause_second_vill ///
											enviro_cause_second_othvill ///
											enviro_cause_second_othtz ///
											enviro_cause_second_intl ///
											enviro_cause_second_gov)
											
	recode env_cause (4 5 6 7 8 = 2)(1 2 3 9 10 -222 -999 = 0), gen(enviro_cause_human)
	lab var enviro_cause_human "Dummy: climate changed caused by humans"
	replace enviro_cause_human = 1 if enviro_cause_second_humans == 1 & enviro_cause_human == 0
	
	
	
	recode env_cause (7 = 2)(1 2 3 4 5 6 8 9 10 -222 -999 = 0), gen(enviro_cause_intl)
	lab var enviro_cause_intl "Dummy: climate changed caused by international folks"
	replace enviro_cause_intl = 1 if enviro_cause_second_intl == 1 & enviro_cause_intl == 0
		
	
/* Gender ______________________________________________________________________*/

	fre ge_school
	recode ge_school (2 = 1)(1 = 0)
	lab def ge_school_new 1 "Girls Equal Edu" 0 "Boys > Girls Edu"
	lab val ge_school ge_school_new
	
	recode ipv_attitudes (1=0 "Accept IPV (gossip)")(0=1 "Reject IPV (gossip)"), gen(ipv_reject_gossip)
	gen ipv_reject_long_gossip = 0 if ipv_hithard == 2
		replace ipv_reject_long_gossip = 1 if ipv_hithard == 1 & ipv_reject_gossip == 0
		replace ipv_reject_long_gossip = 2 if ipv_reject_gossip == 1 & ipv_persist == 1
		replace ipv_reject_long_gossip = 3 if ipv_reject_gossip == 1 & ipv_persist == 0
		
/* GBV _________________________________________________________________________*/

	* Treatment
	rename gbv_norm_rand_txt t_gbv_gender 
	
	drop gbv_safe_alone_dark

	rename gbv_safe_boda gbv_risky_boda
		lab val gbv_risky_boda gbv_safe_travel
	rename gbv_safe_travel gbv_risky_travel

	drop gbv_safe_dark_norm
	
	recode gbv_safe_boda_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_boda_norm)
		lab var gbv_risky_boda_norm "Others think boda risky"
		
	recode gbv_safe_travel_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_travel_norm)
		lab var gbv_risky_travel_norm "Others thing travel alone risky"

	rename gbv_safe_party_self gbv_nopartyalone
	rename gbv_safe_party_norm gbv_nopartyalone_norm
	
	
	* GBV Worry Gifts
	recode gbv_worry_gifts (1 = 0 "Innocent")(2 = 1 "Suspicious"), gen(gbv_suspect_gifts)
		lab var gbv_suspect_gifts "Suspicious for man to gift young girl gifts?"
		drop gbv_worry_gifts
		
	recode gbv_worry_ride (1 = 0 "Innocent")(2 = 1 "Suspicious"), gen(gbv_suspect_ride)
		lab var gbv_suspect_ride "Suspicious for man to offer rides?"
		drop gbv_worry_ride 
	
		
	* GBV Response
	gen gbv_response_dum = (gbv_response == 2)
	lab var gbv_response_dum "Report GBV to Gov"
	lab def gbv_response_dum 0 "Dont report to gov" 1 "Report to gov"
	lab val gbv_response_dum gbv_response_dum 
	
	* Response Norms
	gen gbv_response_norm_dum = (gbv_response_norm == 2)
	lab var gbv_response_norm_dum "Report GBV to Gov"
	lab def gbv_response_norm_dum 0 "Dont report to gov" 1 "Report to gov"
	lab val gbv_response_norm_dum gbv_response_norm_dum 

	
/* Environment Outcomes ________________________________________________________*/

	recode envatt_general (1 = 1 "Enviro > Dev Projects")(2 = 0 "Dev Projects > Enviro"), gen(enviro_attitudes)
		lab var enviro_attitudes "Enviro over dev projects"
	
	recode envoutcm_cutting_wood (1 = 0 "OK to cut trees fine")(2 = 1 "Dont cut trees"), gen(enviro_dontcut)
		lab var enviro_dontcut "Enviro dont cut"
	
	recode envatt_firewood_norm (1 = 0 "Cut trees fine")(2 = 1 "Dont cut trees"), gen(enviro_dontcut_norm)
		lab var enviro_dontcut_norm "Enviro dont cut norm"
	
	recode envoutcm_politician (1 = 0 "Sell the forest land")(2 = 1 "Protect the land"), gen(enviro_voteenviro)
		lab var enviro_voteenviro "Enviro vote (not vignette)"
	
	recode envoutcm_start_fire (1 = 1 "Report firestarters")(2 = 0 "Dont report firestarters"), gen(enviro_reportfires)
		lab var enviro_reportfires "Enviro report fires"
	
	
/* Court Outcomes ______________________________________________________________*/

		* Treat 
		rename court1_rand_txt t_enviro_punish_rich
		rename court2_rand_txt t_gbv_punish_rich
		
		rename court_judge_sentense1 steal_punish
			
		rename court_judge_sentense2 enviro_punish

		rename court_judge_sentense3 gbv_punish 
			
		foreach var of varlist steal_punish gbv_punish enviro_punish {
			
			destring `var', replace
			lab def `var' 0 "No Punish" 1 "Fine" 2 "A few days" 3 "A few months" 4 "1 year in jail" 5 "Between 1 and 5 years" 6 "More than 5 years in jail"
			lab val `var' `var'
		
		}
	
	recode court_boda_sex (2 = 0 "Dont Testity")(1 =1 "Do testify"), gen(gbv_testify)
		lab var gbv_testify "Testify on GBV: self"
	
	recode court_boda_sex_norm (2 = 0 "Dont Testity")(1 =1 "Do testify"), gen(gbv_testify_norm)
		lab var gbv_testify_norm "Testify on GBV: norm"
	
	
/* Political Participation and Efficacy ________________________________________*/

	recode ppart_disagreement1 (1 = 1 "Voting works")(2 = 0 "Voting fails"), gen(enviro_efficacy)
		lab var enviro_efficacy "Voting works"
	recode ppart_disagreement2 (1 = 1 "Meetings work")(2 = 0 "Meetings fail"), gen(gbv_efficacy)
		lab var gbv_efficacy "Meetings work"
	
	rename ppart_absentee absenteeism_meet

	rename ppart_preserve1 enviro_meet 
		replace enviro_meet = ppart_preserve2 if enviro_meet == .
		
	rename ppart_violence1 gbv_meet 
		replace gbv_meet = ppart_violence2 if gbv_meet == .
	
	
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

		
/* Womens Political Participation ______________________________________________*/

	recode wpp_leaders_men (1 = 1 "Women just as good")(2 = 0 "Women not as good"), gen(wpp_attitude2_dum)
	rename wpp_behavior wpp_behavior 
	
		**drop wpp_attitude 
		drop wpp_norm 
		
	
/* Radio Ownership _____________________________________________________________*/

	* Treatments
	gen t_radioinfo = .
		replace t_radioinfo = 0 if treatment_code1 == "control"
		replace t_radioinfo = 3 if treatment_code1 == "treatment 3"
		replace t_radioinfo = 1 if treatment_code1 == "treatment 1"
		replace t_radioinfo = 2 if treatment_code1 == "treatment 2"
		
		lab def t_radioinfo 0 "control" 3 "both priv." 1 "rfa-ccm/tk-priv" 2 "tk-ccm/rfa-priv"
		lab val t_radioinfo t_radioinfo 
		lab var t_radioinfo "Treatment: Radio Info"
		
	gen t_radiomsg = .
		replace t_radiomsg = 0 if treatment_rand2_code == "control"
		replace t_radiomsg = 1 if treatment_rand2_code == "treatment"
		
		lab def t_radiomsg 0 "control" 1 "treat"
		lab val t_radiomsg t_radiomsg 
		lab var t_radiomsg "Treatment: Receive TK Message"

	rename radiown_ccm radio_ccmbias_any
	rename radiown_description radio_manipcheck
	
	rename radiown_emphas_ccm radio_ccmbias
		
	rename radiown_interest_listen radio_choice
	
	recode radiown_tk_agree (1 = 1 "Clear")(2 = 0 "Not clear"), gen(radio_tkclear)
	recode radiown_tk_ccm (1 = 1 "Unbiased")(2 = 0 "CCM Bias"), gen(radio_tkbias)
	recode radiown_ccm_perfomance (1 = 4 "Very good")(2 = 3 "OK")(3 = 2 "Not good")(4 = 1 "Bad"), gen(radio_ccmgood)
	
	
/* i ing ___________________________________________________________________*/

	rename parenting_q1 parent_talkptix
	rename parenting_q6 wpp_talkdaughter
	recode parenting_helicopter (1 = 1 "helicopter")(2 = 0 "no helicopter"), gen(parent_helicopter)
		lab var parent_helicopter "Helicopter parents"
	
	
/* Feeling Thermometer _________________________________________________________*/

	foreach var of varlist 	thermo_local_leader thermo_business thermo_boda ///
							thermo_ccm thermo_mamasamia thermo_samiahassan   {
						
						replace `var' = .d if `var' == -999
						replace `var' = .r if `var' == -888
						replace `var' = `var' * 5
						
						
						}

		gen thermo_allsamia = thermo_mamasamia 
		replace thermo_allsamia = thermo_samiahassan if thermo_allsamia == .
		
	rename thermo_samia_t t_thermo_samia
	

		
/* Durations ___________________________________________________________________*/

	*destring duration, gen(svy_duration)
	*replace svy_duration = svy_duration/60


/* GBV Indices _________________________________________________________________*/

	* GBV Index 
	egen gbv_risk_index = rowmean(gbv_risky_travel gbv_risky_boda gbv_suspect_gifts ///
									gbv_suspect_ride gbv_nopartyalone)
	
	egen gbv_risk_norm_index = rowmean(gbv_risky_travel_norm gbv_risky_boda_norm ///
									gbv_nopartyalone_norm)
		
	gen gbv_response_short = gbv_response/2
	gen gbv_punish_short = gbv_punish/6
	egen gbv_response_index = rowmean(gbv_response_short gbv_punish_short gbv_testify)
		
	gen gbv_response_norm_short = gbv_response_norm/2
	egen gbv_response_norm_index = rowmean(gbv_response_norm_short gbv_testify_norm)
	
	gen ptixpref1_rank_gbv_short = (ptixpref1_rank_gbv-1)/2 
	gen socpref2_rank_women_short = (socpref2_rank_women-1)/3
	
	egen gbv_prior_index = rowmean(gbv_elect ptixpref1_rank_gbv_short ///
									socpref2_rank_women_short)
	
	egen gbv_partner_prior_index = rowmean(ptixpref1_partner_gbv socpref2_partner_gbv)
	
	gen gbv_parent = parent_helicopter
	
	
/* Enviro Indices ______________________________________________________________*/

	gen enviro_ccknow_long_short = enviro_ccknow_long/2
	gen enviro_cause_intl_short = enviro_cause_intl/2
	gen enviro_cause_human_short = enviro_cause_human/2
	egen enviro_know_index = rowmean(enviro_ccknow_long_short enviro_cause_human enviro_cause_intl)
	
	egen enviro_attitudes_index = rowmean(enviro_attitudes enviro_voteenviro)
	
	gen enviro_punish_short = enviro_punish/6
	egen enviro_punish_index = rowmean(enviro_reportfires enviro_punish_short)
	
	gen ptixpref2_rank_enviro_short = (ptixpref2_rank_enviro-1)/2 
	gen socpref1_rank_enviro_short = (socpref1_rank_enviro-1)/3
	egen enviro_prior_index = rowmean(enviro_elect ptixpref2_rank_enviro_short ///
									socpref1_rank_enviro_short)
									
	egen enviro_partner_prior_index = rowmean(ptixpref2_partner_enviro socpref1_partner_enviro)
	
	gen socpref1_rank_bribes_short = socpref1_rank_bribes/4
	gen thermo_leader_short = thermo_local_leader/100
	egen corruption_index = rowmean(ppart_corruption socpref1_rank_bribes_short thermo_leader_short)

	
/* Save _________________________________________________________________________*/

	sort id_* *_id
	order id_ward_uid id_village_uid resp_id region_code region_name district_code district_name ward_code ward_name village_code village_name id_resp_c sub_village enum enum_name 
	
	drop id_re 

	save "${data}/02_mid_data/pfm_as2_midline_clean.dta", replace
											
				
				

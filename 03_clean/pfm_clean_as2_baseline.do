/*______________________________________________________________________________

	Project: Pangani FM 2
	File: Baseline Cleaning
	Date: 2023.10.28
	Author: Dylan Groves, dylanwgroves@gmail.com
_______________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	*version 15
	clear all
	set maxvar 30000
	set more off

	
/* Load Data _________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_nopii_as2_baseline.dta", clear
	gen as2_baseline = 1
	
/* Remove Labels _______________________________________________________________*/

	cap drop *_label

/* Clean IDs ___________________________________________________________________*/

	replace resp_id = "2_101_5_001" if resp_id == "2_101_5_01"
	replace resp_id = "2_101_5_004" if resp_id == "2_101_5_04"
	
	replace ward_code = "91" if resp_id == "2_91_7_062"
	replace ward_code = "91" if resp_id == "2_91_7_065"
	
	
/* Village Information _________________________________________________________*/

		gen id_resp_c = id
			lab var id_resp_c "Respondent Code"
		
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
			
/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

/* Respondent Information ______________________________________________________*/

	rename resp_wear_ppe resp_ppe
	rename resp_describe_day resp_howudoin
	
	rename resp_job_sm_1   resp_job_fisher
	rename resp_job_sm_2   resp_job_fishmonger
	rename resp_job_sm_3   resp_job_boatbuilder
	rename resp_job_sm_4   resp_job_farm
	rename resp_job_sm_5   resp_job_livestock
	rename resp_job_sm_6   resp_job_farmoth
	rename resp_job_sm_7   resp_job_livestockoth
	rename resp_job_sm_8   resp_job_construction
	rename resp_job_sm_9   resp_job_house
	rename resp_job_sm_10  resp_job_boda 
	rename resp_job_sm_11  resp_job_smallbiz
	rename resp_job_sm_12  resp_job_smallbizoth
	rename resp_job_sm_13  resp_job_casual
	rename resp_job_sm_14  resp_job_salaryag
	rename resp_job_sm_15  resp_job_salary 
	rename resp_job_sm_16  resp_job_pension
	rename resp_job_sm_17  resp_job_teacher
	rename resp_job_sm_18  resp_job_doctor
	rename resp_job_sm_19  resp_job_gov 
	rename resp_job_sm_oth resp_job_oth 
	
	gen resp_muslim = (resp_religion == 3)
	gen resp_christian = (resp_religion == 2)
	
	rename resp_relationship_hhh resp_hhh_rltn
	rename resp_marital_status resp_rltn_statu
	rename resp_marital_status_oth resp_marital_status_oth
	rename resp_current_partner_age resp_partner_age
	rename resp_people_in_hh resp_hh_nbr
	rename resp_children_0_17 resp_hh_kids
	rename resp_children_ever_had resp_kidsborn
	rename resp_knowvill resp_pplknow
	rename resp_fromvill resp_vill16
	rename resp_visitcity resp_visittown
	rename resp_education resp_edu 
	rename resp_education_oth resp_edu_oth 
	rename resp_read_write resp_literate										// this is not in the baseline survey!
	rename resp_language_prim resp_language
	rename resp_language_prim_oth resp_language_oth 
	rename resp_language_sec resp_2ndlanguage
	rename resp_language_sec_oth resp_2ndlanguage_oth 
	rename resp_tz_tribe resp_natid 
	rename resp_koranic_school resp_religious_muslimschool
	rename resp_christian_school resp_religious_christianschool
	rename resp_attend_religious resp_religiosity
	
	
	recode resp_howudoin (1 = 1)(2 = 2)(3 = 0)
	lab def resp_doin 0 "Bad" 1 "Typical" 2 "Good"
	lab val resp_howudoin resp_doin 
	
	gen resp_religiousschool = resp_religious_muslimschool
		replace resp_religiousschool = resp_religious_christianschool if resp_religiousschool == .
		

	gen resp_tribe_sambaa = (resp_tribe == 32)
	gen resp_tribe_wazigua = (resp_tribe == 35)
	gen resp_tribe_wadigo = (resp_tribe == 38)
	gen resp_tribe_other = 1 if resp_tribe != 32 & resp_tribe != 35 & resp_tribe != 38
		replace resp_tribe_other = 0 if resp_tribe_other == .
		
	gen resp_couple = 1 if 	resp_rltn_statu == 1 | resp_rltn_statu == 2 | resp_rltn_statu == 3
		replace resp_couple = 0 if resp_couple == .

	gen resp_swahili = (resp_language == 1)

	gen resp_morelanguages = 1 if resp_swahili == 0 
		replace resp_morelanguages = 1 if resp_swahili == 1 & (resp_2ndlanguage != 9 | resp_2ndlanguage != 1) 
		replace resp_morelanguages = 0 if resp_swahili == 1 & resp_2ndlanguage == 9

	gen resp_hhh = (resp_hhh_rltn == 1)
		lab var resp_hhh "Respondent head of household"
		lab val resp_hhh yesno
		
	gen resp_standard7 = (resp_edu > 7)

	gen resp_visittown_yr = (resp_visittown > 2)
		lab var resp_visittown_yr "Visit town more than once per year"

	
	foreach var of varlist resp_* {
		cap recode `var' (-999 = .d)(-888 = .r)(-222 = .o)
	}

	
/* Environmental Attitudes _____________________________________________________*/

	* env_betterworse
	
	recode env_betterworse (2 = 1 "Worse")(1 3 = 0 "Not worse"), gen(enviro_worse)
		lab var enviro_worse "Environment getting worse?"
	
	gen env_problems = ""
		replace env_problems = env_problems_worse 
		replace env_problems = env_problems_notworse if env_problems_worse == ""
		
	foreach n of numlist 1/14 {
	
		gen env_problems_`n' = .
			replace env_problems_`n' = env_problems_worse_`n'
			replace env_problems_`n' = env_problems_notworse_`n' if env_problems_`n' == .
	
	}
	
	rename env_problems_1 env_probs_drought 
	rename env_problems_2 env_probs_rainfall 
	rename env_problems_3 env_probs_heat 
	rename env_problems_4 env_probs_rainpredict
	rename env_problems_5 env_probs_cropsland
	rename env_problems_6 env_probs_forest 
	rename env_problems_7 env_probs_water 
	rename env_problems_8 env_probs_forest2
	rename env_problems_9 env_probs_water2 
	rename env_problems_10 env_probs_rangeland 
	cap rename env_problems_11 env_probs_coasterode
	rename env_problems_12 env_probs_saltwater
	rename env_problems_13 env_probs_mangrove
	rename env_problems_14 env_probs_fish 
	cap rename env_problems__999 env_probs_dk 
	cap rename env_problems__222 env_probs_oth 
	
	drop env_problems_notworse*
	drop env_problems_worse*
	
	* gen env_cause_
	
	rename env_cause_second_1 env_cause_second_nature
	rename env_cause_second_2 env_cause_second_god
	rename env_cause_second_3 env_cause_second_othersuper
	rename env_cause_second_4 env_cause_second_vill
	rename env_cause_second_5 env_cause_second_othvill
	rename env_cause_second_6 env_cause_second_othtz
	rename env_cause_second_7 env_cause_second_othcountry
	rename env_cause_second_8 env_cause_second_gov
	rename env_cause_second_9 env_cause_second_none
	rename env_cause_second_10 env_cause_second_refuse
	cap rename env_cause_seccon_999 env_cause_second_dk
	
	
	gen enviro_cause_human = 	(env_cause == 4 | env_cause == 5 | env_cause == 6 | ///
								env_cause == 7 | env_cause == 8)
								
		replace enviro_cause_human = 2 if enviro_cause_human == 1
								
		replace enviro_cause_human = 1 if 	env_cause_second_vill == 1 | ///
											env_cause_second_othvill == 1 | ///
											env_cause_second_othtz == 1 | ///
											env_cause_second_othcountry == 1 | ///
											env_cause_second_gov == 1
		
		lab var enviro_cause_human "Humans cause of enviro problems?"
											
	gen enviro_cause_outside = (env_cause == 5 | env_cause == 6 | env_cause == 7 | env_cause ==  8)
		
		replace enviro_cause_outside = 2 if enviro_cause_outside == 1
		
		replace enviro_cause_outside = 1 if 	env_cause_second_othvill == 1 | ///
												env_cause_second_othtz == 1 | ///
												env_cause_second_othcountry == 1 | ///
												env_cause_second_gov == 1
												
		lab var enviro_cause_human "Outsiders cause of enviro problems"
	

	
/* Courts ______________________________________________________________________*/

	rename courts_police court_police
	rename courts_court court_court
	gen court_court_ever = courts_court_ever
		replace court_court_ever = 1 if court_court == 1
	
	* Faith
	rename courtnorm_wealth_txt t_courtfaith_wealth
	rename courtnorm_gender_txt t_courtfaith_gender
	
	lab def courtsfaith 1 "Go free" 2 "Get Punished"
	lab val courts_faith courtsfaith
	
	** Land
	rename c_town_txt t_courts_town
	rename c_cuzgender_txt t_courts_cuzgender 
	rename c_othgender_txt t_courts_othgender 
	rename c_othwealth_txt t_courts_othwealth
	rename c_gov_txt t_courts_gov 
		replace t_courts_gov = "court" if t_courts_gov == "local court"
		replace t_courts_gov = "chairperson" if t_courts_gov == "villageleader"
	rename c_alt_txt t_courts_alt 
	rename c_courtfirst_t t_courts_courtfirst
	
	replace court_land_1 = 1 if court_land_2 == 2
	replace court_land_1 = 2 if court_land_2 == 1
	recode court_land_1 (1 = 1 "State")(2 = 0 "Non-State"), gen(court_land)	
	
	gen t_courts_gender = ""
		replace t_courts_gender = "Fem-Fem" if t_courts_cuzgender  == "female" & t_courts_othgender  == "female"
		replace t_courts_gender = "Fem-Male" if t_courts_cuzgender  == "female" & t_courts_othgender  == "male"
		replace t_courts_gender = "Male-Fem" if t_courts_cuzgender  == "male" & t_courts_othgender  == "female"
		replace t_courts_gender = "Male-Male" if t_courts_cuzgender  == "male" & t_courts_othgender  == "male"	
	
	** Divorce
	rename c2_town_txt t_courts2_town
	rename c2_cuzgender_txt t_courts2_cuzgender 
	rename c2_othwealth_txt t_courts2_othwealth
	rename c2_gov_txt t_courts2_gov 
		replace t_courts_gov = "court" if t_courts2_gov == "local court"
		replace t_courts_gov = "chairperson" if t_courts2_gov == "villageleader"
	rename c2_alt_txt t_courts2_alt 
	rename c2_courtfirst_t t_courts2_courtfirst
	
	replace court_divorce_1 = 1 if court_divorce_2 == 2
	replace court_divorce_1 = 2 if court_divorce_2 == 1
	recode court_divorce_1 (1 = 1 "State")(2 = 0 "Non-State"), gen(court_divorce)	

	* Should we have a measure that summarizes what we find in these two? Like "prefers formal resolution / no " or something?
	
		
replace court_court = 2 if court_court == 1
	replace court_court = 1 if court_court_ever == 1 & court_court == 0 
	
	lab def court_crt 0 "Never" 1 "Ever" 2 "In last year"
	lab val court_court court_crt

	
/* Gender ______________________________________________________________________*/

	recode gender_fm (2=1 "Reject FM")(1=0 "Accept FM"), gen(ge_fm_reject)
		lab var ge_fm_reject "Reject forced marriage"
	recode gender_earning (2=1 "Equal earning ok")(1=0 "Equal earning bad"), gen(ge_earning)
		lab var ge_earning "Equality earning"
	recode gender_jobs (2=1 "Jobs for men")(1=0 "Jobs for both"), gen(ge_jobs)
		lab var ge_jobs "Equality jobs"
	recode gender_leader (2=0 "Women cant lead")(1=1 "Women equal"), gen(ge_lead)
		lab var ge_lead "Equality Leader"

	recode ipv_attitudes (1=0 "Accept IPV")(0=1 "Reject IPV"), gen(ipv_reject)
	gen ipv_reject_long = 0 if ipv_hithard == 2
		replace ipv_reject_long = 1 if ipv_hithard == 1 & ipv_reject == 0
		replace ipv_reject_long = 2 if ipv_reject == 1 & ipv_persist == 1
		replace ipv_reject_long = 3 if ipv_reject == 1 & ipv_persist == 0
		
	recode em_religion (1 3 = 0 "Sometimes or always accept")(2 = 1 "Always reject"), gen(em_reject_relig_dum)
	recode em_pregnancy (1 3 = 0 "Sometimes or always accept")(2 = 1 "Always reject"), gen(em_reject_preg_dum)
	
	
/* GBV _________________________________________________________________________*/

		rename gbv_norm_rand_txt t_gbv_gender 
		
		foreach var of varlist gbv_friend_m_* gbv_safe_* gbv_resp_* {
				recode `var' (-999 = .d)(-888 = .r)
		}

		* Generate same as midline and endline: higher is risky.
			recode gbv_safe_boda 		(1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_boda)
			recode gbv_safe_alone 		(1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_travel)
			recode gbv_safe_boda_norm 	(1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_boda_norm)
			recode gbv_safe_alone_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_risky_travel_norm)
	
		

/* Environmental Attitudes _____________________________________________________*/

	recode envatt_general (1 = 1 "Enviro > Dev Proj")(2 = 0 "Dev Proj > Enviro"), gen(envatt_enviro_general)
	recode envatt_general_jobs (1 = 1 "Enviro > Dev Proj")(2 = 0 "Dev Proj > Enviro"), gen(envatt_enviro_jobs)
	gen enviro_attitude = envatt_enviro_general 
		replace enviro_attitude = envatt_enviro_jobs if envatt_enviro_general == .
		lab val enviro_attitude envatt_enviro_general
		
	gen t_envatt_jobs = (envatt_enviro_jobs != .)
	
	recode envatt_firewood (1 = 0 "Cut without permit")(2 = 1 "Get a permit"), gen(enviro_firewood)
	recode envatt_firewood_norm (1 = 0 "Cut without permit")(2 = 1 "Get a permit"), gen(enviro_firewood_norm)


/* Political Preferences _______________________________________________________*/

	rename ppref_partner ptixpref_partner
		replace ptixpref_partner = ppref_partner2 if ptixpref_partner == .

	rename ppref_partner_treat t_ptixpref_partner
		
	gen ptixpref_rank_1st = .
	
forval i = 1/7 {
	gen ptixpref_rank_`i' = .
	replace ptixpref_rank_`i' = 7 if polit_pref_card1 == `i'
	replace ptixpref_rank_`i' = 6 if polit_pref_card2 == `i'
	replace ptixpref_rank_`i' = 5 if polit_pref_card3 == `i'
	replace ptixpref_rank_`i' = 4 if polit_pref_card4 == `i'
	replace ptixpref_rank_`i' = 3 if polit_pref_card5 == `i'
	replace ptixpref_rank_`i' = 2 if polit_pref_card6 == `i'
	replace ptixpref_rank_`i' = 1 if polit_pref_card7 == `i'

}
	
	rename ptixpref_rank_1		ptixpref_rank_girls
	rename ptixpref_rank_2 		ptixpref_rank_edu
	rename ptixpref_rank_3		ptixpref_rank_power
	rename ptixpref_rank_4		ptixpref_rank_water
	rename ptixpref_rank_5		ptixpref_rank_roads
	rename ptixpref_rank_6		ptixpref_rank_health
	rename ptixpref_rank_7		ptixpref_rank_enviro
	
	
	* Partner influence
	
	
	tab ppref_oth_issues
	
	
/* Political Knowledge _________________________________________________________*/

	gen ptixknow_mp_correct = (district_code == "2" & ptixknow_mp == 4)
	
	gen ptixknow_pm_correct = (ptixknow_pm == 2)
	
	gen ptixknow_laws_correct = (ptixknow_laws == 1)
	
	gen ptixknow_biden_correct = (ptixknow_biden > 0)
	
	egen ptixknow_index = rowtotal(ptixknow_mp_correct ptixknow_pm_correct ptixknow_laws_correct ptixknow_biden_correct)
	
	
/* Political Participation _____________________________________________________*/

	recode ppart_* (-888 = .r)(-999 = .d)

	egen ppart_index = rowtotal(ppart_meeting ppart_vote ppart_contact ppart_collact)


/* Women's Political Participation _____________________________________________*/

	rename wpp_txt_treat t_wpp
	
	recode wpp_attitude (1 2 = 1 "Equal women or more women")(0 = 0 "More men"), gen(wpp_attitude_dum)
	recode wpp_norm (1 2 = 1 "Equal women or more women")(0 = 0 "More men"), gen(wpp_norm_dum)
	
	replace wpp_msg_support = 0 if wpp_msg == 0 
	replace wpp_msg_share = 0 if wpp_msg == 0 
	replace wpp_msg_name = 0 if wpp_msg == 0 
	

/* Feeling Thermometer _________________________________________________________*/

	foreach var of varlist 	thermo_dar thermo_china thermo_lga thermo_kenya thermo_doctors ///
						thermo_bartenders thermo_boda thermo_christians thermo_muslims ///
						thermo_ccm thermo_mamasamia thermo_samiahassan  {
						
						replace `var' = .d if `var' == -999
						replace `var' = .r if `var' == -888
						replace `var' = `var' * 5
						
						
						}
	
	gen thermo_allsamia = thermo_mamasamia 
		replace thermo_allsamia = thermo_samiahassan if thermo_allsamia == .
		
	rename thermo_samia_t t_thermo_samia
	


/* Media _______________________________________________________________________*/

	rename media_listen_news media_news
		recode media_news (-999 = .d)(-888 = .r)
		
	rename media_listen_radio radio_2wk
	
	rename media_radio_3month	radio_ever
		replace radio_ever = 1 if radio_2wk > 0 

	rename media_programs_sm_1		radio_pgm_music
	rename media_programs_sm_2		radio_pgm_gospel
	rename media_programs_sm_3		radio_pgm_sport
	rename media_programs_sm_4		radio_pgm_news
	rename media_programs_sm_5		radio_pgm_romance
	rename media_programs_sm_6		radio_pgm_social
	rename media_programs_sm_7		radio_pgm_relig		
	
	foreach var of varlist radio_pgm_* {
		
		replace `var' = 0 if `var' == .
	}

	rename media_listen_sm_1		radio_stn_voa
	rename media_listen_sm_2		radio_stn_tbc
	rename media_listen_sm_3		radio_stn_taifa
	rename media_listen_sm_4		radio_stn_efm
	rename media_listen_sm_5		radio_stn_breeze
	rename media_listen_sm_6		radio_stn_clouds
	rename media_listen_sm_7		radio_stn_maria
	rename media_listen_sm_8		radio_stn_rone
	rename media_listen_sm_9		radio_stn_huruma
	rename media_listen_sm_10		radio_stn_mwambao
	rename media_listen_sm_11		radio_stn_wasafi
	rename media_listen_sm_12		radio_stn_nuru
	rename media_listen_sm_13		radio_stn_uhuru
	rename media_listen_sm_14		radio_stn_bbc
	rename media_listen_sm_15		radio_stn_sautiamerika
	rename media_listen_sm_16		radio_stn_tk
	rename media_listen_sm_17		radio_stn_panganifm
	rename media_listen_sm_18		radio_stn_ihsaan
	rename media_listen_sm_19		radio_stn_nuur
	rename media_listen_sm_20		radio_stn_rfa
	rename media_listen_sm_21		radio_stn_ear
	rename media_listen_sm_22		radio_stn_relig
	rename media_listen_sm_23		radio_stn_kenya

	rename media_listen_sm_oth radio_stn_oth 
	
	rename media_radio_free radio_RFA

	rename media_fav_radio_1		radio_news_voa
	rename media_fav_radio_2		radio_news_tbc
	rename media_fav_radio_3		radio_news_taifa
	rename media_fav_radio_4		radio_news_efm
	rename media_fav_radio_5		radio_news_breeze
	rename media_fav_radio_6		radio_news_clouds
	rename media_fav_radio_7		radio_news_maria
	rename media_fav_radio_8		radio_news_rone
	rename media_fav_radio_9		radio_news_huruma
	rename media_fav_radio_10		radio_news_mwambao
	rename media_fav_radio_11		radio_news_wasafi
	rename media_fav_radio_12		radio_news_nuru
	rename media_fav_radio_13		radio_news_uhuru
	rename media_fav_radio_14		radio_news_bbc
	rename media_fav_radio_15		radio_news_sautiamerika
	rename media_fav_radio_16		radio_news_tk
	rename media_fav_radio_17		radio_news_panganifm
	rename media_fav_radio_18		radio_news_ihsaan
	rename media_fav_radio_19		radio_news_nuur
	rename media_fav_radio_20		radio_news_rfa
	rename media_fav_radio_21		radio_news_ear
	rename media_fav_radio_22		radio_news_relig
	rename media_fav_radio_23		radio_news_kenya

	rename media_fav_sport_1		radio_sport_voa
	rename media_fav_sport_2		radio_sport_tbc
	rename media_fav_sport_3		radio_sport_taifa
	rename media_fav_sport_4		radio_sport_efm
	rename media_fav_sport_5		radio_sport_breeze
	rename media_fav_sport_6		radio_sport_clouds
	rename media_fav_sport_7		radio_sport_maria
	rename media_fav_sport_8		radio_sport_rone
	rename media_fav_sport_9		radio_sport_huruma
	rename media_fav_sport_10		radio_sport_mwambao
	rename media_fav_sport_11		radio_sport_wasafi
	rename media_fav_sport_12		radio_sport_nuru
	rename media_fav_sport_13		radio_sport_uhuru
	rename media_fav_sport_14		radio_sport_bbc
	rename media_fav_sport_15		radio_sport_sautiamerika
	rename media_fav_sport_16		radio_sport_tk
	rename media_fav_sport_17		radio_sport_panganifm
	rename media_fav_sport_18		radio_sport_ihsaan
	rename media_fav_sport_19		radio_sport_nuur
	rename media_fav_sport_20		radio_sport_rfa
	rename media_fav_sport_21		radio_sport_ear
	rename media_fav_sport_22		radio_sport_relig
	rename media_fav_sport_23		radio_sport_kenya
	
	rename media_fav_music_1		radio_music_voa
	rename media_fav_music_2		radio_music_tbc
	rename media_fav_music_3		radio_music_taifa
	rename media_fav_music_4		radio_music_efm
	rename media_fav_music_5		radio_music_breeze
	rename media_fav_music_6		radio_music_clouds
	rename media_fav_music_7		radio_music_maria
	rename media_fav_music_8		radio_music_rone
	rename media_fav_music_9		radio_music_huruma
	rename media_fav_music_10		radio_music_mwambao
	rename media_fav_music_11		radio_music_wasafi
	rename media_fav_music_12		radio_music_nuru
	rename media_fav_music_13		radio_music_uhuru
	rename media_fav_music_14		radio_music_bbc
	rename media_fav_music_15		radio_music_sautiamerika
	rename media_fav_music_16		radio_music_tk
	rename media_fav_music_17		radio_music_panganifm
	rename media_fav_music_18		radio_music_ihsaan
	rename media_fav_music_19		radio_music_nuur
	rename media_fav_music_20		radio_music_rfa
	rename media_fav_music_21		radio_music_ear
	rename media_fav_music_22		radio_music_relig
	rename media_fav_music_23		radio_music_kenya

/* Radio Ownership _____________________________________________________________

	tab media_radio_owner_r
	rename radio_rand1_txt	
	tab radio_rand2_txt
		
	tab media_radio_owner_r_1 
	tab media_radio_owner_r_label_1
	*/
	
	gen radio_knowowner_rfa = . 
	gen radio_knowowner_rone = .
	gen radio_knowowner_tbc = .
	gen radio_knowowner_tk = .
	gen radio_knowowner_uhuru = .
	gen radio_knowowner_wasafi = .
	
	forvalues x = 1/4 {

		replace radio_knowowner_rfa = media_radio_owner_r_`x' if radio_name_r_`x' == "Radio Free Africa"
		replace radio_knowowner_rone = media_radio_owner_r_`x' if radio_name_r_`x' == "Radio One"
		replace radio_knowowner_tbc = media_radio_owner_r_`x' if radio_name_r_`x' == "TBC"
		replace radio_knowowner_tk = media_radio_owner_r_`x' if radio_name_r_`x' == "Tanga Kunani"
		replace radio_knowowner_uhuru = media_radio_owner_r_`x' if radio_name_r_`x' == "Uhuru FM"
		replace radio_knowowner_wasafi = media_radio_owner_r_`x' if radio_name_r_`x' == "Wasafi"
	
	}
	
	foreach var of varlist radio_knowowner_* {
	
		lab val `var' media_radio_owner_r_1
	
	}
	
	lab def media_option1_2_real 1 "Gov" 2 "Opp" 3 "Ind."
	lab val media_option1_2 media_option1_2_real
	
	lab def media_statement2_agree_real 1 "Biased" 2 "Objective"
	lab val media_statement2_agree media_statement2_agree_real
	
	lab def media_statement1_agree_real 1 "Agency" 2 "No Agency"
	lab val media_statement1_agree media_statement1_agree_real
	
	
/* Assets ______________________________________________________________________*/

	rename media_as_radios assets_radios
	rename media_as_radio_own assets_radios_num
		replace assets_radios_num = 0 if assets_radios_num == .
	rename media_as_tv assets_tv 
	rename media_as_cell_phone assets_cell 
	rename media_as_connect	assets_connect 
	rename concl_roof assets_roof
	
	gen assets_roof_metal = (assets_roof == 1)
		lab var assets_roof_metal ""

	
/* Conclusion __________________________________________________________________*/

	rename concl_follow_up	svy_followup
	rename concl_oth_person	svy_otherpresent
	rename concl_relation_resp_sm svy_otherpresent_who 
	
	
/* Durations ___________________________________________________________________*/

	destring duration, gen(svy_duration)
	replace svy_duration = svy_duration/60
	
	destring duration, replace
	
	
/* A little cleaning ___________________________________________________________*/

	replace id_village_uid = "8_81_4" if id_village_uid == "8_81_-222"
	
/* Save _________________________________________________________________________*/

	sort id_* *_id
	order id_ward_uid id_village_uid resp_id region_code  district_code  ward_code  village_code  id_resp_c  enum  
	
	drop id id_re 

/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)
	
	save "${data}/02_mid_data/pfm_as2_baseline_clean.dta", replace
											
				
				

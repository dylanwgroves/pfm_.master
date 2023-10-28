
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survey 1 (2020)
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

	use "${data}/01_raw_data/03_surveys/pfm_nopii_cm_1_2020.dta", clear

	gen cm_1_2020 = 1
	
/* Labels _______________________________________________________________________*/

cap lab def yesno 0 "No" 1 "Yes"
cap lab def agree 0 "Disagree" 1 "Agree"
cap lab def reject 0 "Accept" 1 "Reject"
cap lab def report 0 "Dont report" 1 "Report"
cap lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
cap lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
cap lab def correct	0 "Incorrect" 1 "Correct"
cap lab def yesnolisten 0 "Don't Listen" 1 "Listen"

drop if date == "date2020-11-03"

/* Survey Info _________________________________________________________________*/

drop 	simid devicephonenum us caseid enum_name resp_id idstring

destring duration, gen(svy_duration)
	replace svy_duration = svy_duration / 60
rename enum svy_enum

rename s1q2_district 	svy_district_c
rename s1q3_ward		svy_ward_c
rename s1q4_village		svy_vill_c


egen village_uid			= concat(svy_district_c svy_ward_c svy_vill_c), punct(_)
gen svy_vill_n = "Jaira" if village_id == "5_41_3"
	replace svy_vill_n = "Boza" if village_id == "5_51_1"
	replace svy_vill_n = village_name if svy_vill_n == ""
	replace svy_vill_n = s1q4_village_oth if s1q4_village_oth != ""
	
gen svy_subvill_n = s1q5_sub_vill

rename id				svy_resp_c
egen resp_id			= concat(svy_vill_c svy_resp_c), punct(_)

/* Consent _____________________________________________________________________*/

rename consent consent															// HFC: Consent Check
gen to_exclude = 1 if consent != 1
drop if to_exclude == 1
*drop audio_record																// BM_ note: not asked anymore.

/* Respondent Info ______________________________________________________________*/

rename s2q1_ppe resp_ppe

gen resp_female = .
	replace resp_female = 1 if s1q2_gender == 2
	replace resp_female = 0 if s1q2_gender == 1
	lab val resp_female yesno 
	
gen resp_age = s3q1_age
gen resp_age_yr = 2020 - resp_age

rename s3q2 resp_hhhrltn
	replace resp_hhhrltn = 1 if s3q2_oth == "Yeye mwenyewe"
	
rename s3q3_status 	resp_rltn_status
rename s3q4 		resp_rltn_age
	recode resp_rltn_age (-999 = .d)
gen resp_rltn_age_yr = 2020 - resp_rltn_age 

gen resp_married = (resp_rltn_status ==  1)

gen resp_married_yr = year(s3q5)
	recode resp_married_yr (-999 = .d)

gen resp_married_age = resp_married_yr - resp_age_yr
gen resp_rltn_married_age = resp_married_yr - resp_rltn_age_yr

rename s3q6			resp_profession

rename s3q7_hhh_nbr			resp_hh_size

rename s3q8_hhh_children 	resp_hh_kids

rename s3q11child_had 		resp_kids

gen resp_kids_any = (resp_kids > 0)

rename s3q13_nbr_people 	resp_villknow

rename s3q15_city_town		resp_urbanvisit

rename s3q14_vill_16		resp_livevill16

rename s3q16_school_grade	resp_education

gen resp_education_standard7 = 1 if resp_education >= 8
	replace resp_education_standard7 = 0 if resp_education < 8
	lab var resp_education_standard7 "Standard 7 or higher?"
	lab val resp_education_standard7 yesno

rename s3q17_write_read		resp_literate											
	replace resp_literate = 2 if resp_education >=8

rename s3q19_language		resp_language_main

rename s3q19_language_oth	resp_language_oth
gen resp_swahili = 			(resp_language_main == 1)
	replace resp_swahili = 1 if resp_language_oth == "1"
	lab var resp_swahili "Respondent speaks swahili"
	lab def swahili 0 "No Swahili" 1 "Swahili"
	lab val resp_swahili swahili
	
rename s3q21_tribe			resp_tribe											// Need to input "other"

gen resp_tribe_wazigua = (resp_tribe == 35)	

rename s3q20_tz_tribe		resp_tzortribe

rename s3q21_religion		resp_religion
gen resp_muslim = 			(resp_religion == 3 | ///
							resp_religion == 13 | ///
							resp_religion == 14 | ///
							resp_religion == 15)	
lab var resp_muslim "Respondent Muslim"
lab val resp_muslim yesno
							
gen resp_christian = 0
	replace resp_christian = 1 if 	resp_muslim != 1 ///
									& resp_religion != 16 ///
									& resp_religion != 17 ///
									& resp_religion != 18 ///
									& resp_religion != 19 ///
									& resp_religion != 20 ///
									& resp_religion != -999
lab var resp_muslim "Respondent Muslim"
lab val resp_muslim yesno
									
rename s3q22_religious		resp_religiosity

foreach var of varlist resp_* {
	cap recode `var' (-999 = .d)(-888 = .r)(-222 = .o)
} 

foreach var of varlist resp_* {
	tab `var'
} 


/* Marriage Age ________________________________________________________________

This is a kinda complicated one where we will probably just make our own dataset

*/

rename s7q1			marriages_fhh_name
rename s7q3			marriages_fhh_numkid
rename s7q1b		marriages_fhh_age

forval i = 1/11 {

	cap rename child_full_name_`i' 	marriages_name`i' 
	cap rename s7q6_r_`i' 			marriages_age`i'
	cap gen marriages_born_yr`i'	= 2020 - marriages_age`i'
	cap rename s7q7a_r_`i'			marriages_dead`i'
	cap rename s7q7_r_`i'			marriages_female`i'
		cap recode marriages_female`i' (2=1)(1=0)
	cap rename s7q9_r_`i'			marriages_education`i'
	cap rename s7q10_r_`i'			marriages_married`i'
	cap gen marriages_married_yr`i' = year(s7q11_r_`i')
	cap gen marriages_married_age`i' = 		marriages_married_yr`i' - marriages_born_yr`i'
}		


/* General Values ______________________________________________________________*/

rename s5q3						values_individualism
recode values_individualism (2=1)(1=0)
lab def individualism 1 "People are responsible for themselves" 0 "Government is responsible for people"
lab val values_individualism individualism

rename s5q4 					values_conformity
lab def conformity 1 "Pay attention to others" 0 "Do what one things what is right"
lab val values_conformity conformity

** People you would live near
forval i = 1/8 {
	gen values_noneighbor_`i' = .
		forval j = 1/3 {	
			replace values_noneighbor_`i' = s5q5_r_`j' if ranked_choice_list_r_`j' == "`i'"
		}
	lab var values_noneighbor_`i' "Would not want X group to be your neighbor"
	lab val values_noneighbor_`i' yesno
}
	rename values_noneighbor_1 		values_noneighbor_singlemom					// Not sure this is coded right
	rename values_noneighbor_2		values_noneighbor_otherreligion
	rename values_noneighbor_3		values_noneighbor_aids
	rename values_noneighbor_4		values_noneighbor_homo
	rename values_noneighbor_5		values_noneighbor_drink
	rename values_noneighbor_6		values_noneighbor_unmarried
	rename values_noneighbor_7		values_noneighbor_girlefm
	rename values_noneighbor_8		values_noneighbor_parentsefm

foreach var of varlist values_* {
	recode `var' (-999 = .d)
}	


/* Political Prefences _________________________________________________________

rename s14q2a ptixpref_rank_ag
rename s14q2b ptixpref_rank_crime
rename s14q2c ptixpref_rank_efm
rename s14q2d ptixpref_rank_edu
rename s14q2e ptixpref_rank_justice
rename s14q2f ptixpref_rank_electric
rename s14q2g ptixpref_rank_sanit
rename s14q2h ptixpref_rank_roads
rename s14q2i ptixpref_rank_health

*/

  


forval i = 1/9 {
		gen ptixpref_rank_`i' = .
		lab val ptixpref_rank_`i'
		replace ptixpref_rank_`i' = 9 if s14q2a == `i'
		replace ptixpref_rank_`i' = 8 if s14q2b == `i'
		replace ptixpref_rank_`i' = 7 if s14q2c == `i'
		replace ptixpref_rank_`i' = 6 if s14q2d == `i'
		replace ptixpref_rank_`i' = 5 if s14q2e == `i'
		replace ptixpref_rank_`i' = 4 if s14q2f == `i'
		replace ptixpref_rank_`i' = 3 if s14q2g == `i'
		replace ptixpref_rank_`i' = 2 if s14q2h == `i'
		replace ptixpref_rank_`i' = 1 if s14q2i == `i'
	}

		rename ptixpref_rank_1		ptixpref_rank_ag
		rename ptixpref_rank_2 		ptixpref_rank_crime
		rename ptixpref_rank_3		ptixpref_rank_efm
		rename ptixpref_rank_4		ptixpref_rank_edu
		rename ptixpref_rank_5		ptixpref_rank_justice
		rename ptixpref_rank_6		ptixpref_rank_electric
		rename ptixpref_rank_7		ptixpref_rank_sanit
		rename ptixpref_rank_8		ptixpref_rank_roads
		rename ptixpref_rank_9		ptixpref_rank_health


rename s14q3  ptixpref_local_approve
	recode ptixpref_local_approve (2 = 0)
	lab def gov_approval 0 "Do not approve" 1 "Approve"
	lab val ptixpref_local_approve gov_approval
	
	
/* Gender Equality _____________________________________________________________

NOTE: unfortunately surveycto coded this where disagree is highest (5) and 
agree is lowest (1). some survey questions were also coded in reverse order, so
have to pay special attention. 

We are coding that higher is always "more gender equality"

*/

forval i = 1/10 {
	gen ge_`i' = .
		forval j = 1/6 {
			replace ge_`i' = s6q_r_`j' if s6_qn_sel_r_`j' == "`i'"
		}
}

	rename ge_1			ge_raisekids
		recode ge_raisekids (1=1)(2=0)
		lab val ge_raisekids agree
	rename ge_2			ge_earning
		recode ge_earning (1=0)(2=1) 
		lab val ge_earning agree								
	rename ge_3			ge_school					
		recode ge_school (1=0)(2=1) 
		lab val ge_school agree								
	rename ge_4 		ge_work													// Reversed
		recode ge_work (1=0)(2=1)
		lab val ge_work agree								
	rename ge_5			ge_leadership
		recode ge_leadership (1=1)(2=0)
		lab val ge_leadership agree										
	rename ge_6			ge_business
		recode ge_business (1=1)(2=0)
		lab val ge_business agree	
	rename ge_7			ge_autonomy												// Reversed
		recode ge_autonomy (1=1)(2=0)
		lab val ge_autonomy agree		
	rename ge_8			ge_polygamy
		recode ge_polygamy (1=1)(2=0)
		lab val ge_polygamy agree	
	rename ge_9			ge_hhfinance
		recode ge_hhfinance (1=1)(2=0)
		lab val ge_hhfinance agree	
	rename ge_10		ge_adultery
		recode ge_adultery (1=1)(2=0)
		lab val ge_adultery agree	
		
lab var ge_raisekids "A husband and wife should share equally in raising children."
lab var ge_earning "[REVERSED] If a woman earns more money than her husband, it's almost certain to cause problems"
lab var ge_school "[REVERSED] It is more important that a boy goes to school than a girl"
lab var ge_work "[REVERSED] When jobs are scarce, men should have more right to a job than women"
lab var ge_leadership "In general, women make equally good village leaders as men"
lab var ge_business "In general, women are just as able to run a successful business as men"
lab var ge_autonomy "[REVERSED] When a woman goes out to see a friend or neighbor, she should ask her husband for permission"
lab var ge_polygamy "A man must get approval from his wife before he takes a new wife"
lab var ge_hhfinance "A man should consult his wife before he makes an important economic decision for the household"
lab var ge_adultery "A wife is right to punish her husband if he brings home another woman."

foreach var of varlist ge_* {
	recode `var' (-999 = .d)
}

rename s8q1			fm_reject
	recode fm_reject (1=0)(2=1)
	lab var fm_reject "[REVERSED] A woman shoudl not have a say in who she marries"
	lab val fm_reject agree
	
rename s8q4			em_reject
	tab em_reject
	
rename s8q6			em_norm_prescriptive										// NEED TO BE CAREFUL WITH THIS, IT WAS SWITCHED MID-SURVEY

rename s8q7			em_norm_empirical

	
/* Media Consumption ___________________________________________________________*/

rename s4q2_listen_radio	media_radio
	recode media_radio (6 = 0)
	lab def s4q2_listen_radio 0 "Never", modify
	lab val media_radio s4q2_listen_radio
rename s4q3_radio_3month	media_radio_ever
	replace media_radio_ever = 1 if 	media_radio == 1 | ///
										media_radio == 2 | ///
										media_radio == 3 | ///
										media_radio == 4 | ///
										media_radio == 5

* Favorite Radio Program Types
rename s4q5_programs_sm		media_radio_type	
	rename s4q5_programs_sm_1		media_radio_type_music
	rename s4q5_programs_sm_2		media_radio_type_sports
	rename s4q5_programs_sm_3		media_radio_type_news
	rename s4q5_programs_sm_4		media_radio_type_rltnship
	rename s4q5_programs_sm_5		media_radio_type_social
	rename s4q5_programs_sm_6		media_radio_type_relig
lab val media_radio_type_* yesnolisten

	foreach var of varlist media_radio_type_* {
		replace `var' = 0 if media_radio_ever == 0
	}

* Favorite Radio Stations
rename s4q6_listen_sm				media_radio_stations
	rename s4q6_listen_sm_1			media_radio_stations_voa
	rename s4q6_listen_sm_2			media_radio_stations_tbc
	rename s4q6_listen_sm_3			media_radio_stations_efm
	rename s4q6_listen_sm_4			media_radio_stations_breeze
	rename s4q6_listen_sm_5			media_radio_stations_pfm
	rename s4q6_listen_sm_6			media_radio_stations_clouds
	rename s4q6_listen_sm_7			media_radio_stations_rmaria
	rename s4q6_listen_sm_8			media_radio_stations_rone
	rename s4q6_listen_sm_9			media_radio_stations_huruma
	rename s4q6_listen_sm_10		media_radio_stations_mwambao
	rename s4q6_listen_sm_11		media_radio_stations_wasafi
	rename s4q6_listen_sm_12		media_radio_stations_nuru
	rename s4q6_listen_sm_13		media_radio_stations_uhuru
	rename s4q6_listen_sm_14		media_radio_stations_bbc
	rename s4q6_listen_sm_15		media_radio_stations_sya
	rename s4q6_listen_sm_16		media_radio_stations_tk
lab val media_radio_stations_* yesnolisten
									
** Pangani FM	
rename s4q7a_				media_uhuru
rename s4q7_panganifm 		media_pfm
	replace media_pfm = 1 if media_radio_stations_pfm == 1

** Pangani FM Shows																// Should we keep as missing or set to zero if they dont listen to PFM?
rename s4q8_programs_sm 			media_pfm_shows
	rename s4q8_programs_sm_1		media_pfm_shows_couples
	rename s4q8_programs_sm_2		media_pfm_shows_soap
	rename s4q8_programs_sm_3		media_pfm_shows_leaders
	rename s4q8_programs_sm_4		media_pfm_shows_women
	rename s4q8_programs_sm_5		media_pfm_shows_youth
lab val media_pfm_shows_* listen

foreach var of varlist media_pfm_shows_* {
	replace `var' = 0 if  media_pfm_shows == ""
}

rename s4q9_callpfm							media_pfm_call

** Call into PFM Shows	
	rename  s4q9b_callpfm_programs_1 		media_pfm_call_couples
	rename  s4q9b_callpfm_programs_2		media_pfm_call_soap
	rename  s4q9b_callpfm_programs_3 		media_pfm_call_leaders
	rename  s4q9b_callpfm_programs_4		media_pfm_call_women
	rename  s4q9b_callpfm_programs_5		media_pfm_call_youth
	
	foreach var of varlist media_pfm_call_* {
		replace `var' = 0 if media_radio_ever == 0
	}

** News
rename s4q10_news 				media_news
	
** Call 																		
rename s4q10_radio_show			media_radio_call

** Reports
rename s4q11_vill_report		media_villreport	
rename s4q12_ward_leader		media_locleader
rename s4q13_ntl_leader			media_natleader								
rename s4q13_spoken_journalist	media_talkjourno


/* Political Participation ______________________________________________________*/

** Generate Interest
rename s15q1	ptixpart_interest

** Participation Activities														// If we are doing a "conacted" question, then can get rid of those choices from this list, no
forval i = 1/15 {
	gen ptixpart_activ_`i' = .
		forval j = 1/4 {	
			replace ptixpart_activ_`i' = s15q2_r_`j' if s15q2_rand_rank_r_`j' == "`i'"
		}
}

	rename ptixpart_activ_1 		ptixpart_activ_voteregister					// NEED TO COME CHECK ON THIS
	rename ptixpart_activ_2			ptixpart_activ_votenatl	
	rename ptixpart_activ_3 		ptixpart_activ_votelocal
	rename ptixpart_activ_4			ptixpart_activ_votetalk
	rename ptixpart_activ_5 		ptixpart_activ_workparty
	rename ptixpart_activ_6			ptixpart_activ_talklocgov_vill
	rename ptixpart_activ_7			ptixpart_activ_rally
	rename ptixpart_activ_8			ptixpart_activ_villmeet
	rename ptixpart_activ_9			ptixpart_activ_wardmeet
	rename ptixpart_activ_10		ptixpart_activ_talknatlgov
	rename ptixpart_activ_11		ptixpart_activ_collectiveaction
	rename ptixpart_activ_12		ptixpart_activ_creategroup
	rename ptixpart_activ_13		ptixpart_activ_journo
	rename ptixpart_activ_14		ptixpart_activ_villmeetspoke
	rename ptixpart_activ_15		ptixpart_activ_talklocgov__hh

	lab val ptixpart_activ_* yesno
	

cap rename s15q7						ptixpart_contact_satisfied


/* Women's Political Participation _____________________________________________

	Note: This is also an experiment
	
*/

rename s21_txt_treat wppexp_treatment

rename s21q1	wpp_attitude
	gen wpp_attitude_dum = 1 if wpp_attitude == 1 | wpp_attitude == 2
	replace wpp_attitude_dum = 0 if wpp_attitude == 0
	lab var wpp_attitude_dum "Who should lead? Equal women or more women"
	
rename s21q2	wpp_norm
	gen wpp_norm_dum = 1 if wpp_norm == 1 | wpp_norm == 2
	replace wpp_norm_dum = 0 if wpp_norm == 0
	lab var wpp_norm_dum "Who should lead? Equal women or more women"
	
rename s21q3	wpp_behavior

foreach var of varlist wpp_* {
	recode `var' (-999 = .d)(-888 = .r)
}



/* Early Marriage _____________________________________________

	Note: This is also an experiment on supreme court
	
*/

** Treatment Assignment
destring treat_rand, replace
gen courtexp_treatment = .
	replace courtexp_treatment = 0 if treat_rand < 0.4
	replace courtexp_treatment = 1 if treat_rand > 0.4 & treat_rand <= 0.7
	replace courtexp_treatment = 2 if treat_rand > 0.7
	lab def courtexp_treatment 0 "Control" 1 "Court Only" 2 "Court + AG"
	lab val courtexp_treatment courtexp_treatment
	lab var courtexp_treatment "Supreme Court Experiment Treatment Assignment"
	
gen courtexp_treatment_dum = (courtexp_treatment == 1 | courtexp_treatment == 2)

gen courtexp_treatment_court = 1 if courtexp_treatment == 1
	replace courtexp_treatment_court = 0 if courtexp_treatment == 0

gen courtexp_treatment_both = 1 if courtexp_treatment == 2
	replace courtexp_treatment_both = 0 if courtexp_treatment == 0

gen normsexp_treatment = "Des_Perm" if s8q2_rand_cl == "1"
	replace normsexp_treatment = "Des_Rej" if  s8q2_rand_cl == "2"
	replace normsexp_treatment = "Pres_Perm" if  s8q2_rand_cl == "3"
	replace normsexp_treatment = "Pres_Rej" if  s8q2_rand_cl == "4"

rename s17q1		em_awarelaw

rename s17q4		em_supportban
	recode em_supportban (2=0) if date == "date2020-11-07"
	
rename s17q5		em_supportban_comm
		recode em_supportban_comm (2=0) if date == "date2020-11-07"

	foreach var of varlist em_supportban* {
		destring `var', replace
		lab val `var' yesno
	}

rename s8q8		em_report
rename s8q9		em_report_comm

rename s17q7		em_record_any
*rename s17q8																	
rename s17q9 		em_record_support
	replace em_record_support = 0 if em_record_any == 0
	
rename s17q10		em_record_name	
	replace em_record_name = 0 if em_record_any == 0 
	
rename s17q11		em_record_shareptix		
	replace em_record_shareptix = 0 if em_record_any == 0 & record_rand_draw == "gov"
rename s17q12		em_record_sharepfm
	replace em_record_sharepfm = 0 if em_record_any == 0 & record_rand_draw == "pfm"
	
gen em_record_shareany = em_record_sharepfm 
	replace em_record_shareany = em_record_shareptix if em_record_sharepfm == .
	
foreach var of varlist em_* {
	recode `var' (-999 = .d) (-888 = .r)
}
	


/* Political Knowledge _________________________________________________________*/

* Popular Culture
destring s13q1, replace
gen ptixknow_pop_music = .
	replace ptixknow_pop_music = 1 if 	(s13q1 == 4 | s13q1 == 3) & ///
										s13q1_txt_eng == "Most popular musician in Tanzania"
	replace ptixknow_pop_music = 0 if 	(s13q1 == 5 | s13q1 == -999) & ///
										s13q1_txt_eng == "Most popular musician in Tanzania"
	replace ptixknow_pop_music = .e if 	(s13q1 == 1 | s13q1 == 2) & ///
										s13q1_txt_eng == "Most popular musician in Tanzania"
									
gen ptixknow_pop_sport = .
	replace ptixknow_pop_sport = 1 if 	(s13q1 == 1) & ///
										s13q1_txt_eng == "Football team that will win the Tanza.."
	replace ptixknow_pop_sport = 0 if 	(s13q1 == 2 | s13q1 == -999) & ///
										s13q1_txt_eng == "Football team that will win the Tanza.."
	replace ptixknow_pop_sport = .e if 	(s13q1 == 3 | s13q1 == 4) & ///
										s13q1_txt_eng == "Football team that will win the Tanza.."
										
* Local Politics
gen ptixknow_local_dc = s13q2 if s13q2_txt_eng == "The District Commissioner of your Dis.."
gen ptixknow_local_vc = s13q2 if s13q2_txt_eng == "The Village Chairperson of your Village"
gen ptixknow_local_wc = s13q2 if s13q2_txt_eng == "The Ward Councilor (Diwani) of your W.."
gen ptixknow_local_mp = s13q2 if s13q2_txt_eng == "The elected MP in your District"

** NEED TO GET CORRECT INFO AND GENERATE CORRECT VS INCORRECT VARIABLE

* National Politics
gen ptixknow_natl_justice = s13q3 if s13q3_txt == "Ibrahim Hamis Juma"
	recode ptixknow_natl_justice (4=1)(1=0)(2=0)(3=0)(-999=0)
gen ptixknow_natl_prez = s13q3 if s13q3_txt == "John Magafuli"
	recode ptixknow_natl_prez (1=1)(4=0)(2=0)(3=0)(-999=0)
gen ptixknow_natl_pm = s13q3 if s13q3_txt == "Majaliwa Kassim Majaliwa"
	recode ptixknow_natl_pm (2=1)(1=0)(4=0)(3=0)(-999=0)
gen ptixknow_natl_vp = s13q3 if s13q3_txt == "Samia Suluhu"
	recode ptixknow_natl_vp (3=1)(1=0)(2=0)(4=0)(-999=0)
	
lab val ptixknow_natl_* correct

* Foreign Affairs
gen ptixknow_fopo_trump = s13q4new if s13q4_txt_eng == "Donald Trump"
	recode ptixknow_fopo_trump (-999 = 0) (-222 = 0) (2 = 0) (-888 = 0)
gen ptixknow_fopo_biden = s13q4new if s13q4_txt_eng == "Joe Biden"
	recode ptixknow_fopo_biden (-999 = 0) (-222 = 0) (2 = 0) (-888 = 0)
gen ptixknow_fopo_kenyatta = s13q4new if s13q4_txt_eng == "Uhuru Kenyatta"
	recode ptixknow_fopo_kenyatta (-999 = 0) (-222 = 0) (2 = 1) (1 = 0) (-888 = 0)

	lab val ptixknow_fopo_* correct
	
foreach var of varlist ptixknow_* {
	cap recode `var' (-999 = 0)(-222 = 0)
}
	

/* Intimate Partner Violence __________________________________________________*/

/*Principles Introduction
rename s9_1_a  		ipv_prime_nohit
rename s9_1_b		ipv_prime_punish
rename s9_1_c		ipv_primate_control
gen ipv_prime = 0 if ipv_primate_control != .
	replace ipv_prime = 1 if ipv_prime_nohit != .
	replace ipv_prime = 2 if ipv_prime_punish != .
	lab def ipv_prime 0 "Control" 1 "Hitting Bad" 2 "Punishment Good"
	lab val ipv_prime ipv_prime 
*/
	
* Reject IPV																// Will need to come back and recode this now that the structure is different
rename s9q1a		ipv_rej_disobey
rename s9q1b		ipv_rej_hithard
	recode ipv_rej_hithard (2=1)(1=0)
rename s9q1c		ipv_rej_persists


forval i = 1/6 {
	gen ipv_rej_`i' = .
		forval j = 1/3 {	
			replace ipv_rej_`i' = s9q1d_i_r_`j' if s9d_i_qn_sel_r_`j' == "`i'"
		}
}


rename ipv_rej_1 		ipv_rej_cheats
rename ipv_rej_2		ipv_rej_kids
rename ipv_rej_3		ipv_rej_work
rename ipv_rej_4		ipv_rej_gossip
rename ipv_rej_5		ipv_rej_elders
rename ipv_rej_6		ipv_rej_cook

foreach ipv of varlist ipv_rej* {
	replace `ipv' = .d if `ipv' == -999
	replace `ipv' = .r if `ipv' == -888
	recode `ipv' (1=0)(0=1)
	lab val `ipv' reject	
}

gen ipv_rejindex 	= (ipv_rej_disobey + ipv_rej_cheats + ipv_rej_kids + ipv_rej_work + ipv_rej_gossip + ipv_rej_elders + ipv_rej_cook)
egen ipv_rejall		= rowmin(ipv_rej_disobey ipv_rej_cheats ipv_rej_kids ipv_rej_work ipv_rej_gossip ipv_rej_elders ipv_rej_cook)
	lab val ipv_rejall yesno
	
rename s9q2 			ipv_norm_rej
	recode ipv_norm_rej (1=0)(0=1)(-999 = .d)

* IPV Report
rename s9q3a		ipv_report_police
	recode ipv_report_police (2=0)
	lab def ipv_report_police 0 "Don't Report" 1 "Report to police"
	lab val ipv_report_police ipv_report_police
	lab var ipv_report_police "How respond to cousin being absued by husband?"

rename s9q3b		ipv_report_vc
	recode ipv_report_vc (2=1)(1=0)
	lab def ipv_report_vc 0 "Dont Report" 1 "Report to VC"
	lab val ipv_report_vc ipv_report_vc
	lab var ipv_report_vc "How respond to cousin being absued by husband?"

rename s9q3c		ipv_report_parents
	recode ipv_report_parents (2=1)(1=0)
	lab def ipv_report_parents 0 "Dont Report" 1 "Report to Parents"
	lab val ipv_report_parents ipv_report_parents
	lab var ipv_report_parents "How respond to cousin being absued by husband?"
	
rename s9q3d		ipv_report_femleader
	recode ipv_report_femleader (2=1)(1=0)
	lab def ipv_report_femleader 0 "Dont Report" 1 "Report to Female Leader"
	lab val ipv_report_femleader ipv_report_femleader
	lab var ipv_report_femleader "How respond to cousin being absued by husband?"
	
* Perceptions of IPV Response
rename s9q4 		ipv_gov_man_self											

gen ipv_gov_t_rape = 1 if s9q5_txt_eng == "raped one night"
	replace ipv_gov_t_rape = 0 if s9q5_txt_eng == "beaten by husband"
	
gen ipv_gov_t_young = 1 if s9q6_txt_eng == "young"
	replace ipv_gov_t_young = 0 if s9q6_txt_eng == "adult"

rename s9q5			ipv_gov_fem_self


/* Pscyhology __________________________________________________________________*/

rename s19q2a 		psych_likethinking
    destring s19_q3_rand, replace
	gen psych_other= 1 if s19_q3_rand < 0.5 // other
	replace psych_other= 0 if s19_q3_rand > 0.5 // yourself
	replace psych_other= . if s19_q3_rand ==.
	
	recode psych_likethinking (2=1) (1=0)
	lab def thinking 1 "Like tasks that require thinking" 0 "Like tasks that don't require a lot of thought"
	lab val psych_likethinking thinking


rename s19q3_1		psych_big5_extrovert												// Should we be randomizing order
rename s19q3_2		psych_big5_critical
rename s19q3_3		psych_big5_dependable	
rename s19q3_4		psych_big5_anxious
rename s19q3_5		psych_big5_open
rename s19q3_6		psych_big5_quiet
rename s19q3_7		psych_big5_warm
rename s19q3_8		psych_big5_careless
rename s19q3_9		psych_big5_calm
rename s19q3_10		psych_big5_conventional




/* Relationships ________________________________________________________________*/

** People you would live near
forval i = 1/4 {
	gen couples_labor_`i' = .
		forval j = 1/2 {	
			replace couples_labor_`i' = s12q1_r_`j' if s12q1_ranked_list_r_`j' == "`i'"
		}
}

	rename couples_labor_1 		couples_labor_water
	rename couples_labor_2		couples_labor_laundry
	rename couples_labor_3		couples_labor_kids
	rename couples_labor_4		couples_labor_money
	
	foreach var of varlist couples_labor_* {
		lab val `var' s12q1_r_1
	}

** Final Decisions
rename s12q2a 					couples_decide_clinic
gen couples_decide_edu = .
	replace couples_decide_edu = s12q12b if s12q2_txt_eng == "children's education"
gen couples_decide_hh = .
	replace couples_decide_hh = s12q12b if s12q2_txt_eng == "household repairs"
	
	foreach var of varlist couples_decide* {
		lab val `var' s12q2a 
	}

** Partner 
rename s12q13a					couples_support
rename s12q13b					couples_insult

rename s12q14a					couples_crutch
rename s12q14b					couples_dependable
rename s12q14c					couples_notopen
rename s12q14d					couples_unfaithful

rename s12q15					couples_marriagerating


/* Parenting ___________________________________________________________________*/

rename s11q1		parent_currentevents

rename s11q3		parent_question
	recode parent_question (2=1) (1=0)
	lab def parent_question 0 "Agree" 1 "Disagree"
	lab val parent_question parent_question
	lab var parent_question "Agree (0) or Disagree (1): Parents should not allow children to question their decisions"
	

/* Violence Against Children ___________________________________________________

	Note: as with IPV and GE, attitudes are always towards REJECTING 
	violence / hierarchy, but behaviors are currently just yes/no commited the act
	
*/

rename s18_treat_draw vacexp_treatment

** Define label
lab def vac_reject  1 "Children must never be beaten" 0 "Hitting a child is sometimes justified"

** VAC Attitudes
rename s10q1		vac_reject
	recode vac_rej 2=0
	lab val vac_reject vac_reject
	lab var vac_reject "Which statement are others in your community most likely to agree with?"

rename s10q2		vac_reject_com
	recode vac_reject_com 2=0
	lab val vac_reject_com vac_reject
	lab var vac_reject_com "Which statement are others in your community most likely to agree with?"

rename s18q1			vac_report
	recode vac_report 2=0
	lab val vac_report report
	
rename s18q2		vac_report_norm
	recode vac_report_norm (2=0)
	lab val vac_report_norm report

rename s18q3		vac_govresponse
	
** VAC Behaviors
rename s10q6_sm_2	vac_punish_shout
	lab var vac_punish_shout "Have you shouted at children in last month?"
	
rename s10q6_sm_3	vac_punish_hithand
	lab var vac_punish_hithand "Have you hit children with hand in last month?"
	
rename s10q6_sm_4		vac_punish_hitobj
	lab var vac_punish_hitobj "Have you hit children with stick or object in last month?"
	

/* Assetts _____________________________________________________________________*/

rename s16q1		assets_radio
rename s16q2		assets_radio_num
	replace assets_radio_num = 0 if assets_radio == 0
rename s16q3		assets_tv
rename s16q5		assets_cell
rename s16q6		assets_cell_internet
	replace assets_cell_internet = 0 if assets_cell == 0												// If don't have cell, don't have internet
rename s16q7		assets_rooftype


/* Conclusion __________________________________________________________________*/

rename s20q1				svy_followupok		

rename s20q3				svy_others
rename s20q4_sm				svy_others_who

* Save _________________________________________________________________________*/

	save "${data}/02_mid_data/pfm_cm_1_2020_clean.dta", replace
											
				
				

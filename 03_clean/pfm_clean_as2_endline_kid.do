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

	use "${data}/01_raw_data/03_surveys/pfm_nopii_as2_endline_kids.dta", clear
	gen as2_endline_kids = 1
	
	
/* Data ________________________________________________________________________*/	

	
	* If want to look at training and pilot, go to master and select the appropriate files
	
	* Remember, you have to run this dofile in between the import and this cleaning -- which fixes field mistakes!
	*	do "${userboxcryptor}07_Questionnaires & Data/04 Endline/03 Data Flow/0_master.do"	
	

	gen startdate 	= dofc(starttime)
	gen enddate		= dofc(endtime)
	gen subdate 	= dofc(submissiondate)
	
	format %td startdate enddate subdate

/**/
	drop if startdate <= date("24jul2023", "DMY")
	*duplicates drop resp_id, force
	duplicates list k_resp_id_pull



/* Admin _______________________________________________________________________*/	
				
		* survey_length	
			generate double survey_length = endtime - starttime
			replace survey_length = round(survey_length / (1000*60), 1) // in minutes */

		* endline ID
			gen endline = (startdate >= date("24jul2023", "DMY"))

/* ID __________________________________________________________________________*/  

	count

	gen k_resp_id = id 
	distinct resp_id
	
	* if any issue, raise with fieldteam who will fix in IPA system.
	
/* Pulled treatment assignment _________________________________________________*/

	destring treat_pull, replace
	rename treat_pull treat
	la de treat 0 "env" 1 "gbv"
	la val treat treat

/*
	la de treat_rd 0 "flashlight" 1 "radio"
	la val treat_rd treat_rd
*/

/* PI experiment  _____________________________________________________________*/

	fre rand_pi
	replace rand_pi = "comm" if rand_pi == "parent"
	
	destring emreject_comm_pull, gen(rand_pi_value_num)
	destring emcount_comm_pull,  gen(rand_pi_value_den)
	replace rand_pi_value_num = 9 	if startdate <= date("7aug2023", "DMY")
	replace rand_pi_value_den = 10 	if startdate <= date("7aug2023", "DMY")
	gen  rand_pi_value =	rand_pi_value_num/rand_pi_value_den

	
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
	*replace resp_id = "2_101_5_04" if resp_id == "2_101_5_004"

	
	destring resp_female, replace
		*lab def resp_female 0 "Male" 1 "Female"
	lab val resp_female resp_female 
	
		* check that resp_female was correctly replaced if gender was not confirmed from pull
/*
		rename gender_correction correction_gender
		gen check_gender = (gender_confirm == 0)
		tab resp_female correction_gender if check_gender == 1 
		drop check_gender
	
	tab info_confirm														

	rename info_correction_1	correction_name
	rename info_correction_3	correction_marital
	rename info_correction_4	correction_village
	rename info_correction_5	correction_subvillage
*/

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

	*rename visits_nbr svy_visitsnum
	rename enum svy_enum 
	rename consent svy_consent 

	
/* Respondent Information ______________________________________________________*/

	tab resp_describe_day, m
	tab resp_tribe, m
	
	tab values_tzvstribe, m
	recode values_tzvstribe	(1 2 = 1 "TZ > Tribe") (3 4 5 = 0 "TZ <= Tribe"), gen(values_tzovertribe_dum)


/* Family Life _________________________________________________________________*/

	tab parenting_permission, m 
	tab parenting_talk, m	
	
	rename relationship_discuss_1 parenting_discuss_news 
	rename relationship_discuss_2 parenting_discuss_school 
	rename relationship_discuss_3 parenting_discuss_family 
	rename relationship_discuss_9 parenting_discuss_none 
	
	rename s12q1a family_resp_water
	rename s12q1b family_resp_laundry
	rename s12q1c family_resp_childcare
	rename s12q1d family_resp_money
	
	foreach var of varlist parenting_* {
	
		tab `var', m
	
	}
	

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

	
/* Political Participation and Efficacy ________________________________________*/ 

	tab pknow_interest, m
	
	rename ppart_efficacy sb_efficacy
	recode sb_efficacy (2 = 1 "Understand ptix")(1 = 0 "Ptix complicated"), gen(ppart_efficacy)
	
	tab ppart_efficacy treat_rd, col m
	
	rename ppart_leadership sb_lead
	recode sb_lead (1 = 1 "Want to lead")(2 = 0 "Dont want to lead"), gen(ppart_leadership)
	
	

	
/* WPP _________________________________________________________________________*/

	tab wpp_behavior treat_rd, col	
	recode wpp_leaders_men (1 = 1 "Women just as god")(2 = 0 "Women not as good"), gen(wpp_attitudes2_dum)
	
	
/* Crime _______________________________________________________________________*/

	tab crime_national treat_rd, col
	
	
/* Relationships _______________________________________________________________*/

	tab rship_should, m
	
	rename s3q12 ge_idealkidnum
	tab ge_idealkidnum, m
	
*	rename scouples_q2_f ge_girlmakemoney
*	replace ge_girlmakemoney = scouples_q2_m if ge_girlmakemoney == .
*	tab ge_girlmakemoney, m
	
	rename rship_permission_w rship_permission 
		replace rship_permission = rship_permission_m if rship_permission == .
	fre rship_permission

	/* Core outcome */
	rename scouples_q2_f		ge_wep
		replace ge_wep = scouples_q2_m if resp_female == 0
		recode ge_wep (2=3)(3=2)
		lab val ge_wep ge_wep
		
	gen ge_wep_dum = 1 if ge_wep == 3
			replace ge_wep_dum = 0 if ge_wep == 1
			replace ge_wep_dum = . if ge_wep == 2
			lab val ge_wep_dum agree 
			lab var ge_wep_dum "Woman [man] support self [wife] participating economically"
	
	
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

/* Political Knowledge and interest ____________________________________________*/

	rename s13q1b pknow_favefood
	tab pknow_favefood, m
	
	tab pknow_trust, m
	
	rename s13q1a pknow_music
		tab pknow_music, m
		
	tab pknow_president, m
	tab pknow_vicepresident, m
		replace pknow_vicepresident = 0 if pknow_vicepresident == .d
		
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
	


	
	
/* Forced marriage _____________________________________________________________*/
	
	tab gender_fm, m
		
	recode gender_fm (1 = 0 "Accept FM") (2 = 1 "Reject FM"), gen(fm_reject) 											// recoded on June 18, 2024!
	
	recode gender_fm_branched (2 = 0 "Strong accept FM") (1 = 1 "Accept FM") (3 = 2 "Reject FM") (4 = 3 "Strong reject FM"), gen(ge_fm_long)
		replace ge_fm_long = 3 if gender_fm_down == 2
		replace ge_fm_long = 2 if gender_fm_down == 1
		
	gen ge_fm_norm_parent = gender_fm_parent
	gen ge_fm_norm_comm = gender_fm_norm
	
/* Gender norms ________________________________________________________________*/

	recode gender_earning 		 (2 = 1 "PRO Women$$>Man") (1 = 0 "AGAINST Women$$>Man"), gen(ge_earning) 				// recoded on June 18, 2024!
	recode gender_earning_parent (2 = 1 "PRO Women$$>Man") (1 = 0 "AGAINST Women$$>Man"), gen(ge_earning_norm_parent)	// recoded on June 18, 2024!
	
	recode ge_school 			 (2 = 1 "Equal school") (1 = 0 "Boys more school"), gen(ge_school_dum)					// recoded on June 18, 2024!
			
	rename parenting_helicopter sb_helicopter
	recode sb_helicopter (1 = 0 "Helicopter good")(2 = 1 "Helicopter bad"), gen(parenting_helicopter)					// recoded on June 18, 2024!
	
		

/* Environment Causes __________________________________________________________*/
		
	recode env_ccknow_mean (1 2 3 = 2)(4 5 6 7 -888 -999 = 0), gen(enviro_ccknow_long)
	lab var enviro_ccknow_long "Dummy: Know meaning of climate change"
	replace enviro_ccknow_long = 1 if env_ccknow == 1 & enviro_ccknow_long == 0 
															
	recode env_cause (4 5 6 7 8 = 2)(1 2 3 9 10 -222 -999 = 0), gen(enviro_cause_human)		// DWG: for outcome measure, do we want to set this to zero if they got the meaning of climate change wrong
	lab var enviro_cause_human "Environmental problems primarily caused by humans, secondarily, or not at all"

	
	recode env_cause (7 = 1)(1 2 3 4 5 6 8 9 10 -222 -999 = 0), gen(enviro_cause_intl)
	lab var enviro_cause_intl "Dummy: enviro prob caused by international folks"

	foreach var of varlist enviro_* {
		cap fre enviro_*
	}
	
	rename envoutcm_politician enviro_voteenviro

	
/* GBV _________________________________________________________________________*/
	
	* risky travel att + norm
	recode gbv_safe_travel (2 = 1 "Generally risky")(1 = 0 "Generally safe"), gen(gbv_travel_risky_short)
	
	gen gbv_travel_risky_long = gbv_travel_risky_short
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
	replace gbv_boda_risky_long = 1 if gbv_safe_boda_bu==1
	replace gbv_boda_risky_long = 2 if gbv_safe_boda_bd==2
	replace gbv_boda_risky_long = 3 if gbv_safe_boda_bd==3
	lab def gbv_boda_risky_long 0 "Very safe" 1 "Safe enough" 2 "Quite risky" 3 "Very risky"
	lab val gbv_boda_risky_long gbv_boda_risky_long

	recode gbv_safe_boda_norm (1 = 0 "Safe")(0 = 1 "Risky"), gen(gbv_boda_risky_norm)
	
	tab 	end_gbv_norm_rand_txt
	tab gbv_boda_risky_norm rand_parent_txt

	* Party
	tab gbv_safe_party_self if resp_female == 1, m
	
	* Streets																	
	tab gbv_resp_streets_self if resp_female == 1, m
	rename gbv_resp_streets_self gbv_safe_streets_self_short 
	
	* GBV Response
	gen gbv_response = .
		replace gbv_response = gbv_response_1v 
		replace gbv_response = gbv_response_2v if gbv_response == .
		replace gbv_response = gbv_response_3v if gbv_response == .
		
	gen gbv_response_gov = (gbv_response == 2)
	

	rename gbv_response_norm gbv_response_parent
		label de gbv_response_parent 	0 	"Wait for situation to resolve itself" ///
									1	"Report the issue to the girl's family" ///
									2	"Report the issue to the VEO or VC" ///
									3	"Report the issue to the teachers" ///
									, modify
									
		label val gbv_response_parent gbv_response_parent		
	
	gen gbv_response_parent_gov = (gbv_response_parent == 2)



/* Media Consumption ___________________________________________________________*/

	* two weeks
	rename s4q2_listen_radio media_listen_radio 
	rename media_listen_radio radio_listen
	gen radio_listen_twoweek = 1 if radio_listen == 1 | radio_listen == 2 | radio_listen == 3
			replace radio_listen_twoweek = 0 if radio_listen == 0

	* 3 months
	rename s4q3_radio_3month media_radio_3month
	rename media_radio_3month radio_ever
		replace radio_ever = 1 if  			radio_listen_twoweek == 1 | ///
											radio_listen_twoweek == 2 | ///
											radio_listen_twoweek == 3 

	rename s4q5_programs_sm* 	media_programs_sm*	
	drop media_programs_sm
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
	
	rename s4q5_programs_oth media_programs_oth
	tab media_programs_oth															// DWG: add to hfc to checs														// DWG: Add to HFCs
		
	rename s4q6_listen_who radio_listen_whowith
	
		foreach var of varlist media_* {
			cap fre `var', m
		}

	
/* Audio screening compliance __________________________________________________*/

	rename compl_as2_parent compliance_attend_parent
	rename compl_as2_kid compliance_attend_kid
		replace compliance_attend_kid = 0 if compliance_attend_parent == 0
	rename compl_as2_topic compliance_discuss_topic
	rename compl_as2_topic_who compliance_discuss_who

	
	
	
/* Save ________________________________________________________________________*/	
	
	replace k_resp_id = "8_181_1_027_k1" if k_resp_id == "8_181_1_027_k2"
	replace k_resp_id = "8_181_1_027_k2" if k_resp_id == "8_181_1_027_k3"
	replace k_resp_id = "8_181_1_061_k1" if k_resp_id == "8_181_1_061_k2"

	
	/* Converting don't know/refuse/other to extended missing values first */
	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

	
	save "${data}/02_mid_data/pfm_as2_endline_clean_kids.dta" , replace
	*use "${data_endline}/pfm5_endline_cleaned_field_research.dta" , clear

	
/* Make Wide ___________________________________________________________________*/

	gen helper = substr(k_resp_id,-1,.)
	encode helper, gen(id_kid_rank)
	drop helper

	rename * k_*
	rename k_k_* k_*
	
	rename k_resp_parent_interviewed_* k_resp_parent_int_*
	rename k_id_kid_rank    id_kid_rank
	rename k_resp_id_parent resp_id_parent
	
	reshape wide k_* , i(resp_id_parent) j(id_kid_rank)

					 
/* Export Wide __________________________________________________________________*/

	/* Converting don't know/refuse/other to extended missing values first */
	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

	save "${data}/02_mid_data/pfm_as_endline_clean_kid_wide.dta", replace
	
	
/*
/* GBV Indices _________________________________________________________________*/


		* Keep 
		#d ;
		keep 					resp_id
								k_resp_id
								treat
								gbv_travel_risky_short
								gbv_boda_risky_short
								gbv_safe_streets_self_short
								gbv_safe_party_self
								gbv_travel_risky_norm 
								gbv_boda_risky_norm
								gbv_response
								gbv_response_gov
								gbv_response_parent
								gbv_response_parent_gov
								gbv_elect 
								thermo_boda_num
								ge_school	
								gender_fm
								ge_school
								ge_earning 
								ge_fm_long 
								ge_fm_norm_parent 
								ge_fm_norm_comm
								parenting_helicopter
								;
		#d cr 

		* GBV Index 
		rename gbv_travel_risky_* gbv_risky_travel_* 
		rename gbv_boda_risky_* gbv_risky_boda_* 

			
		egen gbv_risk_index = rowmean(gbv_risky_travel_short gbv_risky_boda_short ///
										gbv_safe_party_self gbv_safe_streets_self_short)
		
		egen gbv_risk_norm_index = rowmean(gbv_risky_travel_norm gbv_risky_boda_norm)
			

		egen gbv_response_index = rowmean(gbv_response_gov)		
		egen gbv_response_norm_index = rowmean(gbv_response_parent_gov)
		
		egen gbv_prior_index = rowmean(gbv_elect)
		
		gen thermo_boda_short = thermo_boda_num/100
		
		rename * e_*
		rename e_resp_id resp_id 
		rename e_treat treat

		save "${data_bb}/pfm_gbv_endline_k.dta", replace

		
	/* Enviro Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_cleaned_field_research_k.dta", clear
		
		*gen enviro_ccknow_short = enviro_ccknow_mean_dum
		gen enviro_cause_human_short = enviro_cause_human/2
		egen enviro_know_index = rowmean(enviro_ccknow_long enviro_cause_intl)

		
		egen enviro_attitudes_index = rowmean(enviro_voteenviro)
			
		egen enviro_prior_index = rowmean(enviro_elect)
												
		gen thermo_leader_short = thermo_local_leader_num/100
		egen corruption_index = rowmean(thermo_leader_short)	
		
		

		
		* Keep 

		#d ;
		keep 					resp_id
								treat
								enviro_know_index
								enviro_ccknow_long
								enviro_cause_human_short
								enviro_cause_intl
								enviro_attitudes_index
								enviro_attitudes
								enviro_voteenviro
								enviro_prior_index
								enviro_elect
								thermo_business
								corruption_index
								thermo_leader
								startdate
								;
		#d cr
		
		rename * e_*
		rename e_treat treat
		rename e_resp_id resp_id 
		
		
	save "${data_env}/pfm_enviro_endline_k.dta", replace
	
	
/* WPP Indices ______________________________________________________________*/

		use "${data_endline}/pfm5_cleaned_field_research_k.dta", clear
		
		
		#d ;
		keep 					
								resp_id
								k_resp_id
								resp_female
								wpp_behavior 
								wpp_attitudes2
								ppart_leadership
								pknow_interest
								ppart_efficacy
								startdate
								;
		#d cr
		
		rename * yr_* 
		rename yr_resp_id resp_id 
		rename yr_k_resp_id k_resp_id
		
		save "${data_wpp}/pfm_wpp_endline_k.dta", replace
	
	
/*
		drop consented_grp1section_11treat_rd consented_grp1section_11rand_pri v570 v571 v572 v573 v574 consented_grp1section_11rand_saf v576 v577 v578 consented_grp1section_11treat_in consented_grp1section_11rand_tra v581 consented_grp1section_11rand_tim v583 v584 v585 v586 v587 v588 v589 v590 v591 v592 v593 v594 v595 v596 v597 v598 v599 v600 v601 v602 v603 consented_grp1section_11treat_be consented_grp1section_11rand_gif v606 consented_grp1section_11rand_val v608 consented_grp1section_11rand_sha v610 v611 v612 v613 v614 v615 v616 v617 v618 v619 v620 v621 v622 v623 v624 v625 v626 v627 v628 v629 v630 v631 v632 v633 v634 v635 v636 v637 v638 v639 v640 consented_grp1section_11rand_mee v642 consented_grp1section_11rand_lea v644 v645 v646 v647 v648 v649 v650 v651 v652 v653 v654 v655 v656 consented_grp1section_open1kidma consented_grp1radio_ownership_gr v659 consented_grp1section_radioexp_e consented_grp1section_conjoint_s consented_grp1section_conjoint_m consented_grp1rand_pilot_conjoin v664 v665 consented_grp1section_conjoint_w consented_grp1section_conjoint_e consented_grp1section_conjoint_d consented_grp1section_11wtp_15 v670 v671 consented_grp1section_gbv_grp1gb consented_grp1section_relationsh v674 consented_grp1section_open1neigh consented_grp1section_media1medi v677 v678 consented_grp1section_wtp_start consented_grp1section_wtp_end consented_grp1section_wtp_dur v682 v683 v684 v685 v686 v687 v688 v689 v690 v691 v692 v693 v694 v695 v696 v697 v698 v699 v700 v701 consented_grp1section_11treatmen v703 consented_grp1section_11thermo_c consented_grp1radio_radioexp_grp v706 v707 v708 v709 v710 v711 v712 v713 consented_grp1section_radioexp_d v715 consented_grp1section_wtp_soda1n consented_grp1section_wtp_soda1s consented_grp1section_wtp_soda1p consented_grp1section_wtp_soda1g v720 v721 v722 v723 v724 v725 v726 v727 v728 v729 v730 v731 v732 v733 v734 v735 v736 v737 v738 v739 v740 v741 v742 v744 v743 v745 v746 v747 v748 v749 v750 v751 v752 v753 v754 consented_grp1section_wtp_boda_1 v756 v757 v758 v759 v760 v761 v762 v763 v764 v765 v766 v767 v768 v769 v770 v771 v772 v773 v774 v775 v776 v777 v778 v779 v780 v781 v782 v783 v784 v785 v786 v787 v788 consented_grp1section_conjoint1s v790 v791 v792 v793 v794 v795 v796 v797 v798 v799 v800 v801 v802 v803 v804 v805 v806 v807 v808 v809 v810 v811 v812 v813 v814 v815 consented_grp1section_11resp_mar consented_grp1section_11agr_pull consented_grp1section_11end_gbv_ v819 consented_grp1section_11wtp_20 consented_grp1section_11wtp_30 consented_grp1section_11wtp_35 v823 v824 v825 v826 consented_grp1section_resp1secti consented_grp1section_11resp_nam v829 v830 v831 v832 v833 v834 v835 v836 v837 v838 v839 v840 v841 v842 v843 v844 v845 v846 v847 v848 v849 v850 v851 v852 v853 v854 v855 v856 v857 v858 v859 v860 v861 v862 ///
	treat_rd_pull section_radioexp_start radiown_ccm treatment_rand1 treatment_rand1_cl treatment_code1 radiown_description radio_rand2 radiown_emphas_ccm radiown_interest_listen section_radioexp_end v582 section_radioexp_dur v604 v605 v607 v609 v641 v643 v657 v658 v660 v661 v662 v663 v666 v667 v668 v669 v672 v676 v705 v714 v719 v755 v789 v818 v822 v828 v580 v673 v679 v680 v702 v704 rand_price1_txt_sw rand_price2_txt_sw rand_price3_txt_sw rand_price4_txt_sw rand_safety5 rand_safety5_txt rand_safety5_txt_sw rand_price5 rand_price5_txt rand_price5_txt_sw rand_safety6 rand_safety6_txt rand_safety6_txt_sw rand_price6 rand_price6_txt rand_price6_txt_sw treat_info rand_transport1 rand_transport1_txt rand_transport1_txt_sw rand_time1 rand_time1_txt rand_time1_txt_sw rand_transport2 rand_transport2_txt rand_transport2_txt_sw rand_time2 rand_time2_txt rand_time2_txt_sw rand_transport3 rand_transport3_txt rand_transport3_txt_sw rand_time3 rand_time3_txt rand_time3_txt_sw rand_transport4 rand_transport4_txt rand_transport4_txt_sw rand_time4 rand_time4_txt rand_time4_txt_sw rand_transport5 rand_transport5_txt rand_transport5_txt_sw rand_time5 rand_time5_txt rand_time5_txt_sw rand_transport6 rand_transport6_txt rand_transport6_txt_sw rand_time6 rand_time6_txt rand_time6_txt_sw treat_benefit_version rand_gift1 rand_gift1_txt rand_gift1_txt_sw rand_value1 rand_value1_txt rand_value1_txt_sw rand_share1 rand_share1_txt rand_share1_txt_sw rand_gift2 rand_gift2_txt rand_gift2_txt_sw rand_value2 rand_value2_txt rand_value2_txt_sw rand_share2 rand_share2_txt rand_share2_txt_sw rand_gift3 rand_gift3_txt rand_gift3_txt_sw rand_value3 rand_value3_txt rand_value3_txt_sw rand_share3 rand_share3_txt rand_share3_txt_sw rand_gift4 rand_gift4_txt rand_gift4_txt_sw rand_value4 rand_value4_txt rand_value4_txt_sw rand_share4 rand_share4_txt rand_share4_txt_sw rand_gift5 rand_gift5_txt rand_gift5_txt_sw rand_value5 rand_value5_txt rand_value5_txt_sw rand_share5 rand_share5_txt rand_share5_txt_sw rand_gift6 rand_gift6_txt rand_gift6_txt_sw rand_value6 rand_value6_txt rand_value6_txt_sw rand_share6 rand_share6_txt rand_share6_txt_sw rand_meet1 rand_meet1_txt rand_meet1_txt_sw rand_lead1 rand_lead1_txt rand_lead1_txt_sw rand_meet2 rand_meet2_txt rand_meet2_txt_sw rand_lead2 rand_lead2_txt rand_lead2_txt_sw rand_meet3 rand_meet3_txt rand_meet3_txt_sw rand_lead3 rand_lead3_txt rand_lead3_txt_sw rand_meet4 rand_meet4_txt rand_meet4_txt_sw rand_lead4 rand_lead4_txt rand_lead4_txt_sw rand_meet5 rand_meet5_txt rand_meet5_txt_sw rand_lead5 rand_lead5_txt rand_lead5_txt_sw rand_meet6 rand_meet6_txt rand_meet6_txt_sw rand_lead6 rand_lead6_txt rand_lead6_txt_sw treat_daughter rship_perm_w rship_perm_w_branched rship_perm_w_branched_c rship_perm_m rship_perm_m_branched rship_perm_m_branched_c kidmarry_nottz2 radioown_prefer radioown_bias_2nd section_conjoint_start section_conjoint_men_start rand_pilot_conjoints sc_safety_start sc_safety_lethergo_1 sc_safety_whynot_1 sc_safety_1rep sc_safety_2rep sc_safety_3rep sc_safety_end sc_safety_dur sc_safety_daughter_start sc_daughter_lethergo_2 sc_daughter_whynot_2 sc_safety_d_1rep sc_safety_d_2rep sc_safety_d_3rep sc_safety_daughter_end sc_safety_daughter_dur sc_benefit_start sc_benefit_mon_1rep sc_benefit_mon_1rep_split sc_benefit_mon_2rep sc_benefit_mon_2rep_split sc_benefit_mon_3rep sc_benefit_mon_3rep_split sc_benefit_meet_1rep sc_benefit_meet_2rep sc_benefit_end sc_benefit_dur ///
	section_conjoint_men_end section_conjoint_men_dur section_conjoint_women_start sc_safety_w_start sc_safety_w_wanttogo sc_safety_w_1rep sc_safety_w_2rep sc_safety_w_3rep sc_safety_w_end sc_safety_w_dur sc_benefit_w_start sc_benefit_w_mon_1rep sc_benefit_w_mon_1rep_split sc_benefit_w_mon_2rep sc_benefit_w_mon_2rep_split sc_benefit_w_mon_3rep sc_benefit_w_mon_3rep_split sc_benefit_w_meet_1rep sc_benefit_w_meet_2rep sc_benefit_w_end sc_benefit_w_dur section_conjoint_women_end section_conjoint_women_dur section_conjoint_end section_conjoint_dur v816 v817 v820 v817 v820 v821 v827 v863 v864 v865 v866 v868 v869 v870 v871 v872 v873 v874 v875 v876 v877 v878 v879 v880 v881 v882 v883 v884 v885 v886 v887 v888 v889 v890 v891
*/

	
/* _____________________________________________________________________________

	Project: Wellspring Tanzania, Natural Experiment Endline
	Purpose: Import raw data, preliminary cleaning, and remove PII
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	

/* Notes _______________________________________________________________________

	(1) Rememeber to cut out training and pilot data
	(2) Remember to use Non-PII data 

*/

/* Import  _____________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_rawpii_ne_endline.dta", clear
	

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def yesno_rev 0 "Yes" 1 "No"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def reject_cat 0 "Always Acceptable" 1 "Sometimes Acceptable" 2 "Never Acceptable"
	lab def interest 0 "Not interested" 1 "Somewhat interested" 2 "Interested" 3 "Very interested"
	lab def em_norm_reject 0 "Acceptable" 1 "Sometimes Acceptable" 2 "Never acceptable"



/* Survey Info _________________________________________________________________*/

	gen endline_ne = 1
	
	destring duration, gen(svy_duration)
		replace svy_duration = svy_duration / 60
		drop svy_duration
	
	rename enum svy_enum
	
	gen svy_enum_muslim=. 
	
	replace svy_enum_muslim= 1 if 	svy_enum==2  | ///
									svy_enum==7  | ///
									svy_enum==8  | ///
									svy_enum==10 | ///
									svy_enum==11 | ///
									svy_enum==14 | ///
									svy_enum==15 | ///
									svy_enum==20 | ///
									svy_enum==25
									
	replace svy_enum_muslim = 0 if svy_enum_muslim == .

	
	rename replacement_ys_n	svy_replacement
		replace svy_replacement = 0 if svy_replacement == .
		
	rename id				id_resp_uid	
	rename district_pull	id_district_n
	rename ward_pull		id_ward_n
	rename village_pull		id_village_n
	gen svy_date = 		 	startdate		

/* Consent _____________________________________________________________________*/

	rename consent consent															// HFC: Consent Check
	gen to_exclude = 1 if consent != 1
	drop if to_exclude == 1

/* Respondent Info ______________________________________________________________*/

	rename resp_name 		resp_name_new
	rename name_pull		resp_name
		replace resp_name = resp_name_new if resp_name_new != ""
		
	rename s2q1_ppe resp_ppe

	/* Age 

		Age is a little bit tricky because we updated the age variable after two days when
		we realized the original age question was inaccurate */
	
	drop resp_age
	destring age_pull, 		gen(resp_age)
	gen resp_age_yr	=		2017-resp_age

	gen resp_female = .
		replace resp_female = 1 if gender_pull == "Female"
		replace resp_female = 0 if gender_pull == "Male"
		lab val resp_female yesno 	
		
	rename s1q3 	resp_howyoudoing
		
	rename s3q3_status 	resp_rltn_status
	rename s3q4 		resp_rltn_age
		recode resp_rltn_age (-999 = .d)(-222 = .d)
		
	gen resp_rltn_age_yr = 2020 - resp_rltn_age 

	gen resp_married_yr = year(s3q5)
		recode resp_married_yr (-999 = .d)

	gen resp_married_age = resp_married_yr - resp_age_yr
	gen resp_rltn_married_age = resp_married_yr - resp_rltn_age_yr

	rename s3q7_hhh_nbr			resp_hh_size

	rename s3q8_hhh_children 	resp_hh_kids
		recode resp_hh_kids (-888 = .r)(-999 = .d)

	rename s3q11child_had 		resp_kids
		recode resp_kids (-888 = .r)(-999 = .d)

	rename s3q14_nbr_people 	resp_villknow

	rename s3q15_city_town		resp_urbanvisit
		recode resp_urbanvisit (-999 = .d)

	rename s3q14_vill_16		resp_livevill16

	gen resp_christian = s3q16_religion
		recode resp_christian (2=1)(3=0)(1=0)
		lab val resp_christian yesno
		
	gen resp_muslim = s3q16_religion
		recode resp_muslim (2=0)(3=1)(1=0)(-222=.d)
		lab val resp_muslim yesno
		
	rename s3q22_religious		resp_religiosity

	rename s3q17				resp_religiousschool
		replace resp_religiousschool = s3q18 if resp_christian == 1

	rename s3q19_tribe			resp_tribe											// Need to input "other"


	
/* General Values ______________________________________________________________*/

	rename s5q1 			values_conformity
		lab def values_conformity 0 "Always do what you think is right" 1 "Pay attention to others"
		lab val values_conformity values_conformity

		
	rename s5q2				values_trynew
		lab def values_trynew 0 "Do things as always done" 1 "Try new things"
		lab val values_trynew values_trynew
		
	rename s5q3				values_mediagood

	rename s5q4				values_dontquestion
		lab def values_dontquestion 0 "Question leaders" 1 "Respect authority"
		lab val values_dontquestion values_dontquestion
		
	rename s5q6				values_urbangood
		recode values_urbangood (-999 = .d) (-888 = .r) (1 = 0) (0 = 1)
		lab def values_urbangood 1 "Good to go to town" 0 "Support the family"
		lab val values_urbangood values_urbangood
		
	rename s3q20_tz_tribe		values_tzortribe
		gen values_tzortribe_dum = (values_tzortribe == 1 | values_tzortribe == 2)
		replace values_tzortribe_dum = . if values_tzortribe == -888 | values_tzortribe == .

	** Gender difference in support for urbanization
	rename gender_txt		treat_values_urbangood_gender

	
/* Prejudice ______________________________________________________________*/

** People you would live near

	/* Create Values */
	gen prej_yesneighbor_aids = .		
	gen prej_yesneighbor_homo = .
	gen prej_yesneighbor_alcoholic = .
	gen prej_yesneighbor_unmarried = .

	forval j = 1/3 {	
		replace prej_yesneighbor_homo = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mashoga"
		replace prej_yesneighbor_aids = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mtu mwenye virus vya ukimwi"
		replace prej_yesneighbor_alcoholic = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Walevi"
		replace prej_yesneighbor_unmarried = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Watu wanaoishi pamoja lakini hawajaoana"
		}
		
	foreach var of varlist prej_yesneighbor_* {
		lab var `var' "Would accept X group to be your neighbor"
		recode `var' (1=0)(0=1)
		recode `var' (1=0)(0=1) if (svy_enum==5 | svy_enum==13 | svy_enum==10 | ///
	     svy_enum==23)
		lab val `var' yesno
		recode `var' (-999 = .d)(-888 = .r)
	}	

	egen prej_yesneighbor_index = rowmean(prej_yesneighbor_aids prej_yesneighbor_homo prej_yesneighbor_alcoholic prej_yesneighbor_unmarried)
	lab var prej_yesneighbor_index "Mean of all questions about acceptable neighbors"

	** People your kid can marry
	forval i = 1/4 {
		gen prej_kidmarry`i' = .
			forval j = 1/2 {	
				replace prej_kidmarry`i' = s3q21_r_`j' if s3q21_sel_val_r_`j' == "`i'"			// Need to change this back to "2"
			}
		lab var prej_kidmarry`i' "Would accept X group to marry your child"
		lab val prej_kidmarry`i' yesno
	}
		rename prej_kidmarry1 		prej_kidmarry_nottribe				// Not sure this is coded right
		rename prej_kidmarry2		prej_kidmarry_notrelig
		rename prej_kidmarry3		prej_kidmarry_nottz
		rename prej_kidmarry4		prej_kidmarry_notrural	
		

		foreach var of varlist prej_kidmarry_* {
			cap recode `var' (-999 = .d)(-888 = .r)
		}	
		
		egen prej_kidmarry_index = rowmean(prej_kidmarry_nottribe prej_kidmarry_notrelig prej_kidmarry_nottz prej_kidmarry_notrural)
		lab var prej_kidmarry_index "Mean of all questions about who child can marry"

	** Feeling thermometer
	forval i = 1/7 {
		gen prej_thermo`i' = .
			forval j = 1/7 {	
				replace prej_thermo`i' = s32a_g_r_`j'*5 if s32_ranked_list_r_`j' == "`i'"			// Need to change this back to "2"
				replace prej_thermo`i' = . if date_txt == "date2020-11-13" 
				replace prej_thermo`i' = . if prej_thermo`i' < 0
			}
		lab var prej_thermo`i' "How do you feel towards X"
	}
		rename prej_thermo1 		prej_thermo_city			
		rename prej_thermo2			prej_thermo_chinese
		rename prej_thermo3			prej_thermo_muslims
		rename prej_thermo4			prej_thermo_christians	
		rename prej_thermo5			prej_thermo_sambaa
			replace prej_thermo_sambaa = s32b_g_r if tribe_txt == "Wasambaa" & prej_thermo_sambaa == .
		rename prej_thermo6			prej_thermo_digo
			replace prej_thermo_digo = s32b_g_r if tribe_txt == "Wadigo" & prej_thermo_sambaa == .
		rename prej_thermo7			prej_thermo_kenyan

		foreach var of varlist prej_thermo_* {
			cap recode `var' (-999 = .d)(-888 = .r)(-4995 = .d)
		}	

		gen prej_thermo_out_rel = prej_thermo_muslims if resp_muslim == 0
			replace prej_thermo_out_rel = prej_thermo_christians if resp_muslim == 1
		
		gen prej_thermo_out_eth = prej_thermo_digo if resp_tribe != 38
			replace prej_thermo_out_eth = prej_thermo_sambaa if resp_tribe == 38
		

/* Political Prefences __________________________________________________________*/

	forval i = 1/9 {
		gen ptixpref_rank_`i' = .
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

	rename s14q2_oth		ptixpref_other
	 
	rename s14q3  ptixpref_local_approve				
		recode ptixpref_local_approve (1 = 0) (0 = 1)
		lab def gov_approval 0 "Don't Approve" 1 "Approve"
		lab val ptixpref_local_approve gov_approval

	rename s14q4  ptixpref_responsibility				
		
	foreach var of varlist ptixpref_* {
		cap recode `var' (-999 = .d)(-888 = .r)(-4995 = .d)
	}

	
/* Gender Equality _____________________________________________________________

	Notes: 
	-- We are coding that higher is always "more gender equality"

*/

	rename s3q12				ge_kids_idealnum
	rename s3q13				ge_kids_idealage

	foreach var of varlist ge_kids_idealnum ge_kids_idealage {

		recode `var' (-999 = .d)(-888 = .r)
	}


	forval i = 1/10 {
		gen ge_`i' = .
			forval j = 1/6 {
				replace ge_`i' = s6q_r_`j' if s6_qn_sel_r_`j' == "`i'"
			}
	}

		rename ge_1			ge_raisekids
			recode ge_raisekids (1=1)(2=0)
		rename ge_2			ge_earning												// Reversed
			recode ge_earning (1=0)(2=1) 					
		rename ge_3			ge_school					
			recode ge_school (1=0)(2=1) 			
		rename ge_4 		ge_work													// Reversed
			recode ge_work (1=0)(2=1)
		rename ge_5			ge_leadership
			recode ge_leadership (1=1)(2=0)						
		rename ge_6			ge_business
			recode ge_business (1=1)(2=0)
		rename ge_7			ge_autonomy												// Reversed
			recode ge_autonomy (1=0)(2=1)	
		rename ge_8			ge_adultery
			recode ge_adultery (1=1)(2=0)
		cap rename ge_9		ge_womanleave
			cap recode ge_womanleave (1=1)(2=0)
		cap rename ge_10	ge_womanspend											// Reversed
			cap recode ge_womanspend (1=0)(2=1)

	lab val ge_raisekids agree
	lab val ge_earning agree
	lab val ge_school agree				
	lab val ge_work agree	
	lab val ge_leadership agree			
	lab val ge_business agree	
	lab val ge_autonomy agree	
	lab val ge_adultery agree	
	lab val ge_womanleave agree
	lab val ge_womanspend agree

	lab var ge_raisekids "A husband and wife should share equally in raising children."
	lab var ge_earning "[REVERSED] If a woman earns more money than her husband, it’s almost certain to cause problems"
	lab var ge_school "[REVERSED] It is more important that a boy goes to school than a girl"
	lab var ge_work "[REVERSED] When jobs are scarce, men should have more right to a job than women"
	lab var ge_leadership "In general, women make equally good village leaders as men"
	lab var ge_business "In general, women are just as able to run a successful business as men"
	lab var ge_autonomy "[REVERSED] When a woman goes out to see a friend or neighbor, she should ask her husband for permission"
	lab var ge_adultery "A wife is right to punish her husband if he brings home another woman."
	cap lab var ge_womanleave "A woman should be able to leave her husband if he mistreats her"
	cap lab var ge_womanspend "[REVERSED] Even if a woman has her own money, she should tell her husband before she spends it"

	foreach var of varlist ge_* {
		recode `var' (-999 = .d) (-888 = .r)
	}
	
	egen ge_index = rowmean(ge_raisekids ge_earning ge_school ge_work ge_leadership ge_business ge_autonomy ge_adultery ge_womanleave ge_womanspend)

	

/* Forced Marriage _____________________________________________________________*/

	rename s8q1			fm_reject
		recode fm_reject (1=0)(2=1)(-999 = .d)(-888 = .r)
		lab var fm_reject "[REVERSED] A woman should not have a say in who she marries"
		lab val fm_reject agree
		
	gen fm_reject_long = .
		replace fm_reject_long = 0 if s8q1a == 2
		replace fm_reject_long = 1 if s8q1a == 1
		replace fm_reject_long = 2 if s8q1b == 1
		replace fm_reject_long = 3 if s8q1b == 2
		lab def fm_reject_long 	0 "Strong Agree" ///
								1 "Agree" ///
								2 "Disagree" ///
								3 "Strongly Disagree"
		lab val fm_reject_long fm_reject_long
		lab var fm_reject_long "[REVERSED, LONG] A woman shoudl not have a say in who she marries"



/* Political Participation ______________________________________________________*/

	/* Generate Interest */
	rename s15q1	ptixpart_interest
		recode ptixpart_interest (1=3)(2=2)(3=1)(4=0)
		lab val ptixpart_interest interest
	
	** Participation Activities														
	forval i = 1/12 {
		gen ptixpart_activ_`i' = .
			forval j = 1/4 {	
				replace ptixpart_activ_`i' = s15q2_r_`j' if s15q2_rand_rank_r_`j' == "`i'"
			}
	}
		rename ptixpart_activ_1 		ptixpart_activ_voteregister					
		rename ptixpart_activ_2			ptixpart_activ_votenatl	
		rename ptixpart_activ_3 		ptixpart_activ_votelocal
		rename ptixpart_activ_4			ptixpart_activ_votetalk
		rename ptixpart_activ_5 		ptixpart_activ_workparty
		rename ptixpart_activ_6			ptixpart_activ_rally 
		rename ptixpart_activ_7			ptixpart_activ_villmeet_share
		rename ptixpart_activ_8			ptixpart_activ_villmeet
		rename ptixpart_activ_9			ptixpart_activ_wardmeet
		rename ptixpart_activ_10		ptixpart_activ_talknatlgov
		rename ptixpart_activ_11		ptixpart_activ_collact
		rename ptixpart_activ_12		ptixpart_activ_creategroup

		lab val ptixpart_activ_* yesno
		
	egen ptixpart_villmeet = rowmean(ptixpart_activ_villmeet ptixpart_activ_wardmeet)
	egen ptixpart_vote = rowmean(ptixpart_activ_votenatl ptixpart_activ_votelocal)
	egen ptixpart_collact = rowmax(ptixpart_activ_collact ptixpart_activ_creategroup)
		
	cap rename s15q7						ptixpart_contact_satisfied

	egen ptixpart_index = rowmean(ptixpart_activ_*)

	
/* Political Knowledge _________________________________________________________*/

	* Popular Culture
	destring s13q1, replace
	destring s13q1_rand_cl, replace
	gen ptixknow_pop_music = .
		replace ptixknow_pop_music = 1 if 	(s13q1 == 4 | s13q1 == 3) & ///
											s13q1_rand_cl == 1
		replace ptixknow_pop_music = 0 if 	(s13q1 == 5 | s13q1 == -999) & ///
											s13q1_rand_cl == 1
		replace ptixknow_pop_music = .e if 	(s13q1 == 1 | s13q1 == 2) & ///
											s13q1_rand_cl == 1
											
		lab val ptixknow_pop_music correct
										
	gen ptixknow_pop_sport = .
		replace ptixknow_pop_sport = 1 if 	(s13q1 == 1) & ///
											s13q1_rand_cl == 2
		replace ptixknow_pop_sport = 0 if 	(s13q1 == 2 | s13q1 == -999) & ///
											s13q1_rand_cl == 2
		replace ptixknow_pop_sport = .e if 	(s13q1 == 3 | s13q1 == 4) & ///
											s13q1_rand_cl == 2
		
		lab val ptixknow_pop_sport correct
											
	* Local Politics
	rename s13q2 	ptixknow_local_dc 

	* National Politics
	gen ptixknow_natl_justice = s13q3 if s13q3_txt == "Ibrahim Hamis Juma"
		recode ptixknow_natl_justice (4=1)(1=0)(2=0)(3=0)(-999=0)
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
		
	rename s13q5		ptixknow_em_aware

	rename s13q6		ptixknow_sourcetrust
	
	gen ptixknow_trustloc = 1 if ptixknow_sourcetrust == 1
	replace ptixknow_trustloc = 0 if ptixknow_sourcetrust == 2 | ptixknow_sourcetrust == 3
	
	gen ptixknow_trustnat = 1 if ptixknow_sourcetrust == 2
		replace ptixknow_trustnat = 0 if ptixknow_sourcetrust == 1 | ptixknow_sourcetrust == 3
		
	gen ptixknow_trustrel = 1 if ptixknow_sourcetrust == 3
		replace ptixknow_trustrel = 0 if ptixknow_sourcetrust == 1 | ptixknow_sourcetrust == 2
	
	foreach var of varlist ptixknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)
	}

	drop political_participation_*
	egen ptixknow_index = rowmean(ptixknow_pop_music ptixknow_pop_sport ptixknow_natl_justice ptixknow_natl_pm ptixknow_natl_vp ptixknow_fopo_trump ptixknow_fopo_biden ptixknow_fopo_kenyatta)


/* Women's Political Participation _____________________________________________

	Note: This is also an experiment
	
*/

	rename s21_txt_treat treat_wpp

	rename s21q1	wpp_attitude

		gen wpp_attitude_dum = 1 if wpp_attitude == 1 | wpp_attitude == 2
		replace wpp_attitude_dum = 0 if wpp_attitude == 0
		lab var wpp_attitude_dum "Who should lead? Equal women or more women"
		
	rename s21q2	wpp_norm

		gen wpp_norm_dum = 1 if wpp_norm == 1 | wpp_norm == 2
		replace wpp_norm_dum = 0 if wpp_norm == 0
		lab var wpp_norm_dum "Who should lead? Equal women or more women"
		
	rename s21q3	wpp_behavior
	rename s21q4	wpp_nomalehhh
		recode wpp_nomalehhh (0=1)(1=0)
		lab var wpp_nomalehhh "[Reversed]: Agree or Disagree: A man should have final say in HH"

	foreach var of varlist wpp_* {
		recode `var' (-888 = .r) (-999 = .d) (-222 = .d)
	}


/* Early Marriage ______________________________________________________________

	Note: This is also an experiment on pluralistitic ignorance
	
*/

	rename s17q1	em_bestage
		recode em_bestage (-888 = .r) (-999 = .d)

	gen em_past18 = (em_bestage >= 18)
		replace em_past18 = . if em_bestage == .
		lab var em_past18 "[After 18] What do you think is the best age for a girl to get married"
		
	rename s17q4 	em_allow

	gen em_reject = 1 if em_allow == 2
		replace em_reject = 0 if em_allow == 1 | em_allow == 3

	rename s17q9		em_norm_reject
		recode em_norm_reject (0=0)(1=2)(2=1)
		lab val em_norm_reject em_norm_reject
		lab var em_norm_reject "Community Rejects Early Marraige"
		
	clonevar em_norm_reject_dum = em_norm_reject
		recode em_norm_reject_dum (2=1)(1=0)(0=0)
		lab val em_norm_reject_dum reject
		lab var em_norm_reject_dum "(Dummy) Community rejects early marriage"
		
	gen treat_pi = 1 if em_txt_treat == "treat"
		replace treat_pi = 0 if em_txt_treat == "control"
		lab val treat_pi treatment
		lab var treat_pi "Pluralistic Ignorance Treatment"

	rename s17q6			em_expected

	rename s17q8a		em_reject_religion
	rename s17q8b		em_reject_noschool
	rename s17q8c		em_reject_pregnant
	rename s17q8d		em_reject_money
	rename s17q8e		em_reject_needhus

	foreach var of varlist em_reject_* {
		recode `var' (3=0)(1=1)(2=2)
		lab val `var' reject_cat
		gen `var'_dum = (`var' == 2)
		lab val `var'_dum yesno
	}

	egen em_reject_index = 	rowmean(em_reject_religion_dum ///
									em_reject_noschool_dum ///
									em_reject_pregnant_dum ///
									em_reject_money_dum ///
									em_reject_needhus_dum)
									
	gen em_reject_all = (em_reject_index == 1)

	rename s17q7		em_record_any

	rename s17q13 		em_record_reject
		replace em_record_reject = 0 if em_record_any == 0

	gen em_record_accept = 1 if em_record_reject == 0 & em_record_any == 1
		replace em_record_accept = 0 if em_record_any == 0
		
	rename s17q10		em_record_name
		replace em_record_name = 0 if em_record_reject != 1
		replace em_record_name = 0 if em_record_any == 0
		
	** Share Politics
	rename s17q11		em_record_shareptix	
		replace em_record_shareptix = 0 if em_record_reject != 1 & record_rand_draw == "gov"
		replace em_record_shareptix = 0 if em_record_any == 0 & record_rand_draw == "gov"
		
	gen em_record_shareptix_name = em_record_shareptix
		replace em_record_shareptix_name = 0 if em_record_name == 0 & record_rand_draw == "gov"

	** Share Pangani FM
	rename s17q12		em_record_sharepfm
		replace em_record_sharepfm = 0 if em_record_reject != 1 & record_rand_draw == "pfm"
		replace em_record_sharepfm = 0 if em_record_any == 0 & record_rand_draw == "pfm"
		
	gen em_record_sharepfm_name = em_record_sharepfm 
		replace em_record_sharepfm_name = 0 if em_record_name == 0 & record_rand_draw == "pfm"
		
	** Share Any 
	gen em_record_shareany = em_record_sharepfm 
		replace em_record_shareany = em_record_shareptix if record_rand_draw == "gov"

	gen em_record_shareany_name = em_record_sharepfm_name
		replace em_record_shareany_name = em_record_shareptix_name if record_rand_draw == "gov"
		
	foreach var of varlist em_reject_* em_record_*  {
		recode `var' (-999 = .d) (-888 = .r)
	}	

	
/* Health Knowledge ____________________________________________________________*/

	rename s23q1		healthknow_notradmed
		recode healthknow_notradmed (0=1)(1=0)									// Check on translation
		lab var healthknow_notradmed "[Reversed] Prayer and traditional medicine can help cure disease"
	rename s23q2		healthknow_vaccines
	rename s23q3		healthknow_vaccines_imp
		replace healthknow_vaccines_imp = 0 if healthknow_vaccines == 0
	rename s23q4		healthknow_nowitchcraft
		recode healthknow_nowitchcraft (0=1)(1=0)
		lab var healthknow_nowitchcraft "[Reversed] Believe in witchcraft?"

	foreach var of varlist healthknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)(-888 = .r)
	}


/* Intimate Partner Violence __________________________________________________*/

* Reject IPV																
	rename s9q1a		ipv_rej_disobey
		recode ipv_rej_disobey (0=1)(1=0)(-999 = .d)(-888 = .r)	
		lab val 		ipv_rej_disobey ipv
		
	rename s9q1b		ipv_rej_hithard
		recode ipv_rej_hithard (2=0)(1=1)(-999 = .d)(-888 = .r)	
		replace ipv_rej_hithard = 1 if ipv_rej_disobey == 1
		lab val 		ipv_rej_hithard ipv
		
	rename s9q1c		ipv_rej_persists
		recode ipv_rej_persists (0 = 1)(1 = 0)(-999 = .d)(-888 = .r)	
		replace ipv_rej_persists = 0 if ipv_rej_disobey == 0
		lab val ipv_rej_persists ipv
		
	gen fixed = 1

	rename s9q2 			ipv_norm_rej
		recode ipv_norm_rej (1=0)(0=1)(-999 = .d)(-888 = .r)	
		lab val ipv_norm_rej ipv
		

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

	foreach ipv of varlist ipv_rej_cheats ipv_rej_kids ipv_rej_work ipv_rej_gossip ipv_rej_elders {
		replace `ipv' = .d if `ipv' == -999
		replace `ipv' = .r if `ipv' == -888
		recode `ipv' (1=0)(0=1)
		lab val `ipv' reject	
	}

	egen ipv_rej_index 	= rowmean(ipv_rej_cheats ipv_rej_kids ipv_rej_work ipv_rej_gossip ipv_rej_elders)
	egen ipv_rej_all	= rowmax(ipv_rej_disobey ipv_rej_cheats ipv_rej_kids ipv_rej_work ipv_rej_gossip ipv_rej_elders)
		lab val ipv_rej_all yesno

	* IPV Report
	rename s9q3a		ipv_report_police
		recode ipv_report_police (2=1)(1=0)
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
		
	egen ipv_report_index = rowmean(ipv_report_police ipv_report_vc ipv_report_parents ipv_report_femleader)

	drop s9q4 s9q5	// We dropped these variables after one day to save sapce									


/* HH Labor _____________________________________________________________________*/

	** People you would live near
	forval i = 1/4 {
		gen couples_labor_`i' = .
			forval j = 1/2 {	
				replace couples_labor_`i' = s12q1_r_`j' if s12q1_ranked_list_r_`j' == "`i'"
			}
	}
		
	/* Generate Dummy Variable for Outcome */
	recode couples_labor_1 	(2 3 4 6 = 1 "Equal/Progressive") ///
							(1 5 = 0 "Conservative"), ///
							gen(hhlabor_water_dum) 
			lab var hhlabor_water_dum "[1 = prog/bal] Who in HH is responsible for water?"
	
	recode couples_labor_2 	(2 3 4 6 = 1 "Equal/Progressive") ///
							(1 5 = 0 "Conservative"), ///
							gen(hhlabor_laundry_dum) 
		lab var hhlabor_laundry_dum "[1 = prog/bal] Who in HH is responsible for laundry?"
		
	egen hhlabor_chores_dum = rowmean(hhlabor_water hhlabor_laundry)
		lab val hhlabor_chores_dum hh_dum
		lab var hhlabor_chores_dum "[1 = prog/bal] Who in HH is responsible for laundry?"
	
	recode couples_labor_3 	(2 3 4 6 = 1 "Equal/Progressive") ///
							(1 5 = 0 "Conservative"), ///
							gen(hhlabor_kids_dum) 
		lab var hhlabor_kids_dum "[1 = prog/bal] Who in HH is responsible for kids?"
	
	recode couples_labor_4 	(1 3 5 6 = 1 "Equal/Progressive") ///
							(2 4 = 0 "Conservative"), ///
							gen(hhlabor_money_dum) 
		lab var hhlabor_money_dum "[1 = prog/bal] Who in HH is responsible for money?"
	
	recode hhlabor* (-999 = .d)(-888 = .r)	
	
	egen hhlabor_index = rowmean(hhlabor_water_dum hhlabor_laundry_dum hhlabor_kids_dum hhlabor_money_dum)

	
/* HH Decisions _____________________________________________________________________*/
		
	gen hhdecision_school = s12q12b if s12q2_txt_eng == "children’s education"
	gen hhdecision_hhfix = s12q12b if s12q2_txt_eng == "household repairs"
		
	recode hhdecision_school (2=1)(3=1)(1=0)(4=1)(5=0), gen(hhdecision_school_dum)
		lab val hhdecision_school_dum hh_dum
		lab var hhdecision_school_dum "[1 = progressive/balanced] Who in HH makes decisions about school?"
		
	recode hhdecision_hhfix (2=1)(3=1)(1=0)(4=1)(5=0), gen(hhdecision_hhfix_dum)
		lab val hhdecision_hhfix_dum hh_dum
		lab var hhdecision_hhfix_dum "[1 = progressive/balanced] Who in HH makes decisions about hh fixes?"
		
	recode hhdecision_school hhdecision_hhfix (-999 = .d)(-888 = .r)
	
	egen hhdecision_index = rowtotal(hhdecision_school_dum hhdecision_hhfix)
		lab var hhdecision_index "Index of two hhdecision questions"
	
	
/* Relationships _______________________________________________________________*/

	rename s12q13a					couples_support
	recode s12q13b					(0 = 1 "Doesn't insult") ///
									(1 = 0 "Does insult"), ///
									gen(couples_noinsult)
									lab var couples_noinsult "[1 = no insult] Does Husband ever make you feel bad about yourself / insult you?"
	
	recode s12q13c					(0 = 1 "Doesn't prevent") ///
									(1 = 0 "Does prevent"), ///
									gen(couples_stopleave)
									lab var couples_stopleave "[1 = no prevent] Does Husband ever prevent you from leaving the house?"

	recode s12q14a					(1 = 1 "can depend") ///
									(2 = 0 "cant depend"), ///
									gen(couples_crutch)
									lab var couples_crutch "[1 = can depend] Can you depend on this person in a time of need?"
									
	recode s12q14b					(1 = 1 "can depend") ///
									(2 = 0 "cant depend"), ///
									gen(couples_depend)
									lab var couples_depend "[1 = can depend] Find it easy to depend on this person?"
									
	recode s12q14c					(1 = 1 "can be open") ///
									(2 = 0 "cant be open"), ///
									gen(couples_open)
									lab var couples_open "[1 = can be open] Do you feel comfortable being open with your partner?"
									
	recode s12q14d					(1 = 1 "not unfaithful") ///
									(2 = 0 "is unfaithful"), ///
									gen(couples_nocheat)
									lab var couples_nocheat "[1 = not unfaithful] Do you worry your partner is unfaithful?"

	rename s12q15					couples_marriagerating
	
	recode couples_marriagerating	(1 2 3 = 1 "Satisfied") ///
									(4 5 = 0 "Not satisfied"), ///
									gen(couples_satisfied)
									lab var couples_satisfied "[1 = satisfied] How satisfied are you with your marriage?"

	foreach var of varlist couples_* {
		recode `var' (-888 = .r) (-999 = .d)
	}
	
	egen couples_depend_index = rowmean(couples_crutch couples_depend)
		lab var couples_depend_index "Index of two synonimous measures of couple strength"
		
	egen couples_index = rowmean(couples_noinsult couples_stopleave couples_depend_index couples_open couples_nocheat)
		lab var couples_index "Average of five measures of relationships"


/* Parenting ___________________________________________________________________*/

	rename s11q1		parent_currentevents

	recode s11q3		(2 = 1 "Disagree") ///
						(1 = 0 "Agree"), ///
						gen(parent_question)
						lab var parent_question "[disagree = 1] Parents should not allow children to quesiton their decisions"
		

/* Violence Against Children ___________________________________________________

	Note: as with IPV and GE, attitudes are always towards REJECTING 
	violence / hierarchy, but behaviors are currently just yes/no commited the act
	
*/

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
		
	** VAC Behaviors
	rename s10q6_sm_2	vac_nopunish_shout
		lab var vac_nopunish_shout "[1 = No] Have you shouted at children in last month?"
		
	rename s10q6_sm_3	vac_nopunish_hithand
		lab var vac_nopunish_hithand "[1 = No] Have you hit children with hand in last month?"
		
	rename s10q6_sm_4		vac_nopunish_hitobj
		lab var vac_nopunish_hitobj "[1 = No] Have you hit children with stick or object in last month?"

	/* Reverse coding */
	foreach var of varlist vac_nopunish_* {
		recode `var' (1=0)(0=1)
		lab val `var' yesno_rev
	}
	
	egen vac_nopunish_index = rowmean(vac_nopunish_hithand vac_nopunish_hitobj)
		
	
/* Media Consumption ___________________________________________________________*/
	rename s4q2_listen_radio	radio_listen							
		lab def s4q2_listen_radio 0 "Never", modify
		lab val radio_listen s4q2_listen_radio
		
	rename s4q2b_listen_radio_time	radio_listen_hrs
		replace radio_listen_hrs = 0 if radio_listen == 0
		
	rename s4q3_radio_3month	radio_ever
		replace radio_ever = 1 if 	radio_listen == 1 | ///
									radio_listen == 2 | ///
									radio_listen == 3 | ///
									radio_listen == 4 | ///
									radio_listen == 5
		recode radio_ever (-999 = .d) (-888 = .r)

	* Favorite Radio Program Types
	rename s4q5_programs_sm				radio_type	
		rename s4q5_programs_sm_1		radio_type_music
		rename s4q5_programs_sm_2		radio_type_sports
		rename s4q5_programs_sm_3		radio_type_news
		rename s4q5_programs_sm_4		radio_type_rltnship
		rename s4q5_programs_sm_5		radio_type_social
		rename s4q5_programs_sm_6		radio_type_relig
	lab val radio_type_* yesnolisten

	foreach var of varlist radio_type_* {
		replace `var' = 0 if radio_ever == 0
	}

	* Favorite Radio Stations
	rename s4q6_listen_sm				radio_stations
		rename s4q6_listen_sm_1			radio_stations_voa
		rename s4q6_listen_sm_2			radio_stations_tbc
		rename s4q6_listen_sm_3			radio_stations_efm
		rename s4q6_listen_sm_4			radio_stations_breeze
		rename s4q6_listen_sm_5			radio_stations_pfm
		rename s4q6_listen_sm_6			radio_stations_clouds
		rename s4q6_listen_sm_7			radio_stations_rmaria
		rename s4q6_listen_sm_8			radio_stations_rone
		rename s4q6_listen_sm_9			radio_stations_huruma
		rename s4q6_listen_sm_10		radio_stations_mwambao
		rename s4q6_listen_sm_11		radio_stations_wasafi
		rename s4q6_listen_sm_12		radio_stations_nuru
		rename s4q6_listen_sm_13		radio_stations_uhuru
		rename s4q6_listen_sm_14		radio_stations_bbc
		rename s4q6_listen_sm_15		radio_stations_sya
		rename s4q6_listen_sm_16		radio_stations_tk
		rename s4q6_listen_sm_17		radio_stations_kenya
		rename s4q6_listen_sm_18		radio_stations_imani
		rename s4q6_listen_sm_19		radio_stations_freeafrica
		rename s4q6_listen_sm_20		radio_stations_abood
		rename s4q6_listen_sm_21		radio_stations_uhurudar
		rename s4q6_listen_sm_22		radio_stations_upendo
		rename s4q6_listen_sm_23		radio_stations_kiss
		rename s4q6_listen_sm_24		radio_stations_times
	lab val radio_stations_* yesnolisten
		
		foreach var of varlist radio_stations_* {
			
			replace `var' = 0 if radio_ever == 0
		}
		
	egen radio_stations_nonpfm = rowmean(radio_stations_voa radio_stations_tbc ///
										  radio_stations_rone radio_stations_uhuru ///
										  radio_stations_tk)

	rename s4q3b_radio_group_often				radio_group

	rename s4q3c_radio_group_who_sm				radio_group_who
		rename s4q3c_radio_group_who_sm_1		radio_group_who_self
		rename s4q3c_radio_group_who_sm_2		radio_group_who_spouse
		rename s4q3c_radio_group_who_sm_3		radio_group_who_kids
		rename s4q3c_radio_group_who_sm_4		radio_group_who_fam
		rename s4q3c_radio_group_who_sm_5		radio_group_who_friends
		rename s4q3c_radio_group_who_sm_6		radio_group_who_coworkers

		foreach var of varlist radio_group_who_* {
			replace `var' = 0 if radio_group == 0
			replace `var' = 0 if radio_ever == 0
		}
		
	rename s4qd_radio_when						radio_when
		rename s4qd_radio_when_1				radio_when_morning
		rename s4qd_radio_when_2				radio_when_afternoon
		rename s4qd_radio_when_3				radio_when_evening
		rename s4qd_radio_when_4				radio_when_night
		
		drop radio_when
		
		foreach var of varlist radio_when_* {
			replace `var' = 0 if radio_ever == 0 
		}

	** Pangani FM	
	rename s4q7a_				radio_uhuru
	
	drop radio_pfm
	rename s4q7_panganifm 		radio_pfm
		replace radio_pfm = 1 if radio_stations_pfm == 1
		replace radio_pfm = 0 if radio_ever == 0
		
		replace radio_uhuru = 1 if radio_stations_uhuru == 1
		replace radio_uhuru = 0 if radio_ever == 0

	** Pangani FM Shows																
	rename s4q8_programs_sm 			radio_pfm_shows
		rename s4q8_programs_sm_1		radio_pfm_shows_couples
		rename s4q8_programs_sm_2		radio_pfm_shows_soap
		rename s4q8_programs_sm_3		radio_pfm_shows_leaders
		rename s4q8_programs_sm_4		radio_pfm_shows_women
		rename s4q8_programs_sm_5		radio_pfm_shows_youth
	lab val radio_pfm_shows_* listen
	
	foreach var of varlist radio_pfm_shows_* {
		replace `var' = 0 if  radio_pfm == 0
	}
	
	rename s4q9_callpfm							radio_pfm_call

	** Call into PFM Shows	
		rename  s4q9b_callpfm_programs_1 		radio_pfm_call_couples
		rename  s4q9b_callpfm_programs_2		radio_pfm_call_soap
		rename  s4q9b_callpfm_programs_3 		radio_pfm_call_leaders
		rename  s4q9b_callpfm_programs_4		radio_pfm_call_women
		rename  s4q9b_callpfm_programs_5		radio_pfm_call_youth

	** News
	rename s4q10_news 				radio_news
		
	** Call 																		
	rename s4q10_radio_show			radio_call

	** Reports
	rename s4q11_vill_report		radio_villreport	
	rename s4q12_ward_leader		radio_locleader
	rename s4q13_ntl_leader			radio_natleader		
	
	** Add in supplment															// we conducted a follow up bc of a coding error that meant pfm programs question was not asked to some respondents
	rename Umeshawahikusikilizakipindich supp_pfm_programs
	rename JeUmewahikupigasimuPangani supp_pfm_call 
	rename NikipindiganikwenyePanganiF supp_pfm_call_program	
	
	replace radio_pfm_shows = supp_pfm_programs if radio_pfm_shows == ""
	replace radio_pfm_shows_couples = 1 if strpos(supp_pfm_programs, "1")>0
	replace radio_pfm_shows_soap = 1 if strpos(supp_pfm_programs, "2")>0
	replace radio_pfm_shows_leaders = 1 if strpos(supp_pfm_programs, "3")>0
	replace radio_pfm_shows_women = 1 if strpos(supp_pfm_programs, "4")>0
	replace radio_pfm_shows_youth = 1 if strpos(supp_pfm_programs, "5")>0

	replace radio_pfm_call = 1 if supp_pfm_call == "Yes"
		replace radio_pfm_call = 0 if supp_pfm_call == "No"
	
	replace radio_pfm_call_couples = 1 if strpos(supp_pfm_call_program, "1")>0
	replace radio_pfm_call_soap = 1 if strpos(supp_pfm_call_program, "2")>0
	replace radio_pfm_call_leaders = 1 if strpos(supp_pfm_call_program, "3")>0
	replace radio_pfm_call_women = 1 if strpos(supp_pfm_call_program, "4")>0
	replace radio_pfm_call_youth = 1 if strpos(supp_pfm_call_program, "4")>0

/* Assetts _____________________________________________________________________*/

	rename s16q1		asset_radio
	rename s16q2		asset_radio_num
		replace asset_radio_num = 0 if asset_radio == 0
	rename s16q3		asset_tv
	rename s16q5		asset_cell
	rename s16q6		asset_cell_internet
		replace asset_cell_internet = 0 if asset_cell == 0												// If don't have cell, don't have internet
	rename s16q7		asset_rooftype

		foreach var of varlist asset_* {
			recode `var' (-888 = .r)(-999 = .d)
		}

		
/* Radio Distribution Compliance _______________________________________________*/

	rename treat_rd_pull treat_rd_pull 

	rename s30q1		rd_receive
	rename s30q2		rd_stillhave
	rename s30q3		rd_stillhave_whyno
	rename s30q4		rd_stillhave_show
	rename s30q5		rd_working
	rename s30q6		rd_working_whynot

	rename s30q7		rd_uses
		rename s30q7_1 rd_uses_self
		rename s30q7_2 rd_uses_spouse
		rename s30q7_3 rd_uses_child
		rename s30q7_4 rd_uses_othfam
		rename s30q7_5 rd_uses_friends
		rename s30q7_6 rd_uses_cowork
		
		foreach var of varlist rd_uses_* {
			lab val `var' yesno
		}
		
	rename s30q8		rd_controls
	rename s30q9		rd_problems
	rename s30q10		rd_challenge
		rename s30q10_1 	rd_challenge_jealous
		rename s30q10_2 	rd_challenge_mistrust
		rename s30q10_3		rd_challenge_fight
		rename s30q10_oth	rd_challenge_oth
		

/* Conclusion __________________________________________________________________*/

	rename s20q1				svy_followupok

	rename s20q2latitude		svy_gps_lat
	rename s20q2longitude		svy_gps_long		

	rename s20q3				svy_others
	rename s20q4_sm				svy_others_who

	
qui ds, has(type numeric)
recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)
		
/* Export __________________________________________________________________*/

	save "${data}/02_mid_data/pfm_ne_endline_clean.dta", replace


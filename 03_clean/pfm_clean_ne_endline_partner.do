	
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

	use "${data}/01_raw_data/03_surveys/pfm_rawpii_ne_partner_endline.dta", clear
	

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
	lab def vac_reject  1 "Children must never be beaten" 0 "Hitting a child is sometimes justified"


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

	rename s3q15_city_town		resp_urbanvisit
		recode resp_urbanvisit (-999 = .d)

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

	rename s5q4				values_dontquestion
		lab def values_dontquestion 0 "Question leaders" 1 "Respect authority"
		lab val values_dontquestion values_dontquestion
		
	rename s5q6				values_urbangood
		recode values_urbangood (-999 = .d) (-888 = .r) (1 = 0) (0 = 1)
		lab def values_urbangood 1 "Good to go to town" 0 "Support the family"
		lab val values_urbangood values_urbangood
		
	rename s3q20_tz_tribe		values_tzovertribe
		gen values_tzovertribe_dum = (values_tzovertribe == 1 | values_tzovertribe == 2)
		replace values_tzovertribe_dum = . if values_tzovertribe == -888 | values_tzovertribe == .
		lab val values_tzovertribe_dum tzovertribe

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
		lab var prej_thermo`i' "How do you feel towards X"
	}
		rename prej_thermo1 		prej_thermo_city			
		rename prej_thermo2			prej_thermo_chinese
		rename prej_thermo3			prej_thermo_muslims
		rename prej_thermo4			prej_thermo_christians	
		rename prej_thermo5			prej_thermo_sambaa
			*replace prej_thermo_sambaa = s32b_g_r if tribe_txt == "Wasambaa" & prej_thermo_sambaa == .
		rename prej_thermo6			prej_thermo_digo
			*replace prej_thermo_digo = s32b_g_r if tribe_txt == "Wadigo" & prej_thermo_sambaa == .
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
		gen ptixpref_resp_locgov = ptixpref_responsibility ==  2
		gen ptixpref_resp_natgov = ptixpref_responsibility ==  3 | ptixpref_responsibility ==  4
		gen ptixpref_resp_vill = ptixpref_responsibility ==  1 

		
	foreach var of varlist ptixpref_* {
		cap recode `var' (-999 = .d)(-888 = .r)(-4995 = .d)
	}

	
/* Gender Equality _____________________________________________________________

	Notes: 
	-- We are coding that higher is always "more gender equality"

*/

	rename s3q12				ge_kids_idealnum
	rename s2q21				ge_kids_idealage

	foreach var of varlist ge_kids_idealnum ge_kids_idealage {

		recode `var' (-999 = .d)(-888 = .r)
	}


	rename s6q1			ge_school	
		recode ge_school (1=0)(2=1) 	
	rename s6q2			ge_work
		recode ge_work (1=0)(2=1)
	rename s6q3			ge_leadership
		recode ge_leadership (1=1)(2=0)		
	rename s6q4			ge_business
		recode ge_business (1=1)(2=0)

	lab val ge_school agree				
	lab val ge_work agree	
	lab val ge_leadership agree			
	lab val ge_business agree	

	lab var ge_school "[REVERSED] It is more important that a boy goes to school than a girl"
	lab var ge_work "[REVERSED] When jobs are scarce, men should have more right to a job than women"
	lab var ge_leadership "In general, women make equally good village leaders as men"
	lab var ge_business "In general, women are just as able to run a successful business as men"
		
	recode ge_* (-999 = .d) (-888 = .r)

	egen ge_index = rowmean(ge_school ge_work ge_leadership ge_business)

	/* Household Labor - Ideal */
	
	forval i = 1/3 {
		gen ge_hhlabor`i' = .
			forval j = 1/3 {	
				replace ge_hhlabor`i' = s8q5_r_`j' if s8q5_index_r_`j' == "`i'"		// Need to change this back to "2"
			}
		lab var ge_hhlabor`i' "How is ideally responsible for X?"
		lab val ge_hhlabor`i' ge_hhlabor
	}
	
		rename ge_hhlabor1 		ge_hhlabor_chores									// Not sure this is coded right
		rename ge_hhlabor2		ge_hhlabor_kids
		rename ge_hhlabor3		ge_hhlabor_money
		
		/* Create dummies in progressive direction */
		foreach var of varlist ge_hhlabor_chores ge_hhlabor_kids {				// create dummy = 1 if shoudl share labor
			recode `var' 	(2 3 = 1 "men/balance") ///
							(1 = 0 "women"), ///
							gen(`var'_dum) lab(`var'_dum)
			lab var `var'_dum "1=prog/bal : Ideally, who is responsible for..."
		}
		
		foreach var of varlist ge_hhlabor_money {								// create dummy = 1 if shoudl share labor
			recode `var' 	(1 3 = 1 "women/balance") ///
							(2 = 0 "men"), ///
							gen(`var'_dum) label(`var'_dum)
			lab var `var'_dum "1=prog/bal : Ideally, who is responsible for..."
		}


/* Forced Marriage _____________________________________________________________*/

	rename s8q5			fm_reject
		recode fm_reject (1=0)(2=1)(-999 = .d)(-888 = .r)
		lab var fm_reject "[REVERSED] A woman should not have a say in who she marries"
		lab val fm_reject agree
		
	gen fm_reject_long = .
		replace fm_reject_long = 0 if s8q5a == 2
		replace fm_reject_long = 1 if s8q5a == 1
		replace fm_reject_long = 2 if s8q5b == 1
		replace fm_reject_long = 3 if s8q5b == 2
		lab def fm_reject_long 	0 "Strong Agree" ///
								1 "Agree" ///
								2 "Disagree" ///
								3 "Strongly Disagree"
		lab val fm_reject_long fm_reject_long
		lab var fm_reject_long "[REVERSED, LONG] A woman shoudl not have a say in who she marries"

	rename s8q5_partner	fm_partner_reject
		lab val fm_partner_reject reject

	rename s8q5_comm	fm_norm_reject
		lab val fm_norm_reject reject
					

/* Political Participation ______________________________________________________*/

	/* Generate Interest */
	rename s15q1	ptixpart_interest
		recode ptixpart_interest (1=3)(2=2)(3=1)(4=0)
		lab val ptixpart_interest interest
		

	/* Participation Activities	 */													
	rename s15q2a	ptixpart_vote
	rename s15q2b	ptixpart_villmeet
	rename s15q2c	ptixpart_collact
		
	cap rename s15q7 ptixpart_contact_satisfied


/* Political Knowledge _________________________________________________________*/

	* Popular Culture
	/*
	gen ptixknow_pop_music = .
		replace ptixknow_pop_music = 1 if (s13q1 == 4 | s13q1 == 3) & s13q1_rand_cl == "1"
		replace ptixknow_pop_music = 1 if (s13q2 == 4 | s13q2 == 3) & s13q2_rand_cl == "1"
		replace ptixknow_pop_music = 0 if (s13q1 == 5 | s13q1 == -999) & s13q1_rand_cl == "1"
		replace ptixknow_pop_music = 0 if (s13q2 == 5 | s13q2 == -999) & s13q2_rand_cl == "1"
		replace ptixknow_pop_music = 0 if (s13q1 == 1 | s13q1 == 2) & s13q1_rand_cl == "1"	
		replace ptixknow_pop_music = 0 if (s13q2 == 5 | s13q2 == -999) & s13q2_rand_cl == "1"
		lab val ptixknow_pop_music correct

	gen ptixknow_pop_sport = .
		replace ptixknow_pop_sport = 1 if (s13q1 == 1) & s13q1_rand_cl == "2"
		replace ptixknow_pop_sport = 1 if (s13q2 == 1) & s13q2_rand_cl == "2"
		replace ptixknow_pop_sport = 0 if (s13q1 == 5 | s13q1 == -999) & s13q1_rand_cl == "2"
		replace ptixknow_pop_sport = 0 if (s13q2 == 5 | s13q2 == -999) & s13q2_rand_cl == "2"
		replace ptixknow_pop_sport = 0 if (s13q1b == 3 | s13q1b == 4 | s13q1b == 2) & s13q1_rand_cl == "2"		
		replace ptixknow_pop_sport = 0 if (s13q2 == 3 | s13q2 == 4 | s13q2 == 2) & s13q2_rand_cl == "2"		
		lab val ptixknow_pop_sport correct	
	*/
	rename s13q2 	ptixknow_local_dc 

	/* National Politics */
	rename s13q3a	 ptixknow_natl_pm 
		recode ptixknow_natl_pm (2=1)(1=0)(4=0)(3=0)(-999=0)

	rename s13q3b	ptixknow_natl_vp
		recode ptixknow_natl_vp (3=1)(1=0)(2=0)(4=0)(-999=0)

	lab val ptixknow_natl_* correct

	/* Foreign Affairs */
	rename s13q4new ptixknow_fopo_kenyatta 
		recode ptixknow_fopo_kenyatta (-999 = 0) (-222 = 0) (-888 = 0) (2 = 2) (1 = 1) 
		lab def ptixknow_fopo_kenyatta 0 "Wrong" 1 "Close" 2 "Correct"

	rename s13q5		ptixknow_em_aware
		destring ptixknow_em_aware, replace

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


/* Women's Political Participation _____________________________________________

	Note: This is also an experiment
	
*/


	rename s21q1	wpp_attitude

		gen wpp_attitude_dum = 1 if wpp_attitude == 1 | wpp_attitude == 2
		replace wpp_attitude_dum = 0 if wpp_attitude == 0
		lab var wpp_attitude_dum "Who should lead? Equal women or more women"
		
	rename s21q2	wpp_norm

		gen wpp_norm_dum = 1 if wpp_norm == 1 | wpp_norm == 2
		replace wpp_norm_dum = 0 if wpp_norm == 0
		lab var wpp_norm_dum "Who should lead? Equal women or more women"
		
	rename s21q3	wpp_behavior
	
	recode s21q4 	(0=1 "Male should no have final say") ///
					(1=0 "Male should have final say"), ///
					gen(wpp_nomalehhh)
		lab var wpp_nomalehhh "[NO = 1] Agree or Disagree: A man should have final say in HH"

	foreach var of varlist wpp_* {
		recode `var' (-888 = .r) (-999 = .d) (-222 = .d)
	}


/* Early Marriage ______________________________________________________________*/

	rename s17q1	em_bestage
		recode em_bestage (-888 = .r) (-999 = .d)

	gen em_past18 = (em_bestage >= 18)
		replace em_past18 = . if em_bestage == .
		lab var em_past18 "[After 18] What do you think is the best age for a girl to get married"
	
	rename s17q4 	em_allow
		
	gen em_reject = 1 if em_allow == 2
		replace em_reject = 0 if em_allow == 1 | em_allow == 3
		lab val em_reject reject
		
	rename s17q5		em_norm_reject
		recode em_norm_reject (2=2)(1=0)(3=1)
		lab val em_norm_reject em_norm_reject
		lab var em_norm_reject "Community rejects Early Marraige"
		
	clonevar em_norm_reject_dum = em_norm_reject
		recode em_norm_reject_dum (2=1)(1=0)(0=0)
		lab val em_norm_reject_dum reject
		lab var em_norm_reject_dum "(Dummy) Communtiy rejects early marriage"

	rename s17q5c		em_hearddiscussed

	rename s17q5d		em_hearddiscussed_often
		replace em_hearddiscussed_often = 0 if em_hearddiscussed == 0
		
	rename s17_txt_treat		treat_court

	gen treat_court_dum = 1 if treat_court == "treat_court" | treat_court == "treat_both"
		replace treat_court_dum = 0 if treat_court == "control"

	rename s17q8a		em_reject_religion
	rename s17q8d		em_reject_money

	foreach var of varlist em_reject_* {
		recode `var' (3=0)(1=1)(2=2)
		lab val `var' reject_cat
		gen `var'_dum = (`var' == 2)
		lab val `var'_dum yesno
	}

	
	egen em_reject_index = 	rowmean(em_reject_religion_dum ///
									em_reject_money_dum)
	
	gen em_reject_all = (em_reject_index == 1)

	
/* Health Knowledge ____________________________________________________________*/

	rename s23q1		healthknow_notradmed
		recode healthknow_notradmed (0=1)(1=0)									// Check on translation
		lab var healthknow_notradmed "[Reversed] Prayer and traditional medicine can help cure disease"
	rename s23q2		healthknow_vaccines

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


	* IPV Report
	rename s9q3		ipv_report_police
		recode ipv_report_police (2=1)(1=0)
		lab def ipv_report_police 0 "Don't Report" 1 "Report to police"
		lab val ipv_report_police ipv_report_police
		lab var ipv_report_police "How respond to cousin being absued by husband?"


/* Ideal HH Labor _____________________________________________________________________*/

lab def ge_hhlabor 1 "Mother" 2 "Father" 3 "Both"

forval i = 1/3 {
	gen ge_hhlabor`i' = .
		forval j = 1/3 {	
			replace ge_hhlabor`i' = s8q5_r_`j' if s8q5_index_r_`j' == "`i'"		// Need to change this back to "2"
		}
	lab var ge_hhlabor`i' "How is ideally responsible for X?"
	lab val ge_hhlabor`i' ge_hhlabor
}

		
	/* Generate Dummy Variable for Outcome */
	recode ge_hhlabor1 	(2 3 = 1 "Equal/Progressive") ///
							(1 = 0 "Conservative"), ///
							gen(hhlabor_chores_dum) 
			lab var hhlabor_chores_dum "[1 = prog/bal] Who in HH is responsible for water?"
	
	recode ge_hhlabor2  	(2 3 = 1 "Equal/Progressive") ///
							(1 = 0 "Conservative"), ///
							gen(hhlabor_kids_dum) 
		lab var hhlabor_kids_dum "[1 = prog/bal] Who in HH is responsible for kids?"
	
	recode ge_hhlabor3 	(1 3 = 1 "Equal/Progressive") ///
							(2 = 0 "Conservative"), ///
							gen(hhlabor_money_dum) 
		lab var hhlabor_money_dum "[1 = prog/bal] Who in HH is responsible for money?"
	
	recode hhlabor* (-999 = .d)(-888 = .r)	
	
	egen hhlabor_index = rowmean(hhlabor_chores_dum hhlabor_kids_dum hhlabor_money_dum)
		lab var hhlabor_index "Index of four HH labor questions"

/* Real Househodl Labor */

	rename s12q1_1		couples_hhlabor_water
	rename s12q1_2		couples_hhlabor_laundry
	rename s12q1_3		couples_hhlabor_kids
	rename s12q1_4		couples_hhlabor_money

	rename s12q12_1		couples_hhdecision_health
	rename s12q12_2		couples_hhdecision_school
	rename s12q12_3		couples_hhdecision_hhfix
		


/* Parenting ___________________________________________________________________*/

	rename s11q1		parent_currentevents

	recode s11q3		(2 = 1 "Disagree") ///
						(1 = 0 "Agree"), ///
						gen(parent_question)
						lab var parent_question "[disagree = 1] Parents should not allow children to quesiton their decisions"
		
	
/* Media Consumption ___________________________________________________________*/

	rename s4q2_listen_radio	radio_listen							
		lab def s4q2_listen_radio 0 "Never", modify
		lab val radio_listen s4q2_listen_radio

	gen radio_any = 1 if radio_listen > 0
		replace radio_any = 0 if radio_listen == 0
		
	rename s4q2b_listen_radio_time	radio_listen_hrs
		replace radio_listen_hrs = 0 if radio_listen == 0
		
	rename s4q3_radio_3month	radio_ever
		replace radio_ever = 1 if 	radio_listen == 1 | ///
									radio_listen == 2 | ///
									radio_listen == 3 | ///
									radio_listen == 4 | ///
									radio_listen == 5
		recode radio_ever (-999 = .d) (-888 = .r)

	/* Favorite Radio Program Types */
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

	/* Favorite Radio Stations */
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
										  
	egen radio_stations_nonpfm_any = rowmax(radio_stations_voa radio_stations_tbc ///
										  radio_stations_rone radio_stations_uhuru ///
										  radio_stations_tk)

	** Reports
	rename s4q12_ward_leader		radio_locleader
	rename s4q13_ntl_leader			radio_natleader		


/* Assetts _____________________________________________________________________*/

	rename s16q1		asset_radio
	rename s16q2		asset_radio_num
		replace asset_radio_num = 0 if asset_radio == 0
	rename s16q3		asset_tv

		foreach var of varlist asset_* {
			recode `var' (-888 = .r)(-999 = .d)
		}

		
/* Radio Distribution Compliance _______________________________________________*/

	rename treat_rd_pull treat_rd_pull 

	rename s30q1		rd_receive
	rename s30q2		rd_stillhave
	rename s30q3		rd_stillhave_whyno

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


/* Drop some long variables ____________________________________________________*/

	drop choices_randomizer_rpt_count choices_randomizer_rpt_count
	drop treat_values_urbangood_gender treat_values_urbangood_gender
	drop conjoint_randomizer_rpt_count conjoint_randomizer_rpt_count
	
		
/* Export __________________________________________________________________*/

	save "${data}/02_mid_data/pfm_ne_endline_partner_clean.dta", replace


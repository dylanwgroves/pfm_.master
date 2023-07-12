	

/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio 
Purpose: Primary Cleaning of Audio Screening Friends Survey Data
Author: 	Dylan Groves, dylanwgroves@gmail.com
			Beatrice Montano, bm2955@columbia.edu
Date: 2021/02/12
________________________________________________________________________________*/



/* Notes _______________________________________________________________________

(1) Rememeber to check in 02_kids_survey_encrypted_cleaning.do that training and pilot data are cut.
(2) Respondent Info (basic) 
	- Need to input "other tribe" at the end of data collection

*/


/* Import  _____________________________________________________________________*/

use  "${data}/01_raw_data/03_surveys/pfm_rawnopii_as_endline_friend.dta", clear


/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def female 0 "Male" 1 "Female"
	lab def yesno_rev 1 "Yes" 0 "No"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def agree_rev 0 "Agree" 1 "Disagree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 0 "Dont report" 1 "Report"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"
	lab def correct	0 "Incorrect" 1 "Correct"
	lab def yesnolisten 0 "Don't Listen" 1 "Listen"
	lab def reject_cat 0 "Always Acceptable" 1 "Sometimes Acceptable" 2 "Never Acceptable"
	lab def interest 0 "Not interested" 1 "Somewhat interested" 2 "Interested" 3 "Very interested"
	lab def em_elect 0 "Vote Against EM Candidate" 1 "Vote For EM Candidate"
	lab def hiv_elect 0 "Vote Against HIV Candidate" 1 "Vote for HIV Candidate"
	lab def treatment 0 "Control" 1 "Treatment" 
	lab def elect_topic 1 "EFM" 2 "HIV" 3 "Roads" 4 "Crime"
	lab def em_norm_reject 0 "Acceptable" 1 "Sometimes Acceptable" 2 "Never acceptable"
	lab def gov_approval 0 "Don't Approve" 1 "Approve"
	lab def gov_trust 0 "Don't Trust" 1 "Trust"
	lab def gov_votedev 0 "Don't vote dev" 1 "Vote dev"
	lab def s3q19_tribe 40 "Mdengeleko" 41 "Wamburu", modify
	lab def tzovertribe 0 "Tribe >= TZ" 1 "TZ > Tribe"



/* Survey Info _________________________________________________________________*/

	gen svy_friend = 1
	
	destring duration, gen(svy_duration)
		replace svy_duration = svy_duration / 60
	
	rename enum svy_enum
	gen svy_enum_muslim=. 														// Martin, please update with new team?
	replace svy_enum_muslim= 1 if 	svy_enum==2  | ///
									svy_enum==7  | ///
									svy_enum==8  | ///
									svy_enum==10 | ///
									svy_enum==11 | ///
									svy_enum==14 | ///
									svy_enum==15 | ///
									svy_enum==20 | ///
									svy_enum==25 | ///
									svy_enum==1  | ///
									svy_enum==29 | ///
									svy_enum==30 | ///
									svy_enum==31 | ///
									svy_enum==32 | ///
									svy_enum==37 | ///
									svy_enum==40				
	replace svy_enum_muslim = 0 if svy_enum_muslim == .

	rename id				id_friend_uid	
	gen id_resp_uid = substr(id_friend_uid, 1, strlen(id_friend_uid) - 2)
	rename district_pull	id_district_n
	rename ward_pull		id_ward_n
	rename village_pull		id_village_n

	
/* Consent _____________________________________________________________________*/

	rename consent consent														


/* Respondent info (basic) _____________________________________________________*/

	rename resp_name 		resp_name
	
	rename s2q0_female 		resp_female
		recode resp_female (2=1)(1=0)
		lab val resp_female female
		
	rename s2q1_ppe 		resp_ppe

	rename s1q3 			resp_howyoudoing
	
	rename s1q4				resp_age
	
	rename s1q5				resp_earnmoney
	
	rename s3q3_status		resp_married
	
	rename s3q4				resp_rltnhhh
	
	rename s3q4a			resp_numkids
	
	rename s3q5				resp_yrsinvill
		destring resp_yrsinvill, replace
		recode resp_yrsinvill (-888 = .r)(-999 = .d)
	
	rename s3q6				resp_villknow
	
	rename s3q7				resp_evercity
			
	rename s3q8				resp_urbanvisit
	
	rename s3q9				resp_edu
	
	rename s3q10			resp_readandwrite
		replace resp_readandwrite = 2 if resp_edu > 7
	
	rename s3q16_religion	resp_religion
	
	gen resp_christian = 0														// not sure about this one, check with baseline
	replace resp_christian = 1 if resp_religion == 2 | ///						
								  resp_religion == 4 | ///
							      resp_religion == 5 | ///
							      resp_religion == 6 | ///
							      resp_religion == 7 | ///
							      resp_religion == 8 | ///							
							      resp_religion == 9 | ///
							      resp_religion == 10 | ///
							      resp_religion == 11
	replace resp_christian = . if resp_religion == -222 | ///
								  resp_religion == -999 | ///
								  resp_religion == -888
		lab val resp_christian yesno
		
	gen resp_muslim = 0
	replace resp_muslim = 1 if resp_religion == 3 | ///						
								  resp_religion == 12 | ///
							      resp_religion == 13 | ///
							      resp_religion == 14 | ///
							      resp_religion == 15					
	replace resp_muslim = . if resp_religion == -222 | ///
							   resp_religion == -999 | ///
							   resp_religion == -888
		lab val resp_muslim yesno

	gen resp_christmuslim = 0 if resp_muslim == 1
	replace resp_christmuslim = 1 if resp_christian == 1
	replace resp_christmuslim = . if resp_religion == -222 | ///
								     resp_religion == -999 | ///
								     resp_religion == -888
		lab val resp_christmuslim resp_christmuslim

	rename s3q22_religious		resp_religiosity								
	replace resp_religiosity = . if resp_religiosity == -888 | ///
									resp_religiosity == -999
	
	rename s3q17				resp_religiousschool
		replace resp_religiousschool = s3q18 if resp_christian == 1
		label var resp_religiousschool "Have you ever been enrolled in RELIGIOUS school?"
				
	rename s3q24				resp_rellead_off


	rename s3q19_tribe			resp_tribe	
		rename s3q19_tribe_oth	resp_tribe_oth

		replace resp_tribe = 40 if resp_tribe_oth == "mdengeleko"

	

/* General Values ______________________________________________________________*/

	rename s5q4				values_conformity
		lab def values_conformity 0 "Always do what you think is right" 1 "Pay attention to others"
		lab val values_conformity values_conformity

	rename s5q3				values_dontquestion
			
		lab def values_dontquestion 0 "Question leaders" 1 "Respect authority"
		lab val values_dontquestion values_dontquestion
		
		
	rename s3q20_tz_tribe		values_tzovertribe
		gen values_tzovertribe_dum = (values_tzovertribe == 1 | values_tzovertribe == 2)
		replace values_tzovertribe_dum = . if values_tzovertribe == -888 | values_tzovertribe == .
		lab val values_tzovertribe_dum tzovertribe

	/* Recode */
	recode values_* (-999 = .d) (-888 = .r)

	
	
/* Gender Equality _____________________________________________________________

We are coding that higher is always "more gender equality"

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
		
	lab val ge_school agree_rev			
	lab val ge_work agree_rev	
	lab val ge_leadership agree			
	lab val ge_business agree	

	lab var ge_school "[Disagree = 1] It is more important that a boy goes to school than a girl"
	lab var ge_work "[Disagree = 1] When jobs are scarce, men should have more right to a job than women"
	lab var ge_leadership "[Agree = 1] In general, women make equally good village leaders as men"
	lab var ge_business "[Agree = 1] In general, women are just as able to run a successful business as men"
		
	recode ge_* (-999 = .d) (-888 = .r)

	egen ge_index = rowmean(ge_school ge_work ge_leadership ge_business)
	
	
	rename s6q5				ge_earning
	recode ge_earning (1=0)(2=1)(-999=.d)(-888=.r)
	lab var ge_earning "[Disagree = 1] If a woman earns more, it will cause problems"
	lab val ge_earning agree_rev
	
	/* Good Wife / Good Husband */
	rename s6q6				ge_goodwife
	rename s6q7				ge_goodhusband
	
	rename s6q6_0 			ge_goodwife_respect
	rename s6q6_1			ge_goodwife_money
	rename s6q6_2 			ge_goodwife_havekids
	rename s6q6_3 			ge_goodwife_faithful 
	rename s6q6_4 			ge_goodwife_sex 
	rename s6q6_5 			ge_goodwife_religious 
	rename s6q6_6			ge_goodwife_timekids
	rename s6q6_7 			ge_goodwife_chores 
	rename s6q6_8 			ge_goodwife_cooking 
	rename s6q6_9 			ge_goodwife_conflict 
	rename s6q6_10 			ge_goodwife_timetable
	rename s6q6_11 			ge_goodwife_love 
	rename s6q6__222 		ge_goodwife_other 
	rename s6q6__888 		ge_goodwife_ref 
	rename s6q6__999		ge_goodwife_dk 
	
	rename s6q7_0 			ge_goodhusband_respect
	rename s6q7_1			ge_goodhusband_money
	rename s6q7_2 			ge_goodhusband_havekids
	rename s6q7_3 			ge_goodhusband_sex 
	rename s6q7_4 			ge_goodhusband_faithful
	rename s6q7_5 			ge_goodhusband_religious 
	rename s6q7_6			ge_goodhusband_timekids
	rename s6q7_7 			ge_goodhusband_chores 
	rename s6q7_8 			ge_goodhusband_cooking 
	rename s6q7_9 			ge_goodhusband_conflict 
	rename s6q7_10 			ge_goodhusband_timetable
	rename s6q7_11 			ge_goodhusband_love 
	rename s6q7__222 		ge_goodhusband_other 
	rename s6q7__888 		ge_goodhusband_ref 
	rename s6q7__999		ge_goodhusband_dk 

	
/* Forced Marriage _____________________________________________________________*/

rename s8q5			fm_reject
	recode fm_reject (1=0)(2=1)(-999 = .d)(-888 = .r)
	lab var fm_reject "[Disagree = 1] A woman should not have a say in who she marries"
	lab val fm_reject agree_rev
	
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
	lab var fm_reject_long "[Strongly Disagree = highest] A woman shoudl not have a say in who she marries"
	
rename s8q5c		fm_friend_reject
	recode fm_friend_reject (1=0)(2=1)(-999 = .d)(-888 = .r)
	lab var fm_friend_reject "[Disagree = 1] A woman should not have a say in who she marries"
	lab val fm_friend_reject agree_rev
	
/* Prejudice ___________________________________________________________________*/
		

	/* Neighbors */

	/* Create Values */
	gen prej_yesnbr_aids = .		
	gen prej_yesnbr_homo = .
	gen prej_yesnbr_alcoholic = .
	gen prej_yesnbr_unmarried = .

	forval j = 1/4 {	
		replace prej_yesnbr_homo = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mashoga"
		replace prej_yesnbr_aids = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mtu mwenye virus vya ukimwi"
		replace prej_yesnbr_alcoholic = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Walevi"
		replace prej_yesnbr_unmarried = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Watu wanaoishi pamoja lakini hawajaoana"
		}
		
	foreach var of varlist prej_yesnbr_* {
		lab var `var' "Would accept X group to be your neighbor"
		recode `var' (1=1)(0=0)
		lab val `var' yesno
		recode `var' (-999 = .d)(-888 = .r)
	}	

	egen prej_yesnbr_index = rowmean(prej_yesnbr_aids prej_yesnbr_homo prej_yesnbr_alcoholic prej_yesnbr_unmarried)
	lab var prej_yesnbr_index "Mean of all questions about acceptable neighbors"

	/* Kids Marrying */
	forval i = 1/4 {
		gen prej_kidmarry`i' = .
			forval j = 1/4 {	
				replace prej_kidmarry`i' = s3q21_r_`j' if s3q21_sel_val_r_`j' == "`i'"			// Need to change this back to "2"
			}
		lab var prej_kidmarry`i' "Would accept X group to marry your child"
		lab val prej_kidmarry`i' yesno
	}
		rename prej_kidmarry1 		prej_kidmarry_nottribe						
		rename prej_kidmarry2		prej_kidmarry_notrelig
		rename prej_kidmarry3		prej_kidmarry_nottz
		rename prej_kidmarry4		prej_kidmarry_notrural	


		/* Recode */
		cap recode pre_kidmarry_* (-999 = .d)(-888 = .r)

		egen prej_kidmarry_index = rowmean(prej_kidmarry_nottribe prej_kidmarry_notrelig prej_kidmarry_nottz prej_kidmarry_notrural)
		lab var prej_kidmarry_index "Mean of all questions about who child can marry"

	/* Feeling Thermometer */
	forval i = 1/9 {
		gen prej_thermo`i' = .
			forval j = 1/9 {	
				replace prej_thermo`i' = s32a_g_r_`j'*5 if s32_ranked_list_r_`j' == "`i'"			// Need to change this back to "2"
				replace prej_thermo`i' = . if prej_thermo`i' < 0
			}
		lab var prej_thermo`i' "How do you feel towards X"
	}
		rename prej_thermo1 		prej_thermo_city			
		rename prej_thermo2			prej_thermo_chinese
		rename prej_thermo3			prej_thermo_muslims
		rename prej_thermo4			prej_thermo_christians	
		rename prej_thermo5			prej_thermo_sambaa
			replace prej_thermo_sambaa = s32_b if tribe_txt == "Wasambaa" & prej_thermo_sambaa == .
		rename prej_thermo6			prej_thermo_digo
			replace prej_thermo_digo = s32_b if tribe_txt == "Wadigo" & prej_thermo_sambaa == .
		rename prej_thermo7			prej_thermo_kenyan

		/* Recode */
			cap recode prej_thermo_* (-999 = .d)(-888 = .r)(-4995 = .d)
			
		/* Generate Out-Group feeling Thermometer */
		gen prej_thermo_out_rel = prej_thermo_muslims if resp_muslim == 0
			replace prej_thermo_out_rel = prej_thermo_christians if resp_muslim == 1
		
		gen prej_thermo_out_eth = prej_thermo_digo if resp_tribe != 38
			replace prej_thermo_out_eth = prej_thermo_sambaa if resp_tribe == 38


/* Early Marriage ______________________________________________________________*/

	rename s17q1_intro	ptixknow_em_aware
		replace ptixknow_em_aware = s13q5 if ptixknow_em_aware == .

	rename s17_txt_treat	treat_court

	gen treat_court_all = 1 if treat_court == "treat_both" | treat_court == "treat_court"
	replace treat_court_all = 0 if treat_court== "control"
	
	gen treat_court_courtonly = 1 if treat_court == "treat_court" 
	replace treat_court_courtonly = 0 if treat_court == "control"
	
	gen treat_court_agcourt = 1 if treat_court == "treat_both"
	replace treat_court_agcourt = 0 if treat_court == "control"
			
	rename em_txt_treat		pi_treat
		
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

	rename s17q7		em_record_any

	rename s17q9 		em_record_reject
		replace em_record_reject = 0 if em_record_any == 0

	gen em_record_accept = 1 if em_record_reject == 0 & em_record_any == 1
		replace em_record_accept = 0 if em_record_any == 0
		replace em_record_accept = 0 if em_record_any == 1 & em_record_reject == 1
		
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
		
	** Reporting
	rename s17q13		em_report 
		recode em_report (2=0)(1=1)
		lab val em_report report
		
	rename s17q14		em_report_norm	
	
	foreach var of varlist em_reject_* em_record_* em_report*  {
		recode `var' (-999 = .d)(-888 = .r)(-222 = .o)
	}

	
	
/* Political Knowledge _________________________________________________________*/

	
	/* Food */
	rename s13q1b	ptixknow_food
	
	/* Popular Culture */
	gen ptixknow_pop_music = .
		replace ptixknow_pop_music = 1 if 	(s13q1a == 4 | s13q1a == 3)
		replace ptixknow_pop_music = 0 if 	(s13q1a == 5 | s13q1a == -999)
		replace ptixknow_pop_music = 0 if 	(s13q1a == 1 | s13q1a == 2) 		
		lab val ptixknow_pop_music correct

	rename s13q2 	ptixknow_local_dc 

	/* National Politics */
	rename s13q3a	 ptixknow_natl_pm 
		recode ptixknow_natl_pm (2=1)(1=0)(4=0)(3=0)(-999=0)

	rename s13q3b	ptixknow_natl_vp
		recode ptixknow_natl_vp (3=1)(1=0)(2=0)(4=0)(-999=0)

	lab val ptixknow_natl_* correct

	/* Foreign Affiars */
	rename s13q4new ptixknow_fopo_kenyatta 
		recode ptixknow_fopo_kenyatta (-999 = 0) (-222 = 0) (-888 = 0) (2 = 2) (1 = 1) 
		lab def ptixknow_fopo_kenyatta 0 "Wrong" 1 "Close" 2 "Correct"
		
	rename s13q6		ptixknow_sourcetrust
		
	foreach var of varlist ptixknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)
	}

	
	
/* Political Interest and Participation _________________________________________*/

	** Generate Interest
	rename s15q1	ptixpart_interest

	** Participation Activities														
	rename s15q2a	ptixpart_vote
	rename s15q2b	ptixpart_villmeet
	rename s15q2c	ptixpart_collact
	
	recode ptixpart_* (-999 = .d) (-888 = .r)
		
	
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
		
	/* HIV Ranking */
	gen ptixpref_hiv = ptixpref_rank_health
		replace ptixpref_hiv = ptixpref_hiv + 1 if ptixpref_rank_efm > ptixpref_rank_health
		lab var ptixpref_hiv "Rank of HIV/Health, Adjusted for EFM"
		
	gen ptixpref_hiv_first = (ptixpref_hiv == 9)
		lab var ptixpref_hiv_first "Ranked HIV First"
	
	gen ptixpref_hiv_topthree = (ptixpref_hiv == 9 | ///
								ptixpref_hiv == 8  | ///
								ptixpref_hiv == 7)
		lab var ptixpref_hiv_topthree "Ranked HIV Top Three"
								
	gen ptixpref_hiv_notlast = (ptixpref_hiv != 2)
		lab var ptixpref_hiv_notlast "Did not rank HIV last"

	/* EFM Ranking */	
	gen ptixpref_efm = ptixpref_rank_efm
		replace ptixpref_efm = ptixpref_efm + 1 if ptixpref_rank_health > ptixpref_rank_efm
		lab var ptixpref_efm "Rank of EFM, Adjusted for HIV"
		
	gen ptixpref_efm_first = (ptixpref_efm == 9)
		lab var ptixpref_efm_first "Ranked EFM First"
	
	gen ptixpref_efm_topthree = (ptixpref_efm == 9 | ///
								ptixpref_efm == 8  | ///
								ptixpref_efm == 7)
	lab var ptixpref_efm_topthree "Ranked EFM Top Three Preferences"
								
	gen ptixpref_efm_notlast = (ptixpref_efm != 2)
		lab var ptixpref_efm_notlast "Did not rank EFM Last"

	foreach var of varlist ptixpref_* {
		cap recode `var' (-999 = .d)(-888 = .r)(-4995 = .d)
	}
	

/* Election ____________________________________________________________________*/

	/* Code Outcomes for Screening Experiments */
	gen em_elect = s3q4a_1	
		recode em_elect (2=0)(1=1)(-888 = .r)(-999 = .d)
		lab val em_elect em_elect 
		
		recode s3q4a_2 (2=1)(1=0), gen(s3q4a_2_reverse)												// Reversed order for randomly selected 1/2 of respondents
		replace em_elect = s3q4a_2_reverse if rand_order_1st_txt == "second"
		recode em_elect (-888 = .r)(-999 = .d)
		
	gen hiv_elect = s3q4b_1		
		recode hiv_elect (2=0)(1=1)(-888 = .r)(-999 = .d)
		lab val hiv_elect hiv_elect
		
		recode s3q4b_2	(2=1)(1=0), gen(s3q4b_2_reverse)											// Reversed order for randomly selected 1/2 of respondents
		replace hiv_elect = s3q4b_2_reverse if rand_order_2nd_txt == "second"
		recode hiv_elect (-888 = .r)(-999 = .d)

		
	/* Code Candidate Profiles */
	forval i = 1/4 {
	
		/* Religion */
		gen cand`i'_muslim = 1 if 			rand_cand`i'_txt == "Mr. Salim" | ///
											rand_cand`i'_txt == "Mrs. Mwanaidi"					// There were issues with this - check with Martin
		replace cand`i'_muslim = 0 if 		rand_cand`i'_txt == "Mr. John" | ///
											rand_cand`i'_txt == "Mrs. Rose"	
		
		lab val cand`i'_muslim yesno 
		lab var cand`i'_muslim "Candidate `i' Muslim?"

		
		/* Gender */
		gen cand`i'_female = 1 if 			rand_cand`i'_txt == "Mrs. Rose" | ///
											rand_cand`i'_txt == "Mrs. Mwanaidi"		
		replace cand`i'_female = 0 if 		rand_cand`i'_txt == "Mr. Salim" | ///
											rand_cand`i'_txt == "Mr. John"		
											
		lab val cand`i'_female yesno
		lab var cand`i'_female "Candidate `i' Female?"
	}
	
		rename cand1_muslim cand1_muslim_1  
		rename cand2_muslim cand2_muslim_1
		rename cand3_muslim cand1_muslim_2
		rename cand4_muslim cand2_muslim_2
		rename cand1_female cand1_female_1  
		rename cand2_female cand2_female_1
		rename cand3_female cand1_female_2
		rename cand4_female cand2_female_2
	
		/* Issue */
			/* First Election */
			gen cand1_topic_1 = 1 if 	 rand_order_1st_txt == "first"
				replace cand1_topic_1 = 3 if rand_promise_1st_txt == "improve roads in the village" & ///
										 rand_order_1st_txt == "second"
				replace cand1_topic_1 = 4 if rand_promise_1st_txt == "reduce crime in the village" & ///
										 rand_order_1st_txt == "second"
				
			gen cand2_topic_1 = 2 if 	 rand_order_1st_txt == "second"
				replace cand2_topic_1 = 3 if rand_promise_1st_txt == "improve roads in the village" & ///
										 rand_order_1st_txt == "first"
				replace cand2_topic_1 = 4 if rand_promise_1st_txt == "reduce crime in the village" & ///
										 rand_order_1st_txt == "first"
										 
			/* Second Election */					 
			gen cand1_topic_2 = 2 if 	 rand_order_2nd_txt == "first"
				replace cand1_topic_2 = 3 if rand_promise_2nd_txt == "improve roads in the village" & ///
										 rand_order_2nd_txt == "second"
				replace cand1_topic_2 = 4 if rand_promise_2nd_txt == "reduce crime in the village" & ///
										 rand_order_2nd_txt == "second"
				
			gen cand2_topic_2 = 2 if 	 rand_order_2nd_txt == "second"
				replace cand2_topic_2 = 3 if rand_promise_2nd_txt == "improve roads in the village" & ///
										 rand_order_2nd_txt == "first"
				replace cand2_topic_2 = 4 if rand_promise_2nd_txt == "reduce crime in the village" & ///
										 rand_order_2nd_txt == "first"
									 
			forval i = 1/2 {
				lab val cand`i'_topic_1 cand`i'_topic_2 elect_topic
				lab var cand`i'_topic_1 "Candidate Platform"
				lab var cand`i'_topic_2 "Candidate Platform"

			}
		
	/* Code Vote Choices */
	gen vote_1 = s3q4a_1
		replace vote_1 = s3q4a_2 if rand_order_1st_txt == "second"
		recode vote_1 (2=0)(1=1)
		
	gen vote_2 = s3q4b_1
		replace vote_2 = s3q4b_2 if rand_order_2nd_txt == "second"
		recode vote_2 (2=0)(1=1)

		
		
		
/* Developmet News _____________________________________________________________*/
	
	rename sdev_txt_treat	dev_treat
		gen dev_treat_neg = 1 if dev_treat == "negative"
		replace dev_treat_neg = 0 if dev_treat == "control"
		
		gen dev_treat_pos = 1 if dev_treat == "positive"
		replace dev_treat_pos = 0 if dev_treat == "control"
	
	rename sdevq4  dev_localapprove			
		recode dev_localapprove (2 = 0) (1 = 1)
		lab val dev_localapprove gov_approval
		
	rename sdevq1  dev_trust
		recode dev_trust (2=0)(1=1)
		lab val dev_trust gov_trust
		
	foreach var of varlist sdev_election_* {
		recode `var' (2=0)
	}
	
	egen dev_electdev = rowmax(sdev_election_vf sdev_election_f sdev_election_n sdev_election_vn)
		lab val dev_electdev gov_votedev
		

		gen electdev_dist = 0 if sdev_election_vf != .
			replace electdev_dist = 1 if sdev_election_f != .
			replace electdev_dist = 2 if sdev_election_n != .
			replace electdev_dist = 3 if sdev_election_vn != .
		lab def electdev_dist 0 "very far" 1 "far" 2 "near" 3 "very near"
		lab val electdev_dist electdev_dist 
		
	rename sdevq3	dev_responsibility
	
	/* Recode */
	recode dev_localapprove dev_trust dev_electdev (-999 = .d) (-888 = .r)
	
			

/* Efficacy ____________________________________________________________________*/

	rename effic1			efficacy_understand
		lab def efficacy_understand 0 "Politics too complicated" 1 "Understand politics"
		lab val efficacy_understand efficacy_understand
		
	rename effic2			efficacy_speakout
		lab def efficacy_speakout 0 "Dont have a say" 1 "Comfy speaking out"
		lab val efficacy_speakout efficacy_speakout
	
	/* Recode */
	recode efficacy_* (-999 = .d) (-888 = .r)
	

	
/* Health Knowledge ____________________________________________________________*/

	rename s23q1		healthknow_notradmed
		recode healthknow_notradmed (0=1)(1=0)									// Check on translation
		lab val healthknow_notradmed yesno_rev
		lab var healthknow_notradmed "[Reversed] Prayer and traditional medicine can help cure disease"
		
	rename s23q4		healthknow_nowitchcraft
		recode healthknow_nowitchcraft (0=1)(1=0)
		lab val healthknow_nowitchcraft yesno_rev
		lab var healthknow_nowitchcraft "[Reversed] Believe in witchcraft?"

	foreach var of varlist healthknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)(-888 = .r)
	}


/* HIV _________________________________________________________________________*/

	rename s_hiv_livelong hiv_livelong
	gen hivknow_arv_survive = .
		replace hivknow_arv_survive = 1 if strpos(hiv_livelong, "1") 
		replace hivknow_arv_survive = 1 if strpos(hiv_livelong, "2") 	
		replace hivknow_arv_survive = 0 if hiv_livelong != "" & hivknow_arv_survive != 1 

	rename s_hiv_stigma2		hivstigma_yesbus

	rename s_disclose_family_b	hivdisclose_friend
	rename s_disclose_family_c	hivdisclose_cowork
	
	rename s_hiv_antiretroviral hivknow_arv_any
	
	recode hivdisclose_* (-999 = .d)(-888 = .r)(-222 = .o)

	egen hivdisclose_index = rowmean(hivdisclose_friend hivdisclose_cowork)

	recode hivknow_* hivstigma_* (-999 = .d)(-888 = .r)(-222 = .o)
	
	
	
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

	rename s9q2 			ipv_norm_rej
		recode ipv_norm_rej (1=0)(0=1)(-999 = .d)(-888 = .r)	
		lab val ipv_norm_rej ipv
		
	rename s9q3		ipv_report
		recode ipv_report (2=0)(1=1)
		lab var ipv_report "Report IPV to police?"
		lab val ipv_report report
		
	recode ipv_* (-999 = .d)(-888 = .r)		
	
	
/* Media Consumption ___________________________________________________________*/

	rename s4q2_listen_radio	radio_listen							
		lab def s4q2_listen_radio 0 "Never", modify
		lab val radio s4q2_listen_radio
		
	rename s4q2b_listen_radio_time	radio_listen_hrs
		replace radio_listen_hrs = 0 if radio_listen == 0
		recode radio_listen_hrs (888 = .r)
		
	rename s4q3_radio_3month	radio_ever
		replace radio_ever = 1 if 	radio_listen == 1 | ///
									radio_listen == 2 | ///
									radio_listen == 3 | ///
									radio_listen == 4 | ///
									radio_listen == 5
		recode radio_ever (-999 = .d)(-888 = .r)(-222 = .o)

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
	
	egen radio_typetotal = rowtotal(radio_type_*)


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


	** Group Listening
	rename s4q7					radio_group	
	rename s4q8					radio_group_who

	** Reports
	rename s4q12_ward_leader		radio_locleader
	rename s4q13_ntl_leader			radio_natleader								


/* Radio Distribution Compliance _______________________________________________*/

	rename treat_rd_pull treat_rd_pull 

	rename s30q1		rd_receive
	rename s30q2		rd_stillhave

	cap rename s30q8		rd_controls
	cap rename s30q9		rd_problems
	cap rename s30q10		rd_challenge
		cap rename s30q10_1 	rd_challenge_jealous
		cap rename s30q10_2 	rd_challenge_mistrust
		cap rename s30q10_3		rd_challenge_fight
		cap rename s30q10_oth	rd_challenge_oth
	
	
/* Audio Screening Compliance __________________________________________________*/

	rename s31q1		comply_any
	rename s31q3		comply_topic



/* Conclusion __________________________________________________________________*/

	rename s20q1				svy_followupok

	rename s20q2latitude		svy_gps_lat
	rename s20q2longitude		svy_gps_long		

	rename s20q3				svy_others
	rename s20q4_sm				svy_others_who

/* Rename Treatment Variables __________________________________________________*/

	*rename treat_rd_pull	rd_treat

/* Remove Variables ____________________________________________________________*/
	
	rename s17q8 f17q8
	
	drop section_* simid subscriberid devicephone* duration username ///
	caseid *_pull enum_oth s1* int_* txt_* choices_* ///
	s14* s4* s5* s6* s20* s21* ///
	ranked_* *_cl *_count *_rand *_draw ///	
	sdev_*	s_*
	
	rename f17q8 s17q8


/* Merge Original Data _________________________________________________________*/

	tempfile dta_friend
	gen sample_friends = 1	
	duplicates drop id_resp_uid, force


/* Export __________________________________________________________________*/

	save "${data}/01_raw_data/pfm_as_endline_clean_friend.dta", replace

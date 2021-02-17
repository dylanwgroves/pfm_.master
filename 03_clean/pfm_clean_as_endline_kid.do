	

/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio 
Purpose: Primary Cleaning of Audio Screening Kids Survey Data
Author: 	Dylan Groves, dylanwgroves@gmail.com
			Beatrice Montano, bm2955@columbia.edu
Date: 2021/02/12
________________________________________________________________________________*/


/* Notes _______________________________________________________________________

(*) Rememeber to check in kids_02_cleaning_martin.do that training and pilot data are cut.
(*) Respondent Info (basic) 
	- clean "other tribe" at the end of collection
	- Think about how to code religiosity differently across religions
(*) Prejudice
	- check outer thermomether for tribe_txt
(*) Forced Marriage and Early Marriage
	- check labeling of answers, can we make them all coherent?
(*) Elections
	- check cleaning - not done 
(*) Political Knowledge
	- clean "other food" at the end of collection
(*) Gender Equality
	- clean "other" in good wife / good husband at the end of collection
*/


/* Set Seed ____________________________________________________________________*/
	
	set seed 1956

/* Import  _____________________________________________________________________*/

	use  "${data}/01_raw_data/03_surveys/pfm_rawnopii_as_endline_kid.dta", clear


/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def female 0 "Male" 1 "Female"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def agree_rev 1 "Disagree" 0 "Agree"
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
	lab def ge_wep 1 "Women dont work" 2 "Depends" 3 "Women work"
	lab def as_parentattend  0 "No/Dont Know" 1 "Yes"
	lab def s3q19_tribe 40 "Mdengeleko" 41 "Wamburu", modify
	lab def hhlabor_simple 0 "Traditional gender role" 1 "Balanced or progressive gender roles"
	lab def tzovertribe 0 "Tribe >= TZ" 1 "TZ > Tribe"
	lab def leadership 0 ""
	lab def ge_hhlabor 	1 "Mother" 2 "Father" 3 "Both Parents" 4 "Female kid" ///
						5 "Male kid" 6 "All kids" 7 "Whole family"


/* Survey Info _________________________________________________________________*/

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

	rename id				id_kid_uid
		lab var id_kid_uid "Unique ID of kid"

	gen id_kid_c = 			substr(id_kid_uid,-1,.)
		destring id_kid_c, replace
		lab var id_kid_c "Random number assigned to kid out of 5"
	
	gen id_resp_uid = 		substr(id_kid_uid, 1, strlen(id_kid_uid) - 2)
		lab var id_resp_uid "Unique ID of original respondent"
		
	egen id_kid_rank = 		rank(s1q4), by(id_resp_uid) unique
		lab var id_kid_rank "Age order out of kids in family 13-18"

	rename district_pull	id_district_n
	rename ward_pull		id_ward_n
	rename village_pull		id_village_n
	


/* Consent _____________________________________________________________________*/

	rename consent consent														


/* Respondent info (basic) _____________________________________________________*/

	rename resp_name 		resp_name
	
	rename s2q0_female 		resp_female
		lab val resp_female female
		
		
	rename s2q1_ppe 		resp_ppe

	rename s1q3 			resp_howyoudoing
	
	rename s1q4				resp_age
	
	rename s3q7				resp_edu
	rename s3q8				resp_readandwrite
		replace resp_readandwrite = 1 if resp_edu > 7
	
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

	rename s3q22_religious		resp_religiosity								// maybe add different code for different religions?
	replace resp_religiosity = . if resp_religiosity == -888 | ///
									resp_religiosity == -999
	
	rename s3q17				resp_religiousschool							
		replace resp_religiousschool = s3q18 if resp_christian == 1
		drop s3q18
		label var resp_religiousschool "Have you ever been enrolled in RELIGIOUS school?"
			
	rename s3q24				resp_rellead_off
	
	rename s3q19_tribe			resp_tribe	
	rename s3q19_tribe_oth		resp_tribe_oth									// clean this at the end of collection
	

/* Prejudice ___________________________________________________________________*/
		
	/* Tribe vs Nation */
	rename s3q20_tz_tribe		values_tzovertribe
	gen values_tzovertribe_dum = (values_tzovertribe == 1 | values_tzovertribe == 2)
	replace values_tzovertribe_dum = . if values_tzovertribe == -888 | values_tzovertribe == .
	lab val values_tzovertribe_dum tzovertribe


	/* Marriage */	
	unab varlist : s3q21_*
	unab exclude : s3q21_r_1 s3q21_r_2 s3q21_sel_val_r_1 s3q21_sel_val_r_2
	local varlist : list varlist - exclude
	foreach var of var `varlist' {
	drop `var'
	}
	
	forval i = 1/2 {
		gen prej_kidmarry`i' = .
			forval j = 1/2 {	
				replace prej_kidmarry`i' = s3q21_r_`j' if s3q21_sel_val_r_`j' == "`i'"	
			}
		lab var prej_kidmarry`i' "Parents would accept me marrying X group"
		lab val prej_kidmarry`i' yesno
	}
		rename prej_kidmarry1 		prej_kidmarry_nottribe			
		rename prej_kidmarry2		prej_kidmarry_notrelig

		foreach var of varlist prej_kidmarry_* {
			cap recode `var' (-999 = .d)(-888 = .r)
		}	
	
	foreach var of var `exclude' {
	drop `var'
	}
	
	/* Neighbors */
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
		lab val `var' yesno
		recode `var' (-999 = .d)(-888 = .r)
	}	

	egen prej_yesnbr_index = rowmean(prej_yesnbr_aids prej_yesnbr_homo prej_yesnbr_alcoholic prej_yesnbr_unmarried)
	lab var prej_yesnbr_index "Mean of all questions about acceptable neighbors"

	drop s5q5_* rand_choices_helper
		
	/* Feeling Thermometer */	
	unab varlist : s32_*
	unab exclude : s32a_g_r_* s32_ranked_list_r_* s32_b
	local varlist : list varlist - exclude
	foreach var of var `varlist' {
	drop `var'
	}
	
	forval i = 1/9 {
		gen prej_thermo`i' = .
			forval j = 1/9 {	
				replace prej_thermo`i' = s32a_g_r_`j'*5 if s32_ranked_list_r_`j' == "`i'"	
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
	rename prej_thermo8			prej_thermo_women
	rename prej_thermo9			prej_thermo_men
		
	foreach var of var `exclude' {
	drop `var'
	}

	/* Generate Out-Group feeling Thermometer */
	gen prej_thermo_out_rel = prej_thermo_muslims if resp_muslim == 0
		replace prej_thermo_out_rel = prej_thermo_christians if resp_muslim == 1
	
	gen prej_thermo_out_eth = prej_thermo_digo if resp_tribe != 38				
		replace prej_thermo_out_eth = prej_thermo_sambaa if resp_tribe == 38	// not sure, shouldn't this be !=58 ?
			
																				// make out_gender thermo
			
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

	rename s8q5_partner	fm_parent_reject
		lab val fm_parent_reject agree


/* Political Participation and Efficacy _________________________________________*/
 
	** Generate Interest
	rename s15q1	ptixpart_interest

	** Participation Activities														
	rename s15q2	efficacy_understand
	recode s15q4 	(1=1 "Want to lead") ///
					(2=0 "Other things to do"), ///
					gen(ptixpart_leaderhsip) label(ptixpart_leadership)

/* Early Marriage ______________________________________________________________*/

	rename s3q11	em_bestage 
		recode em_bestage (-888 = .r) (-999 = .d)

		gen em_past18 = (em_bestage >= 18)
		replace em_past18 = . if em_bestage == .
		lab var em_past18 "[After 18] What do you think is the best age for a girl to get married"

	rename s3q12	em_bestkidnum
		recode em_bestkidnum (-888 = .r) (-999 = .d)

	rename s17q4 	em_allow

	gen em_reject = 1 if em_allow == 2
		replace em_reject = 0 if em_allow == 1 | em_allow == 3
		label val em_reject reject
		
	rename s17q6	em_parent_allow

	gen em_parent_reject = 1 if em_parent_allow == 2
		replace em_parent_reject = 0 if em_parent_allow == 1 | em_parent_allow == 3
		label val em_parent_reject reject
		
	rename s17q8a		em_reject_religion
	rename s17q8d		em_reject_money

		foreach var of varlist em_reject_* {
			recode `var' (3=0)(1=1)(2=2)
			lab val `var' reject_cat
			gen `var'_dum = (`var' == 2)
			lab val `var'_dum yesno
		}
		
	rename s13q5 	em_legalage
		recode em_legalage (-999 = .d) (-888 = .r)
	
	gen em_legalage18 = (em_legalage > 17)
	
	foreach var of varlist em_reject_* {
		recode `var' (-999 = .d) (-888 = .r)
	}	
	
	egen em_reject_index = rowmean(em_reject_religion_dum em_reject_money_dum)


	
/* Election ____________________________________________________________________*/
																				 // check cleaning overall section
	/* Code Outcomes for Screening Experiments */
	gen em_elect = s3q4a_1	
		recode em_elect (2=0)(1=1)
		lab val em_elect em_elect 
		
		recode s3q4a_2 (2=1)(1=0), gen(s3q4a_2_reverse)							// Reversed order for randomly selected 1/2 of respondents
		replace em_elect = s3q4a_2_reverse if rand_order_1st_txt == "second"

	gen hiv_elect = s3q4b_1		
		recode hiv_elect (2=0)(1=1)
		lab val hiv_elect hiv_elect
		
		recode s3q4b_2	(2=1)(1=0), gen(s3q4b_2_reverse)						// Reversed order for randomly selected 1/2 of respondents
		replace hiv_elect = s3q4b_2_reverse if rand_order_2nd_txt == "second"

		
	/* Code Candidate Profiles */
	forval i = 1/4 {
	
		/* Religion */
		gen cand`i'_muslim = 1 if 			rand_cand`i'_txt == "Mr. Salim" | ///
											rand_cand`i'_txt == "Mrs. Mwanaidi"		// There were issues with this - check with Martin
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

		
/* Political Knowledge _________________________________________________________*/

	/* Food */
	rename s13q1b	ptixknow_food
																				// clean "other" at the end of collection
	/* Popular Culture */
	gen ptixknow_pop_music = .
		replace ptixknow_pop_music = 1 if 	(s13q1a == 4 | s13q1a == 3)			// is Ally Kiba also a right answer? # 6
		replace ptixknow_pop_music = 0 if 	(s13q1a == 5 | s13q1a == -999 | s13q1a == 1 | s13q1a == 2)
		lab val ptixknow_pop_music correct

	/* Local Politics */
	rename s13q2a 	ptixknow_local_dc 
	rename s13q2b 	ptixknow_local_mp

	/* Sources about new issues */
	rename s13q6	ptixknow_sourcetrust
		
	foreach var of varlist ptixknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)
	}

/* HIV  ________________________________________________________________________*/

	gen hivknow_arv_survive = .
		replace hivknow_arv_survive = 1 if strpos(s_hiv_livelong, "1") 
		replace hivknow_arv_survive = 1 if strpos(s_hiv_livelong, "2") 	
		replace hivknow_arv_survive = 1 if strpos(s_hiv_livelong, "8") 	
		replace hivknow_arv_survive = 0 if s_hiv_livelong != "" & hivknow_arv_survive != 1 
	
	rename s_hiv_secret			hivdisclose_nosecret
		recode hivdisclose_nosecret (0=1)(1=0)
		lab var hivdisclose_nosecret "[Reverse] Prefer family member keep HIV secret?"

	rename s_hiv_stigma2		hivstigma_yesbus
	
	rename s_hiv_stigma2_parent	hivstigma_parent_yesbus
	
	recode hiv* (-999 = .d)(-888 = .r)(-222 = .o)
	


	/* Pre-treatment: s HH roles in family*/	
	drop s12q1ab
	
	rename s12q1a				hhlabor_water
	rename s12q1b				hhlabor_laundry
	rename s12q1c				hhlabor_kids
	
	foreach var of varlist hhlabor_water hhlabor_laundry hhlabor_kids {
		recode `var' (0 = 4) if resp_female == 1								// If girl and say "self", it means you are saying "girls"
		recode `var' (0 = 5) if resp_female == 0								// If boy and say "self", it means you are saying "boys"
		
		recode `var'	(1 4 = 0 "women") ///
						(2 3 5 6 7 = 1 "men / balance"), ///
						gen(`var'_dum) label(`var'_dum)
		
		lab var `var'_dum "[1=prog/bal] Who in household is responsible for..."
		}

	rename s12q1d				hhlabor_money
		recode hhlabor_money (0 = 4) if resp_female == 1						// If girl and say "self", it means you are saying "girls"
		recode hhlabor_money (0 = 5) if resp_female == 0						// If boy and say "self", it means you are saying "boys"
		recode hhlabor_money 	(1 3 4 6 7 = 1 "women / balance") ///
								(2 5 = 0 "men"), ///
								gen(hhlabor_money_dum) label(hhlabor_money_dum)
		lab var hhlabor_money_dum  "[1=prog/bal] Who in household is responsible for..."
								
/* HH roles Experiment _________________________________________________________*/

	rename scouples_txt_treat 	couples_treat
	

/* Gender Equality _____________________________________________________________*/

	gen hhlabor_chores = hhlabor_water if txt_choresactual == "water"
		replace hhlabor_chores = hhlabor_laundry if txt_choresactual == "laundry"
	
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
	
	/* Gender equality outcomes */		
	rename s6q8 			    ge_earning
		recode ge_earning (1=0)(2=1)	
		lab val ge_earning agree_rev
		lab var ge_earning "[Disagree = 1] If a woman earns more, it will cause problems"

	rename s6q8_parent 			ge_parent_earning
		recode ge_parent_earning (1=0)(2=1)
		lab val ge_parent_earning agree_rev
		lab var ge_parent_earning "[Parent, Disagree = 1] If a woman earns more, it will cause problems"

	rename s6q1			ge_school	
		recode ge_school (1=0)(2=1) 	
		lab val ge_school agree_rev				
		lab var ge_school "[Disagree = 1] It is more important that a boy goes to school than a girl"
		
	recode ge_* (-999 = .d) (-888 = .r)
	
	/* Ideal HH roles outcome */												// we should add "taking care of children" back in for socialization purposes!

	forval i = 1/2 {
		gen ge_hhlabor`i' = .
			forval j = 1/2 {	
				replace ge_hhlabor`i' = s8q5_r_`j' if s8q5_index_r_`j' == "`i'"	
			}
		lab var ge_hhlabor`i' "How is ideally responsible for X?"
		lab val ge_hhlabor`i' ge_hhlabor
	}
		
		rename ge_hhlabor1 		ge_hhlabor_chores
			recode ge_hhlabor_chores 	(2 3 5 6 7 = 1 "men/balanced") ///
										(1 4 = 0 "women"), ///
										gen(ge_hhlabor_chores_dum) label(ge_hhlabor_chores_dum)
										lab var ge_hhlabor_chores_dum "[1=prog/bal] Who is ideally responsible for hh chores"

		rename ge_hhlabor2		ge_hhlabor_money
			recode ge_hhlabor_money 	(1 3 4 6 7 = 1 "women/balanced") ///
										(2 5 = 0 "men"), ///
										gen(ge_hhlabor_money_dum) label(ge_hhlabor_money_dum)				
										lab var ge_hhlabor_money_dum "[1=prog/bal] Who is ideally responsible for making money"
	
	/* Good wife */
	rename s6q6		goodwife
	rename s6q6__1		goodwife_hard
	rename s6q6_0 		goodwife_respecful
	rename s6q6_1 		goodwife_makemoney										
	rename s6q6_2		goodwife_haschildren	
	rename s6q6_3		goodwife_sex  
	rename s6q6_4		goodwife_nocheat
	rename s6q6_5		goodwife_religious 
	rename s6q6_6		goodwife_parent
	rename s6q6_7		goodwife_chores 
	rename s6q6_8		goodwife_cook  
	rename s6q6_9		goodwife_nofight
	rename s6q6_10		goodwife_timetable 
	rename s6q6_11		goodwife_lovehusb
	rename s6q6_12		goodwife_lovechild
	rename s6q6__888 	goodwife_dk
	rename s6q6__222	goodwife_oth
	*s6q6_oth																	// clean this at the end of collection
	
	/* Good husband */
	rename s6q7		goodhusb
	rename s6q7__1		goodhusb_hard
	rename s6q7_0 		goodhusb_respecful
	rename s6q7_1 		goodhusb_makemoney	
	rename s6q7_2		goodhusb_haschildren	
	rename s6q7_3		goodhusb_sex  
	rename s6q7_4		goodhusb_nocheat
	rename s6q7_5		goodhusb_religious 
	rename s6q7_6		goodhusb_parent
	rename s6q7_7		goodhusb_chores 
	rename s6q7_8		goodhusb_cook  
	rename s6q7_9		goodhusb_nofight
	rename s6q7_10		goodhusb_timetable 
	rename s6q7_11		goodhusb_lovehusb
	rename s6q7_12		goodhusb_lovechild
	rename s6q7__888 	goodhusb_dk
	rename s6q7__222	goodhusb_oth
	*s6q7_oth																	// clean this at the end of collection
	
	egen ge_index = rowmean(ge_wep_dum ge_earning ge_school)

	
/* Family and Parenting ________________________________________________________*/

	rename s12q14 		parent_permission
	
	rename s11q1 		parent_talknews

	recode s11q3 	(2=1 "Disagree") ///
					(1=0 "Agree"), ///
					gen(parent_question) label(parent_question)
					lab var parent_question "Agree (0) or Disagree (1): Parents should not allow children to question their decisions"
	
/* Media Consumption ___________________________________________________________*/
	
	rename s4q2_listen_radio	radio_listen							
		lab def s4q2_listen_radio 0 "Never", modify
		lab val radio s4q2_listen_radio
		
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
		rename s4q5_programs_sm_7		radio_type_religmusic
		rename s4q5_programs_sm_8		radio_type_edu
				
		lab val radio_type_* yesnolisten
		foreach var of varlist radio_type_* {
			replace `var' = 0 if radio_ever == 0
		}
	
			egen radio_typetotal = rowtotal(radio_type_*)
	
	rename s4q6_listen_who	radio_who 
		rename s4q6_listen_who_0 radio_who_noone
		rename s4q6_listen_who_1 radio_who_fam 
		rename s4q6_listen_who_2 radio_who_friend 
		rename s4q6_listen_who_3 radio_who_community 
		rename s4q6_listen_who__999 radio_who_dk
		
		foreach var of varlist radio_who_* {
			replace `var' = 0 if radio_ever == 0
		}
	
	rename s4q7_agency		radio_choice
	
	
/* Role Model __________________________________________________________________*/

	rename s40q1 			rolemodel_who

	rename s40q1_1			rm_oldwoman
	rename s40q1_2			rm_oldman
	rename s40q1_3			rm_child
	rename s40q1_4			rm_maleteach
	rename s40q1_5			rm_femaleteach
	rename s40q1_6			rm_maledoctor
	rename s40q1_7			rm_femaledoctor
	rename s40q1_8			rm_villlead
	rename s40q1_9			rm_rellead
	rename s40q1_10			rm_malebiz
	rename s40q1_11			rm_femalebiz
	rename s40q1_12			rm_malepolice
	rename s40q1_13			rm_femalepolice
	rename s40q1_14			rm_maleptix
	rename s40q1_15			rm_femaleptix
	rename s40q1_16			rm_maleartist
	rename s40q1_17			rm_femaleartist 
	rename s40q1_18			rm_malesport
	rename s40q1_19			rm_femalesport 
	rename s40q1__222		rm_other 
	rename s40q1__888		rm_refuse
	rename s40q1__999		rm_dk
	
/* Radio Distribution Compliance _______________________________________________*/

	rename s30q1 			rd_receive 
	rename s30q2 			rd_listen
	
	
/* Audio Screening Compliance __________________________________________________*/

	rename s31q1		as_parentattend
		recode as_parentattend (2=1)(3=0)
		lab val as_parentattend as_parentattend 
		
	rename s31q3 		as_parentattend_topic									// add check whether the topic is the right one!
	rename s31q4 		as_parentattend_findout

	recode as_parent* (-999=.d)(-888=.r) (-222=.)

																			
/* Conclusion __________________________________________________________________*/

	rename s20q1				svy_followupok

	rename s20q2latitude		svy_gps_lat
	rename s20q2longitude		svy_gps_long		

	rename s20q3				svy_others
	rename s20q4_sm				svy_others_who

	
/* Merge Original Data _________________________________________________________*/

	gen sample_kids = 1
	
	
/* Remove Variables ____________________________________________________________*/

	drop rand_* simid subscriberid devicephone* duration username ///
	caseid *_pull enum_oth s1* int_* txt_* choices_* ///
	s0* s3* s4* s6* s20* s8* ///
	ranked_* *_cl *_count *_rand *_sw *_txt scouples_* v4* v5* ///	
	scouplesq4 scouplesq5 section_*_start section_*_end s_* section_* ///
	district_name enum_name ward_name village_name deviceid goodwife goodhusb ///
	formdef_* rolemodel_who key starttime startdate endtime enddate survey_length

/* Export Long __________________________________________________________________*/

	save "${data}/01_raw_data/pfm_as_endline_clean_kid_long.dta", replace

/* Make Wide ___________________________________________________________________*/

	duplicates drop id_kid_c id_resp_uid, force									// COME BACK AND FIX THIS WHEN WE FIND OUT THE SOURCE OF THE ISSUE 6_191_3_83_2

	reshape wide 	 id_district_n id_ward_n id_village_n id_kid_uid id_re id_kid_c ///
					 svy_* resp_* hhlabor_* fm_* em* ptix* efficacy* ///
					 goodwife_* goodhusb_* ge_* radio_* parent_* rm_* prej_* values_* ///
					 hiv*  *_treat rd_* submissiondate cand* vote* as*, ///
					 i(id_resp_uid) j(id_kid_rank)

					 
/* Export Wide __________________________________________________________________*/

	save "${data}/01_raw_data/pfm_as_endline_clean_kid.dta", replace

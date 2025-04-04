
	
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Audio Screening
	Purpose: Endline Survey - clean and remove PII
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/11/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global date = td(07122020) // update the date everyday		

/* Notes _______________________________________________________________________

	(1) Rememeber to cut out training and pilot data 
	(2) Need to come back for feeling thermometer questions

*/

/* Import  _____________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_rawpii_as_endline.dta", clear
	

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def female 0 "Male" 1 "Female"
	lab def agree 0 "Disagree" 1 "Agree"
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
	lab def tzovertribe 0 "Tribe >= TZ" 1 "TZ > Tribe"
	lab def hhlabor 1 "Mother" 2 "Father" 3 "Both"
	lab def hhdecision 1 "Mother" 2 "Father" 3 "Both" 4 "Other man" 5 "Other woman"
	lab def hh_dum 0 "Woman" 1 "Man or balanced"
	lab def hh_dum_rev 0 "Man" 1 "Woman or balanced"

	
	
/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

	
/* Survey Info _________________________________________________________________*/

	destring duration, gen(svy_duration)
		replace svy_duration = svy_duration / 60
	
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
									svy_enum==25 | ///
									svy_enum==1  | ///
									svy_enum==29 | ///
									svy_enum==30 | ///
									svy_enum==31 | ///
									svy_enum==32 | ///
									svy_enum==37 
								
									
									
	replace svy_enum_muslim = 0 if svy_enum_muslim == .

	rename id				id_resp_uid	
	rename district_pull	id_district_n
	rename ward_pull		id_ward_n
	rename village_pull		id_village_n

/* Consent _____________________________________________________________________*/

	rename consent consent														// HFC: Consent Check


/* Respondent Info ______________________________________________________________*/

	/* Name */
	rename resp_name 		resp_name_new
	rename name_pull		resp_name
		replace resp_name = resp_name_new if resp_name_new != ""

	rename s2q1_ppe resp_ppe

	/* Age */
	destring age_pull, 		gen(resp_age)
	gen resp_age_yr	=		2017-resp_age					// yob of main respondent

	gen resp_female = .
		replace resp_female = 1 if gender_pull == "Female"
		replace resp_female = 0 if gender_pull == "Male"
		lab val resp_female female 
		
	rename s1q3 	resp_howyoudoing
	
	rename s3q3_status 	resp_rltn_status
	gen resp_asmarried = 1 if resp_rltn_status == 1 | resp_rltn_status == 2
		replace resp_asmarried = 0 if resp_asmarried == . 
		lab var resp_asmarried "As married?"
		lab val resp_asmarried yesno

	rename s3q4 		resp_rltn_age						// age of partner
		recode resp_rltn_age (-999 = .d)(-222 = .d)
	
		
	gen resp_rltn_age_yr = 2020 - resp_rltn_age 			// yob 	of partner

	gen resp_married_yr = year(s3q5)						// year of marriage
		recode resp_married_yr (-999 = .d)

	gen resp_married_age = resp_married_yr - resp_age_yr				// age of main respondent at marriage
	gen resp_rltn_married_age = resp_married_yr - resp_rltn_age_yr		// age of partner at marriage

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

	rename s3q19_tribe			resp_tribe											// Need to input "other" -- BM: done.
		replace resp_tribe = 25 if s3q19_tribe_oth == "Wakinga"
		replace resp_tribe = 9  if s3q19_tribe_oth == "Mnyamwezi"
		replace resp_tribe = 19 if s3q19_tribe_oth == "Mbena"
		replace resp_tribe = 20 if s3q19_tribe_oth == "Waha" | s3q19_tribe_oth == "Muha"
		replace resp_tribe = 5 	if s3q19_tribe_oth == "Wakwele"
		replace resp_tribe = 14 if s3q19_tribe_oth == "Wakagulu" | s3q19_tribe_oth == "Mkaguru"
		replace resp_tribe = 4	if s3q19_tribe_oth == "Wangoni"
		replace resp_tribe = 6	if s3q19_tribe_oth == "Mpare" 
		replace resp_tribe = 40 if s3q19_tribe_oth == "Wanyasa"
		la def s3q19_tribe 40 "Wanyasa" , modify
		replace resp_tribe = 41 if s3q19_tribe_oth == "Wapangwa" | s3q19_tribe_oth == "Mpangwa" | s3q19_tribe_oth == "Mpangu"
		la def s3q19_tribe 41 "Wapangwa" , modify
		replace resp_tribe = 42 if s3q19_tribe_oth == "Wasegeju" | s3q19_tribe_oth == "Msegeji" | s3q19_tribe_oth == "Msegejo" | s3q19_tribe_oth == "Msegeju" 
		la def s3q19_tribe 42 "Wasegeju" , modify
		replace resp_tribe = 43 if s3q19_tribe_oth == "mpemba" | s3q19_tribe_oth == "Mpemba" | s3q19_tribe_oth == "Wapemba"
		la def s3q19_tribe 43 "Wapemba" , modify
		replace resp_tribe = 44 if s3q19_tribe_oth == "Washirazi" | s3q19_tribe_oth == "Shirazi" | s3q19_tribe_oth == "Mshirazi" | s3q19_tribe_oth == "Mshilazi"
		la def s3q19_tribe 44 "Washirazi" , modify
		replace resp_tribe = 45 if s3q19_tribe_oth == "Mnyamwanga" | s3q19_tribe_oth == "Wanyamwanga" | s3q19_tribe_oth == "wanyamwanga"
		la def s3q19_tribe 45 "Wanyamwanga" , modify
		replace resp_tribe = 46 if s3q19_tribe_oth == "Wamakua" | s3q19_tribe_oth == "wamakua" | s3q19_tribe_oth == "Wamakuwa" | s3q19_tribe_oth == "Mmakua"
		la def s3q19_tribe 46 "Wamakua" , modify
		replace resp_tribe = 47 if s3q19_tribe_oth == "MTUMBATU" | s3q19_tribe_oth == "Watumbatu" | s3q19_tribe_oth == "Mtumbatu"
		la def s3q19_tribe 47 "Watumbatu" , modify
		
		replace s3q19_tribe_oth = "" if 	s3q19_tribe_oth == "Wakinga" | s3q19_tribe_oth == "Mbena" | s3q19_tribe_oth == "Wakwele" | ////
											s3q19_tribe_oth == "Mnyamwezi" | s3q19_tribe_oth == "Waha" | s3q19_tribe_oth == "Muha" | ////
											s3q19_tribe_oth == "Wakagulu" | s3q19_tribe_oth == "Mkaguru" | ////
											s3q19_tribe_oth == "Wanyasa" | s3q19_tribe_oth == "Wapangwa" | ////
											s3q19_tribe_oth == "Wasegeju" | s3q19_tribe_oth == "Msegeji" | s3q19_tribe_oth == "Msegejo" | s3q19_tribe_oth == "Msegeju" | ////
											s3q19_tribe_oth == "mpemba" | s3q19_tribe_oth == "Mpemba" | s3q19_tribe_oth == "Wapemba" | ////
											s3q19_tribe_oth == "Washirazi" | s3q19_tribe_oth == "Shirazi" | s3q19_tribe_oth == "Mshirazi" | s3q19_tribe_oth == "Mshilazi" | ////
											s3q19_tribe_oth == "Mnyamwanga" | s3q19_tribe_oth == "Wanyamwanga" | s3q19_tribe_oth == "wanyamwanga" | ////
											s3q19_tribe_oth == "Wamakua" | s3q19_tribe_oth == "wamakua" | s3q19_tribe_oth == "Wamakuwa" | s3q19_tribe_oth == "Mmakua" | ////
											s3q19_tribe_oth == "Wakwele" | s3q19_tribe_oth == "Wakagulu" | s3q19_tribe_oth == "Mkaguru" | s3q19_tribe_oth == "Wangoni" | ////
											s3q19_tribe_oth == "Mpare" | s3q19_tribe_oth == "Mpangwa" | s3q19_tribe_oth == "Mpangu" | ////
											s3q19_tribe_oth == "MTUMBATU" | s3q19_tribe_oth == "Watumbatu" | s3q19_tribe_oth == "Mtumbatu"
	
	gen svy_date = 				startdate

	
/* General Values ______________________________________________________________*/


	** Gender difference in support for urbanization
	rename gender_txt		treat_values_urbangood_gender

	recode s5q1 			(0 = 1 "Do what you think is right")(1 = 0 "Pay attention to others"), ///
							gen(values_conformity)
		lab var values_conformity "[1 = No conformity] People should pay attention others or do what they think is right"
			
	recode s5q4				(0 = 1 "Question leaders")(1 = 0 "Respect authority"), ///
							gen(values_questionauthority)
		lab var values_questionauthority "[1 = Yes] People should question their leaders"
		
	recode s5q6				(1 = 0 "Support the family") (0 = 1 "Good to go to town") ///
							(-999 = .d) (-888 = .r), gen(values_urbangood)
		lab var values_urbangood "[1 = City] Should child go to town or stay in village after school?"

	recode s3q20_tz_tribe	(1 2 = 1 "TZ > Tribe") (3 4 5 .d = 0 "TZ <= Tribe") (-888 = .r "Refuse"), ///
							gen(values_tzovertribe_dum)
		lab var values_tzovertribe "[1 = TZ] Which feels more important to you, being a Tanzanian or being a ${tribe_txt}"

	rename s3q20_tz_tribe values_tzovertribe
	
	/* Recode */
	*recode values_* (-999 = .d) (-888 = .r)
	recode values_* (-999 = .) (-888 = .)

/* Efficacy ____________________________________________________________________*/

	rename s5q8				efficacy_understand
		lab def efficacy_understand 0 "Politics too complicated" 1 "Understand politics"
		lab val efficacy_understand efficacy_understand
		
	rename s5q9				efficacy_speakout
		lab def efficacy_speakout 0 "Dont have a say" 1 "Comfy speaking out"
		lab val efficacy_speakout efficacy_speakout
	
	/* Recode */
	recode efficacy_* (-999 = .d) (-888 = .r)


/* Prejudice ___________________________________________________________________*/

** People you would live near

	/* Create Values */
	gen prej_yesnbr_aids = .		
	gen prej_yesnbr_homo = .
	gen prej_yesnbr_alcoholic = .
	gen prej_yesnbr_unmarried = .

	forval j = 1/3 {	
		replace prej_yesnbr_homo = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mashoga"
		replace prej_yesnbr_aids = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Mtu mwenye virus vya ukimwi"
		replace prej_yesnbr_alcoholic = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Walevi"
		replace prej_yesnbr_unmarried = s5q5_r_`j' if s5q5_name_sw_r_`j' == "Watu wanaoishi pamoja lakini hawajaoana"
		}
		
	foreach var of varlist prej_yesnbr_* {
		lab var `var' "Would accept X group to be your nbr"
		recode `var' (1=0)(0=1)
		recode `var' (1=0)(0=1) if (svy_enum==5 | svy_enum==13 | svy_enum==10 | ///
		svy_enum==23 | svy_enum==24) & (startdate== td(07,12,2020) | startdate== td(08,12,2020))
		lab val `var' yesno
		recode `var' (-999 = .d)(-888 = .r)
	}	

	egen prej_yesnbr_index = rowmean(prej_yesnbr_aids prej_yesnbr_homo prej_yesnbr_alcoholic prej_yesnbr_unmarried)
	lab var prej_yesnbr_index "Mean of all questions about acceptable nbrs"


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
	forval i = 1/7 {
		gen prej_thermo`i' = .
			forval j = 1/7 {	
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
		
			gen prej_thermo_in_rel = prej_thermo_muslims if resp_muslim == 1
				replace prej_thermo_in_rel = prej_thermo_christians if resp_muslim == 0

		
		gen resp_tribe_digo = 1 if resp_tribe == 38				// digo
			replace resp_tribe_digo = 0 if resp_tribe == 32		// samba
		
		gen prej_thermo_out_eth = prej_thermo_digo if resp_tribe_digo == 0
			replace prej_thermo_out_eth = prej_thermo_sambaa if resp_tribe_digo == 1

			gen prej_thermo_in_eth = prej_thermo_digo if resp_tribe_digo == 1
				replace prej_thermo_in_eth = prej_thermo_sambaa if resp_tribe_digo == 0

			
			
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
		replace ptixpref_hiv_first = . if ptixpref_hiv == .
		lab var ptixpref_hiv_first "Ranked HIV First"
	
	gen ptixpref_hiv_topthree = (ptixpref_hiv == 9 | ///
								ptixpref_hiv == 8  | ///
								ptixpref_hiv == 7)
		replace ptixpref_hiv_topthree = . if ptixpref_hiv == .
		lab var ptixpref_hiv_topthree "Ranked HIV Top Three"
								
	gen ptixpref_hiv_notlast = (ptixpref_hiv != 2)
		replace ptixpref_hiv_notlast = . if ptixpref_hiv_notlast == .
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

	/* Partner Rank */
	rename s14q2_partner	ptixpref_partner_rank
		gen ptixpref_partner_hiv = (ptixpref_partner_rank == 9)
		gen ptixpref_partner_efm = (ptixpref_partner_rank == 3)
	
	* Local government
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

	
/* Election ____________________________________________________________________*/

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
											rand_cand`i'_txt == "Mrs. Mwanaidi"	// There were issues with this - check with Martin
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
		
	/* Gen Vote Pref 
		/* Muslim */
		gen vote_pref_muslim_1 = 1 if vote_elect1 == 1 & (cand1_muslim > cand2_muslim)
			replace vote_pref_muslim_1 = 1 if vote_elect1 == 0 & (cand1_muslim < cand2_muslim)
			
			replace vote_pref_muslim_1 = 0 if vote_elect1 == 1 & (cand1_muslim < cand2_muslim)
			replace vote_pref_muslim_1 = 0 if vote_elect1 == 0 & (cand1_muslim > cand2_muslim)
			
			replace vote_pref_muslim_1 = . if (cand1_muslim == cand2_muslim)
			
		gen vote_pref_muslim_2 = 1 if vote_elect2 == 1 & (cand3_muslim > cand4_muslim)
			replace vote_pref_muslim_2 = 1 if vote_elect2 == 0 & (cand3_muslim < cand4_muslim)
			
			replace vote_pref_muslim_2 = 0 if vote_elect2 == 1 & (cand3_muslim < cand4_muslim)
			replace vote_pref_muslim_2 = 0 if vote_elect2 == 0 & (cand3_muslim > cand4_muslim)
			
			replace vote_pref_muslim_2 = . if (cand3_muslim == cand4_muslim)
			
		egen vote_pref_muslim_index = rowmean(vote_pref_muslim_1 vote_pref_muslim_2)
	
		/* Female */
		gen vote_pref_female_1 = 1 if vote_elect1 == 1 & (cand1_female > cand2_female)
			replace vote_pref_female_1 = 1 if vote_elect1 == 0 & (cand1_female < cand2_female)
			
			replace vote_pref_female_1 = 0 if vote_elect1 == 1 & (cand1_female < cand2_female)
			replace vote_pref_female_1 = 0 if vote_elect1 == 0 & (cand1_female > cand2_female)
			
			replace vote_pref_female_1 = . if (cand1_female == cand2_female)
			
		gen vote_pref_female_2 = 1 if vote_elect2 == 1 & (cand3_female > cand4_female)
			replace vote_pref_female_2 = 1 if vote_elect2 == 0 & (cand3_female < cand4_female)
			
			replace vote_pref_female_2 = 0 if vote_elect2 == 1 & (cand3_female < cand4_female)
			replace vote_pref_female_2 = 0 if vote_elect2 == 0 & (cand3_female > cand4_female)
			
			replace vote_pref_female_2 = . if (cand3_female == cand4_female)
			
		egen vote_pref_female_index = rowmean(vote_pref_female_1 vote_pref_female_2)
		*/	

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
		
	lab val ge_school agree				
	lab val ge_work agree	
	lab val ge_leadership agree			
	lab val ge_business agree	

	lab var ge_school "[1 = No] It is more important that a boy goes to school than a girl"
	lab var ge_work "[1 = No] When jobs are scarce, men should have more right to a job than women"
	lab var ge_leadership "In general, women make equally good village leaders as men"
	lab var ge_business "In general, women are just as able to run a successful business as men"
		
	recode ge_* (-999 = .d) (-888 = .r)

	egen ge_index = rowmean(ge_school ge_work ge_leadership ge_business)

	/* HH Labor */
	forval i = 1/3 {
		gen ge_hhlabor`i' = .
			forval j = 1/3 {	
				replace ge_hhlabor`i' = s8q5_r_`j' if s8q5_index_r_`j' == "`i'"	// Need to change this back to "2"
			}
		lab var ge_hhlabor`i' "Who is ideally responsible for X?"
		lab val ge_hhlabor`i' ge_hhlabor
	}
		rename ge_hhlabor1 		ge_hhlabor_chores								// Not sure this is coded right
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
	
	egen ge_hhlabor_index = rowmean(ge_hhlabor_chores_dum ge_hhlabor_kids_dum ge_hhlabor_money_dum)
	lab var ge_hhlabor_index "Index of 3 HH IDEAL labor questions"
	
	egen ge_hhlabor_2index = rowmean(ge_hhlabor_chores_dum ge_hhlabor_money_dum)
	lab var ge_hhlabor_2index "Index of 2 HH IDEAL labor questions"
		
/* Forced Marriage _____________________________________________________________*/

	rename s8q5			fm_reject
		recode fm_reject (1=0)(2=1)(-999 = .d)(-888 = .r)
		lab var fm_reject "[1 = No] A woman should not have a say in who she marries"
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
		
	* rename s15q7	ptixpart_contact_satisfied // dropped after pilot
	



/* Women's Political Participation _____________________________________________

	Note: This is also an experiment
	
*/
	
	rename s21_txt_treat treat_wpp

	rename s21q1	wpp_attitude // In general, do you think that political leaders in Tanzania should be mostly men, mostly women, or that there should be equal numbers of men and women?
		gen wpp_attitude_dum = 1 if wpp_attitude == 1 | wpp_attitude == 2
		replace wpp_attitude_dum = 0 if wpp_attitude == 0
		lab var wpp_attitude_dum "Who should lead? Equal women or more women"
		lab def wpp_attitude_dum 0 "Men" 1 "Equal or more women"
		lab val wpp_attitude_dum wpp_attitude_dum
		
	rename s21q2	wpp_norm

		gen wpp_norm_dum = 1 if wpp_norm == 1 | wpp_norm == 2
		replace wpp_norm_dum = 0 if wpp_norm == 0
		lab var wpp_norm_dum "Who should lead? Equal women or more women"
		
	rename s21q3	wpp_behavior
	rename s21q4	wpp_partner

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

	rename s17q5b_new	em_norm_reject_bean

	rename s17q5c		em_hearddiscussed

	rename s17q5d		em_hearddiscussed_often
		replace em_hearddiscussed_often = 1 if em_hearddiscussed == 0
		
	gen treat_pi = 1 if em_txt_treat == "treat"
		replace treat_pi = 0 if em_txt_treat == "control"
		lab val treat_pi treatment
		lab var treat_pi "Pluralistic Ignorance Treatment"

	destring emcount_pull_10, gen(b_em_comreject_pct)

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

	rename s17q9 		em_record_reject
		replace em_record_reject = 0 if em_record_any == 0

	gen em_record_accept = 1         if em_record_reject == 0 & em_record_any == 1
		replace em_record_accept = 0 if em_record_any == 0
		replace em_record_accept = 0 if em_record_any == 1 & em_record_reject == 1 	
	 /*gen em_record_accept = (em_record_reject == 0)
	 		replace em_record_accept = . if em_record_reject == . */
	
		
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

	/* Popular Culture */
	gen ptixknow_pop_music = .
		replace ptixknow_pop_music = 1 if (s13q1a == 4 | s13q1a == 3) 
		replace ptixknow_pop_music = 0 if (s13q1a == 5 | s13q1a == -999 | s13q1a == .d | s13q1a == 1) 
		lab val ptixknow_pop_music correct

	gen ptixknow_pop_sport = .
		replace ptixknow_pop_sport = 1 if (s13q1b == 1 | s13q1a == 2) 
		replace ptixknow_pop_sport = 0 if (s13q1b == 4 | s13q1b ==  5 | s13q1b == .d) 
		lab val ptixknow_pop_sport correct
	
	rename s13q2 	ptixknow_local_dc 

	/* National Politics */
	rename s13q3a	 ptixknow_natl_pm 
		recode ptixknow_natl_pm (2=1)(1=0)(4=0)(3=0)(-999=0)

	rename s13q3b	ptixknow_natl_justice
		recode ptixknow_natl_justice (3=0)(1=0)(2=0)(4=1)(-999=0)

	lab val ptixknow_natl_* correct

	/* Foreign Affairs */
	rename s13q4new ptixknow_fopo_kenyatta 
		recode ptixknow_fopo_kenyatta (-999 = 0) (-222 = 0) (-888 = 0) (2 = 1) (1 = 0) 
		lab def ptixknow_fopo_kenyatta 0 "Wrong" 1 "Close" 2 "Correct"

	rename s13q5		ptixknow_em_aware
	// this is from the pilot, we decided Endline was only going to have PI and not COURTS experiment
	*	replace ptixknow_em_aware = s17q1_intro if s17_txt_treat == "treat_both" | s17_txt_treat == "treat_court" 	
	*	destring ptixknow_em_aware, replace

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

	egen ptixknow_pop_index = rowmax(ptixknow_pop_sport  ptixknow_pop_music)
	egen ptixknow_natl_index = rowmax(ptixknow_natl_pm   ptixknow_natl_justice)
	

		
/* Health Knowledge ____________________________________________________________*/

	recode s23q1 			(0=1 "Cant cure disease") (1 .d =0 "Can cure disease / don't know"),	///
							gen(healthknow_notradmed)
	lab var healthknow_notradmed "[1 = No] Can payer and trad. medicine help cure disease?"

	rename s23q2			healthknow_vaccines
	
	recode s23q3			(0 1 .d = 0 "Not very important") (2 = 1 "Very important"), ///
							gen(healthknow_vaccines_imp)
	lab var healthknow_vaccines_imp "[2 = very important] In your opinion, how important is it for a healthy young child to receive vaccine?"
	replace healthknow_vaccines_imp = 0 if healthknow_vaccines == 0
		
	recode s23q4			(0 = 1 "Withcraft does not exist") (1 .d = 0 "Witchraft does exist / don't know"), ///
							gen(healthknow_nowitchcraft)
	lab var healthknow_nowitchcraft "[1 = No] Believe in witchcraft?"

	foreach var of varlist healthknow_* {
		cap recode `var' (-999 = 0)(-222 = 0)(-888 = .r)
	}

/* HIV Knowledge _______________________________________________________________*/

	gen hivknow_arv_survive = .
		replace hivknow_arv_survive = 1 if strpos(s_hiv_livelong, "1") 
		replace hivknow_arv_survive = 1 if strpos(s_hiv_livelong, "2") 	
		replace hivknow_arv_survive = 0 if s_hiv_livelong != "" & hivknow_arv_survive != 1 

	gen hivknow_arv_nospread = .
		replace hivknow_arv_nospread = 1 if strpos(s_hiv_nospread, "1")
		replace hivknow_arv_nospread = 0 if s_hiv_nospread != "" & hivknow_arv_nospread != 1
		
	gen hivknow_arv_any = .
		replace hivknow_arv_any = 1 if strpos(s_hiv_livelong, "1") 
		replace hivknow_arv_any = 1 if strpos(s_hiv_nospread, "1")
		replace hivknow_arv_any = 1 if s_hiv_antiretroviral == 1
		replace hivknow_arv_any = 0 if s_hiv_antiretroviral == 0
		
	recode  s_hiv_transmitted (1=0 "Yes")(0=1 "No"), gen(hivknow_transmit)
		lab var hivknow_transmit "[Reversed] Can HIV be spread to other people?"
		
	cap recode hivknow_* (-999 = 0)(-222 = 0)(-888 = .r)

	egen hivknow_index = rowmean(hivknow_arv_survive hivknow_arv_nospread hivknow_transmit)

/* HIV Stigma _______________________________________________________________*/

	rename s_hiv_stigma1 		hivstigma_notfired	

	rename s_hiv_stigma1_norm	hivstigma_notfired_norm

	rename s_hiv_stigma2		hivstigma_yesbus
	
	recode hivstigma_* (-999 = .d)(-888 = .r)(-222 = .o)

	egen hivstigma_index = rowmean(hivstigma_notfired hivstigma_yesbus)


/* HIV Disclosure _______________________________________________________________*/

	rename s_hiv_secret			hivdisclose_nosecret
		recode hivdisclose_nosecret (0=1)(1=0)
		lab var hivdisclose_nosecret "[Reverse] Prefer family member keep HIV secret?"

	rename s_disclose_family_b	hivdisclose_friend
	rename s_disclose_family_c	hivdisclose_cowork
	
	recode hivdisclose_* (-999 = .d)(-888 = .r)(-222 = .o)

	egen hivdisclose_index = rowmean(hivdisclose_friend hivdisclose_cowork hivdisclose_nosecret)


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

	egen ipv_rej_index_v0 	= rowmean(ipv_rej_disobey ipv_rej_hithard ipv_rej_persists)
		
	rename s9q2 			ipv_norm_rej
		recode ipv_norm_rej (1=0)(0=1)(-999 = .d)(-888 = .r)	
		lab val ipv_norm_rej ipv
		
	** Create extended measure
	gen ipv_rej_disobey_long = .
		replace ipv_rej_disobey_long = 0 if ipv_rej_hithard == 0 & ipv_rej_disobey == 0
		replace ipv_rej_disobey_long = 1 if ipv_rej_hithard == 1 & ipv_rej_disobey == 0
		replace ipv_rej_disobey_long = 2 if ipv_rej_persists == 0 & ipv_rej_disobey == 1
		replace ipv_rej_disobey_long = 3 if ipv_rej_persists == 1 & ipv_rej_disobey == 1
		lab def ipv_rej_long 0 "Hit, hard" 1 "Hit, not hard" 2 "Dont hit, unless persists" 3 "Dont hit, even if persists"
		lab val ipv_rej_disobey_long ipv_rej_long

	rename s9q3		ipv_report
		recode ipv_report (2=0)(1=1)	
		lab var ipv_report "Report IPV to police?"
		lab val ipv_report report
		
	recode ipv_* (-999 = .d)(-888 = .r)		

/* HH Labor _____________________________________________________________________*/

	/* Actual HH Labor (Attitudes twowards HH Labor are above) */
	rename s12q1_1		hhlabor_water
	rename s12q1_2		hhlabor_laundry
	rename s12q1_3		hhlabor_kids
	rename s12q1_4		hhlabor_money
		
		foreach var of varlist hhlabor_* {
			lab val `var' hhlabor
		}
		
	/* Generate Dummy Variable for Outcome */
	recode hhlabor_water (2=1)(3=1)(1=0), gen(hhlabor_water_dum)
		lab val hhlabor_water_dum hh_dum
		lab var hhlabor_water_dum "[1 = prog/bal] Who in HH is responsible for water?"
	
	recode hhlabor_laundry (2=1)(3=1)(1=0), gen(hhlabor_laundry_dum)
		lab val hhlabor_laundry_dum hh_dum
		lab var hhlabor_laundry_dum "[1 = prog/bal] Who in HH is responsible for laundry?"
		
	egen hhlabor_chores_dum = rowmean(hhlabor_water_dum hhlabor_laundry_dum)
		lab var hhlabor_chores_dum "[1 = prog/bal] Who in HH is responsible for chores?"
	
	recode hhlabor_kids (2=1)(3=1)(1=0), gen(hhlabor_kids_dum)
		lab val hhlabor_kids_dum hh_dum
		lab var hhlabor_kids_dum "[1 = prog/bal] Who in HH is responsible for kids?"
	
	recode hhlabor_money (2=0)(3=1)(1=1), gen(hhlabor_money_dum)
		lab val hhlabor_money_dum hh_dum_rev
		lab var hhlabor_money_dum "[1 = prog/bal] Who in HH is responsible for money?"
	
	recode hhlabor* (-999 = .d)(-888 = .r)		

	egen hhlabor_index = rowmean(hhlabor_chores_dum hhlabor_kids_dum hhlabor_money_dum)
	lab var hhlabor_index "Index of 3 HH labor questions"
	
	egen hhlabor_2index = rowmean( hhlabor_chores_dum  hhlabor_money_dum)
	lab var hhlabor_2index "Index of 2 HH IDEAL labor questions"


/* HH Decisions _____________________________________________________________________*/

	/* HH Decision-making (actual) */
	rename s12q12_1		hhdecision_health
	rename s12q12_2		hhdecision_school
	rename s12q12_3		hhdecision_hhfix
	
		foreach var of varlist hhdecision_* {
			lab val `var' hhdecision
		}
		
	/* Generate Dummy Variable for Outcome */
	recode hhdecision_health (2=1)(3=1)(1=0)(4=1)(5=0), gen(hhdecision_health_dum)
		lab val hhdecision_health hh_dum
		lab var hhdecision_health "[1 = progressive/balanced] Who in HH makes decisions about health?"
		
	recode hhdecision_school (2=1)(3=1)(1=0)(4=1)(5=0), gen(hhdecision_school_dum)
		lab val hhdecision_school_dum hh_dum
		lab var hhdecision_school_dum "[1 = progressive/balanced] Who in HH makes decisions about school?"
		
	recode hhdecision_hhfix (2=1)(3=1)(1=0)(4=1)(5=0), gen(hhdecision_hhfix_dum)
		lab val hhdecision_hhfix_dum hh_dum
		lab var hhdecision_hhfix_dum "[1 = progressive/balanced] Who in HH makes decisions about hh fixes?"
	
	recode hhdecision* (-999 = .d)(-888 = .r)		

	egen hhdecision_index = rowtotal(hhdecision_school_dum hhdecision_hhfix_dum)
		lab var hhdecision_index "Index of two hhdecision questions"
	
	
/* Relationships _______________________________________________________________*/

	/* Couples Info */
	rename s12q13_1		couples_talk_news
	rename s12q13_2		couples_talk_kids
	rename s12q13_9		couples_talk_none

	rename s12q14		couples_autonomy
		recode couples_autonomy (4=0) (3=1) (2=2) (1=3)
		la de couples_autonomy 0 "Always" 1 "Most times" 2 "Sometimes" 3 "Never" , modify
		la val couples_autonomy couples_autonomy
 		lab var couples_autonomy "Partner prohibits you going to maket / friends"
		
	recode couples* (-999 = .d)(-888 = .r)	


/* Parenting ___________________________________________________________________*/

	rename s11q0		parent_hhkids_any


	rename s11q3		parent_question
		recode parent_question (2=1) (1=0)
		lab def parent_question 0 "Agree" 1 "Disagree"
		lab val parent_question parent_question
		lab var parent_question "Agree (0) or Disagree (1): Parents should NOT allow children to question their decisions"
		
	rename s11q4a		parent_control_activities
	rename s11q4b		parent_control_punish
	rename s11q4c		parent_responsive_praise
	rename s11q4d		parent_responsive_school

	rename s11q1		parent_currentevents
		gen parent_currentevents_dum = (parent_currentevents > 1)

	rename s11q5_1		parent_talk_newspols
	rename s11q5_2		parent_talk_school
	rename s11q5_3		parent_talk_community
	rename s11q5_4		parent_talk_entertainment
	rename s11q5_0		parent_talk_none

	
/* Media Consumption ___________________________________________________________*/

	rename s4q2_listen_radio	radio_listen							
		lab def s4q2_listen_radio 0 "Never", modify
		lab val radio s4q2_listen_radio

	gen radio_any = 1 if radio_listen > 0
	replace radio_any = 0 if radio_listen == 0
		
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
		
	** Uhuru / Pangani FM	
	rename s4q14				radio_uhuru
	rename s4q15				radio_pfm_call
		replace radio_uhuru = 1 if radio_stations_uhuru == 1
		replace radio_uhuru = 0 if radio_ever == 0

	** Group Listening
	rename s4q7					radio_group
	rename s4q8					radio_group_who

	** Reports
	rename s4q12_ward_leader		radio_locleader
	rename s4q13_ntl_leader			radio_natleader								


/* Assetts _____________________________________________________________________*/

	rename s16q1		assets_radio
	rename s16q2		assets_radio_num
		replace assets_radio_num = 0 if assets_radio == 0
	rename s16q3		assets_radio_self
	rename s16q4		assets_electricity
	rename s16q5		assets_rooftype

		foreach var of varlist assets_* {
			recode `var' (-999 = .d)(-888 = .r)(-222 = .o)
	}

/* Psychology _________________________________________________________________*/

	rename s19q1		psych_thinkhard
			lab def thinkhard 1 "Dont like to think" 2 "Like to think"
			lab val psych_thinkhard thinkhard

	rename s19q2		psych_newideas
			lab def newideas 1 "Turn off thoughts" 2 "Like new ideas"
			lab val psych_newideas newideas

	rename s19q3		psych_immerse
			lab def immerse 1 "Get lost in stories/music" 2 "Dont get lost in stories/music"
			lab val psych_immerse immerse

		
/* Radio Distribution Compliance _______________________________________________*/

	rename treat_rd_pull treat_rd_pull 

	rename s30q1		rd_receive
	rename s30q2		rd_stillhave
	rename s30q3		rd_stillhave_whyno
	rename s30q4		rd_stillhave_show
	rename s30q5		rd_working
	rename s30q6		rd_working_whynot

	cap rename s30q7		rd_controls
	cap rename s30q9		rd_problems
	cap rename s30q10		rd_challenge
		cap rename s30q10_1 	rd_challenge_jealous
		cap rename s30q10_2 	rd_challenge_mistrust
		cap rename s30q10_3		rd_challenge_fight
		cap rename s30q10_oth	rd_challenge_oth
	

/* Audio Screening Compliance __________________________________________________*/

	rename s31q1		comply_topic
	rename s31q2		comply_discuss
	rename s31q3		comply_discuss_who

	
/* Friend Sampling __________________________________________________________	*/	

	/* Person 1 */
	rename s33q1_r		comsample_1_name
		replace comsample_1_name = "" if comsample_1_name == "000"
		replace comsample_1_name = "" if comsample_1_name == "-888"
		replace comsample_1_name = "" if comsample_1_name == "Hana mtu"
		replace comsample_1_name = "" if comsample_1_name == "Hakuna zaidi ya familia yangu"
		
	gen comsample_1_none = 1 if comsample_1_name == ""
	
	rename s33q2_r		comsample_1_rltn
	
		lab def s33q2_r 11 "Aunt/Uncle" 12 "Nephew/Neice" 13 "Parent in law" ///
						14 "Sibling in law" 15 "Child in law" ///
						16 "Granddaughter/son" 17 "Children" 18 "Spouse", modify	
 	
		replace comsample_1_rltn = . if s33q2_oth_r == "Hana mtu"
		replace comsample_1_rltn = . if s33q2_oth_r == "Hakuna zaidi ya familia yangu"
		replace comsample_1_rltn = . if comsample_1_name == "-888"

		replace comsample_1_rltn = 11 if s33q2_oth_r == "Baba Mdogo" | ///
										 s33q2_oth_r == "Baba mdogo" | ///
										 s33q2_oth_r == "Mama mdogo" | ///
										 s33q2_oth_r == "Mama kubwa" | ///
										 s33q2_oth_r == "Mama mkubwa"
										 
		replace comsample_1_rltn = 12 if s33q2_oth_r == "Mtoto wa kaka" | ///
										 s33q2_oth_r == "Mtoto wa kaka yake"
		
		replace comsample_1_rltn = 13 if s33q2_oth_r == "Mama mkwe" | ///
										 s33q2_oth_r == "Mother inlaw"
		
		replace comsample_1_rltn = 14 if s33q2_oth_r == "Brother In-law" | ///
										 s33q2_oth_r == "Brother in law" | ///
										 s33q2_oth_r == "Mke wa kaka yake" | ///
										 s33q2_oth_r == "Mke wa kaka yake(wifi)" | ///
										 s33q2_oth_r == "Mke wa shemeji yangu" | ///
										 s33q2_oth_r == "Shemeji" | ///
										 s33q2_oth_r == "Shemeji yake" | ///
										 s33q2_oth_r == "Sister in law" | ///
										 s33q2_oth_r == "Wifi" | ///
										 s33q2_oth_r == "Wifi yangu"
										 
		replace comsample_1_rltn = 18 if s33q2_oth_r == "Mjengezi Mwenzangu" | ///
										s33q2_oth_r == "Mke mwenza" | ///
										s33q2_oth_r == "Mke mwenza" | ///
										s33q2_oth_r == "Mke" | ///
										s33q2_oth_r == "Mkemwenza" | ///
										s33q2_oth_r == "Mke mwenzangu" | ///
										s33q2_oth_r == "Mke Mwenzangu" | ///
										s33q2_oth_r == "Mjengezi mwenzangu"
										 
		replace comsample_1_rltn = 15 if  s33q2_oth_r == "Mkwe (daughter inlaw)" | ///
										  s33q2_oth_r == "Mkwe"
										 
		replace comsample_1_rltn = 16 if s33q2_oth_r == "Mjukuu" | ///
										 s33q2_oth_r == "Mjukuu kwake"
										  
		replace comsample_1_rltn = 17 if s33q2_oth_r == "Mtoto wake" | ///
										 s33q2_oth_r == "Mtoto wangu"
										 		 
		replace comsample_1_rltn = 1 if s33q2_oth_r == "Young brother"
		
		replace comsample_1_rltn = 4 if s33q2_oth_r == "Mdogo ake" | ///
										s33q2_oth_r == "Mdogo wake"
																
		replace comsample_1_rltn = 9 if id_resp_uid == "3_41_3_34" | ///
										s33q2_oth_r == "Kiongozi wa dini"
		
		replace comsample_1_rltn = 10 if s33q2_oth_r == "Jirani" | ///
										 s33q2_oth_r == "Jirani yake"
				
	
	gen comsample_1_fam = .	
		forval i = 1/5 {
			replace comsample_1_fam = 1 if comsample_1_rltn == `i'
		}
		forval i = 17/18 {
			replace comsample_1_fam = 2 if comsample_1_rltn == `i'
		}
		forval i = 6/16 {
			replace comsample_1_fam = 0 if comsample_1_rltn == `i'
		}


	/* Person 2 _________________________________________________________________*/
	
	rename s33q3_a		comsample_2_name

	replace comsample_2_name = s33q3_b if 	comsample_1_fam == 1
			replace comsample_2_name = "" if comsample_2_name == "000"
			replace comsample_2_name = "" if comsample_2_name == "000"
			replace comsample_2_name = "" if comsample_2_name == "-888"
			replace comsample_2_name = "" if comsample_2_name == "Hana mtu"
			replace comsample_2_name = "" if comsample_2_name == "Hakuna zaidi ya familia yangu"
										
	rename s33q3_a_r	comsample_2_rltn
		replace comsample_2_rltn = s33q3_b_r if comsample_1_fam == 1
		
	rename s33q3_a_oth	comsample_2_rltn_oth
		replace comsample_2_rltn_oth = s33q3_b_oth if comsample_1_fam == 1
											
		replace comsample_2_rltn = . if comsample_2_rltn_oth == "-000" | ///
										comsample_2_rltn_oth == "-888" | ///
										comsample_2_rltn_oth == "000" | ///
										comsample_2_rltn_oth == "Hakuna" | ///
										comsample_2_rltn_oth == "Hakuna mwingine" | ///
										comsample_2_rltn_oth == "Hakuna mwingine" | ///
										comsample_2_rltn_oth == "Hakuna zaidi ya ndugu" | ///
										comsample_2_rltn_oth == "Hakuna mtu wa pili" | ///
										comsample_2_rltn_oth == "Hakuna mtu mwingine"| ///
										comsample_2_rltn_oth == "Hana mwengine" | ///
										comsample_2_rltn_oth == "Hana rafiki" | ///
										comsample_2_rltn_oth == "Hana rafiki au mtu wa karibu" | ///
										comsample_2_rltn_oth == "Hanaa" | ///
										comsample_2_rltn_oth == "Hana" | ///
										comsample_2_rltn_oth == "Sina"
										
		replace comsample_2_rltn = 1 if comsample_2_rltn_oth == "Mdogo ake" | ///
										 comsample_2_rltn_oth == "Modogo wake" 
										 
		replace comsample_2_rltn = 10 if comsample_2_rltn_oth == "Jirani" | ///
										 comsample_2_rltn_oth == "Jirani karibu" | ///
										 comsample_2_rltn_oth == "Jirani yake pia"
		
		replace comsample_1_rltn = 11 if comsample_2_rltn_oth == "Mama mdogo" | ///
										 comsample_2_rltn_oth == "Mtoto wa babu"
										 
		replace comsample_1_rltn = 12 if comsample_2_rltn_oth == "Mtoto wa kaka" | ///
										 comsample_2_rltn_oth == "Mtoto wa mdogo wake"
		
		replace comsample_1_rltn = 13 if comsample_2_rltn_oth == "Baba mkwe" | ///
										 comsample_2_rltn_oth == "Mother inlaw"
		
		replace comsample_2_rltn = 14 if comsample_2_rltn_oth == "Brother inlaw" | ///
										 comsample_2_rltn_oth == "Shemeji" | ///
										 comsample_2_rltn_oth == "Sister in law" | ///
										 comsample_2_rltn_oth == "Sistern inlaw"

		replace comsample_2_rltn = 16 if comsample_2_rltn_oth == "Mjukuu"
		
		replace comsample_2_rltn = 15 if comsample_2_rltn_oth == "Mkaza mwanangu (mkwe wangu)" | ///
										 comsample_2_rltn_oth == "Mkwe wako" | ///
										 comsample_2_rltn_oth == "Mkwe wangu"
										 
		replace comsample_2_rltn = 17 if comsample_2_rltn_oth == "Mtoto" | ///
										 comsample_2_rltn_oth == "Mtoto wake" | ///
										 comsample_2_rltn_oth == "Mtoto wangu ambae anaishi jirani"
		
		replace comsample_2_rltn = 12 if comsample_2_rltn_oth == "Mtoto wa kaka" | ///
										 comsample_2_rltn_oth == "Mtoto wa Kaka"

		replace comsample_2_rltn = 18 if comsample_2_rltn_oth == "Wifi" | ///
										 comsample_2_rltn_oth == "Wifi yangu" | ///
										 comsample_2_rltn_oth == "Wiki yake" | ///
										 comsample_2_rltn_oth == "Fiance" | ///
										 comsample_2_rltn_oth == "Mke Mwenzangu" | ///
										 comsample_2_rltn_oth == "Mke Mwenzio" | ///
										 comsample_2_rltn_oth == "Mke mwenzangu" | ///
										 comsample_2_rltn_oth == "Mkwe" 
	
		lab val comsample_2_rltn s33q2_r
		
	gen comsample_2_fam = .	
		forval i = 1/5 {
			replace comsample_2_fam = 1 if comsample_2_rltn == `i'
		}
		forval i = 17/18 {
			replace comsample_1_fam = 2 if comsample_1_rltn == `i'
		}
		forval i = 6/16 {
			replace comsample_1_fam = 0 if comsample_1_rltn == `i'
		}

/* Children Sampling ___________________________________________________________*/

	rename s7q1			kidssample_kidnum

	forval i = 1/12 {
		rename s7q5_first_name_r_`i'	kidssample_namefirst_`i'
		rename s7q5_second_name_r_`i'	kidssample_namesecond_`i'
		rename s7q5_third_name_r_`i'	kidssample_namethird_`i'
		
		egen kidssample_fullname_`i' = concat(kidssample_namefirst_`i'  kidssample_namesecond_`i' kidssample_namethird_`i'), punct(" ")
		
		rename s7q6_old_r_`i'			kidssample_age_`i'
		rename s7q7_gender_r_`i'		kidssample_gender_`i'
	}
	
	rename s7q9			kidssample_consent
	
	* Does the person have at least one daughter (older than 13?)
		egen temp = rowmean(kidssample_gender_*)
		gen daughters = (temp > 1)
		drop temp
	
/* Conclusion __________________________________________________________________*/

	rename s20q1				svy_followupok
	
	rename s20q1b 				svy_phonenum 
	rename s20q1b_oth			svy_phonenum2 

	rename s20q2latitude		svy_gps_lat
	rename s20q2longitude		svy_gps_long		

	rename s20q3				svy_others
	rename s20q4_sm				svy_others_who


	
/* Export ______________________________________________________________________*/

	gen endline_as = 1

/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)
	
	* Within folder
	save "${data}/01_raw_data/pfm_as_endline_clean.dta", replace




*-------------------------------------------------------------------------------
* Project: Pangani FM 2
* File: FollowUp Pilot Import and Cleaning
* Date: 8/7/2019
* Author: Dylan Groves, dgroves@poverty-action.org
* Overview: This cleans data for high frequency checks on the follow up data
*-------------------------------------------------------------------------------

** NOTES
** Need to drop dates from piloting


/* Introduction ________________________________________________________________*/

	clear all
	set maxvar 30000
	set more off


/* Import Data  ________________________________________________________________*/

	use "${data}/01_raw_data/03_surveys/pfm_as_midline_nopii.dta", clear


/* Clean Data  _________________________________________________________________*/

	* Labels
	lab def yesno 0 "No" 1 "Yes"
	lab def female 0 "Male" 1 "Female"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def reject 0 "Accept" 1 "Reject"
	lab def report 1 "Report" 0 "Dont Report"
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

	* Converting don't know/refuse/other to extended missing values
	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

	gen as_midline = 1
	
/* General Information  ________________________________________________________*/

	rename s1q1 svy_date
	drop pre_district
	rename pre_district_name svy_district_name
	rename pre_ward svy_ward
	rename pre_subvillage_name svy_subvillage
	rename s1q2 svy_visits
	rename s1q3 svy_matchbaseline	
	drop submissiondate
	drop isvalidated
	drop pre_village
	rename time_1 date	


/* Respondent Info _____________________________________________________________*/

	rename s2q1 resp_gender
	rename s2q2 resp_howudoin
	rename s2q4 resp_villageleader

	rename s2q5 s2q4_discussions													

	replace s2q4_discussions = subinstr(s2q4_discussions, "-999", "dontknow",.)		// Switch out scubstrings
	replace s2q4_discussions = subinstr(s2q4_discussions, "-888", "refuse",.)

	gen s2q4_discussions_electric = 1 if strpos(s2q4_discussions, "1")				// NEED TO
	gen s2q4_discussions_ipv = 1 if strpos(s2q4_discussions, "2")
	gen s2q4_discussions_discrim = 1 if strpos(s2q4_discussions, "3")
	gen s2q4_discussions_ptix = 1 if strpos(s2q4_discussions, "4")
	gen s2q4_discussions_water = 1 if strpos(s2q4_discussions, "5") 	
	gen s2q4_discussions_hiv = 1 if strpos(s2q4_discussions, "6") 	
	gen s2q4_discussions_stealing = 1 if strpos(s2q4_discussions, "7") 	
	gen s2q4_discussions_fm = 1 if strpos(s2q4_discussions, "8")
	gen s2q4_discussions_none = 1 if strpos(s2q4_discussions, "9") 		
	gen s2q4_discussions_dontknow = 1 if strpos(s2q4_discussions, "donknow") 	
	gen s2q4_discussions_refuse = 1 if strpos(s2q4_discussions, "refuse")

	lab def yesnodiscuss 0 "Didnt Dicuss" 1 "Discussed"

	foreach var of varlist s2q4_discussions_* {
		replace `var' = 0 if `var' == .
		lab val `var' yesnodiscuss
	}

	egen s2q4_discussions_total = rowtotal(s2q4_discussions_*)
	lab var s2q4_discussions_total "Total discussions"

/* Section 3 - Civic Engagment _________________________________________________*/
	
	rename s3q1 s3q1_ptix_interest
	rename s3q2 s3q2_ptix_contact

	* Political Contacts
	gen s3q2_ptix_contact_vc = 1 if strpos(s3q2_ptix_contact, "1")				
	gen s3q2_ptix_contact_veo = 1 if strpos(s3q2_ptix_contact, "2")
	gen s3q2_ptix_contact_weo = 1 if strpos(s3q2_ptix_contact, "3")
	gen s3q2_ptix_contact_wc = 1 if strpos(s3q2_ptix_contact, "4")
	gen s3q2_ptix_contact_ppo = 1 if strpos(s3q2_ptix_contact, "6") 	
	gen s3q2_ptix_contact_tl = 1 if strpos(s3q2_ptix_contact, "7") 	
	gen s3q2_ptix_contact_rl = 1 if strpos(s3q2_ptix_contact, "8") 	
	gen s3q2_ptix_contact_none = 1 if strpos(s3q2_ptix_contact, "9")

	foreach var of varlist s3q2_ptix_contact_* {
		replace `var' = 0 if `var' == .
	}

	egen s3q2_ptix_contact_total = rowtotal(s3q2_ptix_contact_*)
	lab var s3q2_ptix_contact_total "Total political contacts"

	* Priorities
	rename s3q3_a food_priority_list
	rename s3q3_b em_priority_list
	rename s3q3_c road_priority_list
	rename s3q3_e elect_priority_list
	rename s3q3_f crime_priority_list
	rename s3q3_g hiv_priority_list
	
	
	* As in endline: 
	
				/* HIV Ranking */
			gen ptixpref_hiv_topthree = (hiv_priority_list == 1 | ///
										hiv_priority_list == 2  | ///
										hiv_priority_list == 3)
				lab var ptixpref_hiv_topthree "Ranked HIV Top Three"
										
			/* EFM Ranking */	
			gen ptixpref_efm_topthree = (em_priority_list == 1 | ///
										em_priority_list == 2  | ///
										em_priority_list == 3)
				lab var ptixpref_efm_topthree "Ranked EFM Top Three Preferences"
										
	* Only for midline
	
	/* Fix rank orderings to account for effec ton other side */
	replace em_priority_list = 0 if em_priority_list == -1
	replace em_priority_list = 2 if em_priority_list == 1 & hiv_priority_list > 1
	replace em_priority_list = 3 if em_priority_list == 2 & hiv_priority_list > 2
	
	replace hiv_priority_list = 0 if hiv_priority_list == -1
	replace hiv_priority_list = 2 if hiv_priority_list == 1 & em_priority_list > 1
	replace hiv_priority_list = 3 if hiv_priority_list == 2 & em_priority_list > 2

	foreach var in *_priority_list {
		recode `var' (. = 0)
	}

	
	* Election
	lab def vote 1 "1st Candidate" 2 "2nd Candidate"
	lab def vote_male 1 "Male" 0 "Female"
	lab def vote_islam 1 "Islam" 0 "Christian"
	
	rename s3q4a vote_1
	rename s3q4b vote_2
	
	gen vote_fmhiv = .
		replace vote_fmhiv = 1 if rand_promise1_txt == "fight against child marriage" & rand_promise2_txt == "make hiv-aids treatment more available"
		replace vote_fmhiv = 1 if rand_promise2_txt == "fight against child marriage" & rand_promise1_txt == "make hiv-aids treatment more available"
		replace vote_fmhiv = 1 if rand_promise3_txt == "fight against child marriage" & rand_promise4_txt == "make hiv-aids treatment more available"
		replace vote_fmhiv = 1 if rand_promise4_txt == "fight against child marriage" & rand_promise3_txt == "make hiv-aids treatment more available"

	gen em_elect = 0
		replace em_elect = 1 if vote_1 == 1 & rand_promise1_txt == "fight against child marriage"
		replace em_elect = 1 if vote_1 == 2 & rand_promise2_txt == "fight against child marriage"
		replace em_elect = 1 if vote_2 == 1 & rand_promise3_txt == "fight against child marriage"
		replace em_elect = 1 if vote_2 == 2 & rand_promise4_txt == "fight against child marriage"
		replace em_elect = . if vote_fmhiv == 1
		
	gen hiv_elect = 0
		replace hiv_elect = 1 if vote_1 == 1 & rand_promise1_txt == "make hiv-aids treatment more available"
		replace hiv_elect = 1 if vote_1 == 2 & rand_promise2_txt == "make hiv-aids treatment more available"
		replace hiv_elect = 1 if vote_2 == 1 & rand_promise3_txt == "make hiv-aids treatment more available"
		replace hiv_elect = 1 if vote_2 == 2 & rand_promise4_txt == "make hiv-aids treatment more available"
		replace hiv_elect = . if vote_fmhiv == 1

/*
 	foreach num of numlist 1/2 {

	gen vote1_male`num' = 1 if rand_cand`num'_txt == "Mr. John" | rand_cand`num'_txt == "Mr. Salim"
	replace vote1_male`num' = 0 if rand_cand`num'_txt == "Mrs. Mwanaidi" | rand_cand`num'_txt == "Mrs. Neema"

	gen s3q4_vote1_islam`num' = 1 if rand_cand`num'_txt == "Mr. Salim" | rand_cand`num'_txt == "Mrs. Mwanaidi" 
	replace s3q4_vote1_islam`num' = 0 if rand_cand`num'_txt == "Mr. John" | rand_cand`num'_txt == "Mrs. Neema"

	gen s3q4_vote1_fm`num' = 1 if rand_promise`num'_txt == "fight against child marriage"
	replace s3q4_vote1_fm`num' = 0 if rand_promise`num'_txt != "fight against child marriage"

	gen s3q4_vote1_hiv`num' = 1 if rand_promise`num'_txt == "make hiv-aids treatment more available"
	replace s3q4_vote1_hiv`num' = 0 if rand_promise`num'_txt != "make hiv-aids treatment more available"

	rename rand_cand`num'_txt s3q4_vote1_cand`num' 

	lab val s3q4_vote1_islam`num' vote_islam
	lab val s3q4_vote1_male`num' vote_male
	}


	foreach num of numlist 3/4 {

	gen s3q4_vote2_male`num' = 1 if rand_cand`num'_txt == "Mr. John" | rand_cand`num'_txt == "Mr. Salim"
	replace s3q4_vote2_male`num' = 0 if rand_cand`num'_txt == "Mrs. Mwanaidi" | rand_cand`num'_txt == "Mrs. Neema"

	gen s3q4_vote2_islam`num' = 1 if rand_cand`num'_txt == "Mr. Salim" | rand_cand`num'_txt == "Mrs. Mwanaidi" 
	replace s3q4_vote2_islam`num' = 0 if rand_cand`num'_txt == "Mr. John" | rand_cand`num'_txt == "Mrs. Neema"

	rename rand_cand`num'_txt s3q4_vote1_cand`num'

	lab val s3q4_vote2_islam`num' vote_islam
	lab val s3q4_vote2_male`num' vote_male

	gen s3q4_vote2_fm`num' = 1 if rand_promise`num'_txt == "fight against child marriage"
	replace s3q4_vote2_fm`num' = 0 if rand_promise`num'_txt != "fight against child marriage"

	gen s3q4_vote2_hiv`num' = 1 if rand_promise`num'_txt == "make hiv-aids treatment more available"
	replace s3q4_vote2_hiv`num' = 0 if rand_promise`num'_txt != "make hiv-aids treatment more available"


	}

	lab var s3q4_vote1_choice "Vote for in Election 1"
	lab def vote1 1 "1st Candidate" 2 "2nd Candidate"
	lab val s3q4_vote1_choice vote1

	lab var s3q4_vote2_choice "Voted for in Election 1"
	lab def vote2 1 "1st Candidate" 2 "2nd Candidate"
	lab val s3q4_vote2_choice vote2

	gen votefm_1 = 1 if ((s3q4_vote1_choice == 1 & s3q4_vote1_fm1 == 1) | (s3q4_vote1_choice == 2 & s3q4_vote1_fm2 == 1))
	replace votefm_1 = 0 if votefm_1 == . 
	replace votefm_1 = . if (s3q4_vote1_fm1 == 1 & s3q4_vote1_hiv2 == 1) | (s3q4_vote1_hiv1 == 1 & s3q4_vote1_fm2 != 1)
	gen votefm_2 = 1 if ((s3q4_vote2_choice == 1 & s3q4_vote2_fm3 == 1) | (s3q4_vote2_choice == 2 & s3q4_vote2_fm4 == 1)) 
	replace votefm_2 = 0 if votefm_2 == .
	replace votefm_2 = . if (s3q4_vote2_fm3 == 1 & s3q4_vote2_hiv4 != 1) | (s3q4_vote2_hiv3 == 1 & s3q4_vote2_fm4 != 1)
	gen votefm_tot = votefm_1 + votefm_2

	gen votehiv_1 = 1 if ((s3q4_vote1_choice == 1 & s3q4_vote1_hiv1 == 1) | (s3q4_vote1_choice == 2 & s3q4_vote1_hiv2 == 1)) 
	replace votehiv_1 = 0 if votehiv_1 == . 
	replace votehiv_1 = . if (s3q4_vote1_fm1 == 1 & s3q4_vote1_hiv2 == 1) | (s3q4_vote1_hiv1 == 1 & s3q4_vote1_fm2 != 1)
	gen votehiv_2 = 1 if ((s3q4_vote2_choice == 1 & s3q4_vote2_hiv3 == 1) | (s3q4_vote2_choice == 2 & s3q4_vote2_hiv4 == 1)) 
	replace votehiv_2 = 0 if votehiv_2 == .
	replace votehiv_2 = . if (s3q4_vote2_fm3 == 1 & s3q4_vote2_hiv4 != 1) | (s3q4_vote2_hiv3 == 1 & s3q4_vote2_fm4 != 1)
	gen votehiv_tot = votehiv_1 + votehiv_2
*/

* Section 4 - Child Marriage ---------------------------------------------------
	destring randomdraw78or79, replace												// Changed Prices 

	* Generate Treatment Variables for Survey Experiment
	gen treat_efmvig_scen = 1 if randomdraw78or79 <= 0.5
	replace treat_efmvig_scen = 0 if randomdraw78or79 > 0.5
	lab def moneyprobs 1 "Money problem" 0 "Daughter problem"
	lab val treat_efmvig_scen  moneyprobs
	lab var treat_efmvig_scen "[Randomized] Money problem or daughter problem situation"

	gen treat_efmvig_out = 0 if txt2_eng == "in their village"																
	replace treat_efmvig_out = 1 if txt2_eng == "outside their village"
	lab def treat_efmvig_out 0 "In Village" 1 "Outside Village"
	lab val treat_efmvig_out inout_vill 
	lab var treat_efmvig_out "[Randomized] Husband from inside or outside village"

	gen treat_efmvig_offer = txt3
	lab var treat_efmvig_offer "[Randomized] Amount offered"

	gen treat_efmvig_son = 0 if txt4_eng == "him"
	replace treat_efmvig_son = 1 if txt4_eng == "his son"
	lab def son 0 "Father" 1 "Son"
	lab val treat_efmvig_son son
	lab var treat_efmvig_son "[Randomized] Husband is father or son"

	gen treat_efmvig_age = txt1
	lab var treat_efmvig_age "[Randomized] Age of daughter"

	rename s6q6a em_reject													// Merge responses to two scenarios, since scenario is just another randomization
	replace em_reject = s6q6c if randomdraw78or79 > 0.5
	recode em_reject 	(2 = 0 "Accept") (1 = 1 "Reject"), ///
						gen(em_reject_story)
		drop em_reject
		lab var em_reject_story "[1 = Reject] Reject EM, story"
		
	replace s6q6b = s6q6d if randomdraw78or79 > 0.5
	recode s6q6b 		(2 = 0 "Accept") (1 = 1 "Reject"), ///
						gen(em_reject_norm)
		lab var em_reject_norm "[1 = Reject] Community reject EM, story"

	rename s6q7 s4q2_fm_lawpref

	** Reporting
	rename s6q8			em_report 
	
	rename s6q9			em_report_norm


/* Section 5 - Gender Hierarchy _________________________________________________*/

	* Recoded to positive = more equality
	rename s6q1 	ge_kid

	recode s6q3 	(0 = 1 "Equal earning ok") (1 = 0 "Equal earning bad"), ///
					gen(ge_earning) 
		lab var ge_earn "[1 = OK] If a woman earns more money than her husband, it's almost certain to cause problems"

	recode s5q4 	(0 = 1 "Equal school") (1 = 0 "Boys in school"), ///
					gen(ge_school)
		lab var ge_school "[REVERSED] 6.6) It is more important for a boy to go to school than a girl"

	egen ge_index = rowmean(ge_kid ge_earning ge_school)
	stop
	
/* Forced Marriage _____________________________________________________________*/

	recode s6q2 	(0 = 1 "Reject") (1 = 0 "Accept"), ///
					gen(fm_reject)
		lab var fm_reject  "[1 = Reject] A girl should not have a say in who she marries; it is best if her father selects a suitable husband for her"

	
	recode s9q2 	(0 = 1 "Reject") (1 = 0 "Accept"), ///
					gen(fm_reject_18)
		lab var fm_reject_18 "[1 = Reject] An 18 year old girl should accept the husband her father selects for her"
		
		
* Section 6 - Migration Attitudes ______________________________________________*/

	gen s6q1_mg_t_male = 1 if gender_txt == "boy"
	replace s6q1_mg_t_male = 0 if gender_txt == "girl"
	lab def male 0 "Girl" 1 "Boy"
	lab val s6q1_mg_t_male male
	lab var s6q1_mg_t_male "[Randomized] Child is a boy"

	gen s6q1_mg_t_city = 1 if town_txt == "city"
	replace s6q1_mg_t_city  = 0 if town_txt == "town"
	lab def city 0 "Town" 1 "City"
	lab val s6q1_mg_t_city  city
	lab var s6q1_mg_t_city  "[Randomized] Move location is town"

	rename s8q1 s6q1_mg_shouldgo
	lab def shouldgo 1 "Should leave" 2 "Should stay"
	lab val s6q1_mg_shouldgo shouldgo

	gen s6q2_mg_t_support = 1 if support_txt == "provide financial support for"
	replace s6q2_mg_t_support = 0 if support_txt == "allow"
	lab def support 0 "Allow" 1 "Provide financial support"
	lab val s6q2_mg_t_support support
	lab var s6q2_mg_t_support "[Randomized] How support kid"

	gen s6q2_mg_t_birthorder = 1 if order_txt == "first"
	replace s6q2_mg_t_birthorder = 2 if order_txt == "middle"
	replace s6q2_mg_t_birthorder = 3 if order_txt == "last"
	lab def birthorder 1 "First child" 2 "Second child" 3 "Last child"
	lab val s6q2_mg_t_birthorder birthorder
	lab var s6q2_mg_t_birthorder "[Randomized] Child's birth order"

	destring random_sondaughter, replace
	gen s6q2_mg_t_boyfirst = 1 if random_sondaughter <= 0.5
	replace s6q2_mg_t_boyfirst = 0 if random_sondaughter > 0.5
	lab def boyfirst 0 "Girl First" 1 "Boy First"
	lab val s6q2_mg_t_boyfirst boyfirst
	lab var s6q2_mg_t_boyfirst "Girl First"

	gen s6q2_mg_t_city = 1 if town_txt == "city"
	replace s6q2_mg_t_city  = 0 if town_txt == "town"
	lab val s6q2_mg_t_city  city
	lab var s6q2_mg_t_city  "[Randomized] Move location is town"

	rename s8q2_1a s15q2_mg_supson
	replace s15q2_mg_supson = s8q2_2b if s15q2_mg_supson == .
	lab def supportkid 0 "Dont Support" 1 "Support"
	lab var s15q2_mg_supson supportkid
	lab var s15q2_mg_supson "If their ${order_txt} son decides to move to the ${town_txt}  to look for work, his parents should ${support_txt} him."

	rename s8q2_1b s15q2_mg_supdaught
	replace s15q2_mg_supdaught = s8q2_2a if s15q2_mg_supdaught == .
	lab val s15q2_mg_supdaught supportkid
	lab var s15q2_mg_supdaught "If their ${order_txt} daughter decides to move to the ${town_txt} to look for work, her parents should ${support_txt} her."


/* Section 7 - IPV Reporting ___________________________________________________*/
	
	gen s16q1a_ipv_t_alt = 1 if s7q1a_1 !=. | s7q1a_2 !=.  
	replace s16q1a_ipv_t_alt = 2 if s7q1a_3 != . | s7q1a_4 !=.
	replace s16q1a_ipv_t_alt = 3 if s7q1a_5 != . | s7q1a_6 !=. 

	gen s16q1b_ipv_t_alt = 1 if s7q1b_3 !=. | s7q1b_5 !=.  
	replace s16q1b_ipv_t_alt = 2 if s7q1b_2 != . | s7q1b_6 !=.
	replace s16q1b_ipv_t_alt = 3 if s7q1b_1 != . | s7q1b_4 !=. 

	gen s16q1c_ipv_t_alt = 1 if s7q1c_3 !=. | s7q1c_6 !=.  
	replace s16q1c_ipv_t_alt = 2 if s7q1c_1 != . | s7q1c_5 !=.
	replace s16q1c_ipv_t_alt = 3 if s7q1c_2 != . | s7q1c_4 !=. 

	lab def alternative 1 "Situation will get better" 2 "Try harder" 3 "Work it out"
	lab val s16q1a_ipv_t_alt alternative
	lab val s16q1b_ipv_t_alt alternative
	lab val s16q1c_ipv_t_alt alternative

	rename s7q1a_1 ipv_report_police
	replace ipv_report_police = s7q1a_2 if ipv_report_police == .
	replace ipv_report_police = s7q1a_3 if ipv_report_police == .
	replace ipv_report_police = s7q1a_4 if ipv_report_police == .
	replace ipv_report_police = s7q1a_5 if ipv_report_police == .
	replace ipv_report_police = s7q1a_6 if ipv_report_police == .
	recode ipv_report_police (2 = 0)

	rename s7q1b_1 ipv_report_vc
	replace ipv_report_vc = s7q1b_2 if ipv_report_vc == .
	replace ipv_report_vc = s7q1b_3 if ipv_report_vc == .
	replace ipv_report_vc = s7q1b_4 if ipv_report_vc == .
	replace ipv_report_vc = s7q1b_5 if ipv_report_vc == .
	replace ipv_report_vc = s7q1b_6 if ipv_report_vc == .
	recode ipv_report_vc (2 = 0)

	rename s7q1c_1 ipv_report_parents
	replace ipv_report_parents = s7q1c_2 if ipv_report_parents == .
	replace ipv_report_parents = s7q1c_3 if ipv_report_parents == .
	replace ipv_report_parents = s7q1c_4 if ipv_report_parents == .
	replace ipv_report_parents = s7q1c_5 if ipv_report_parents == .
	replace ipv_report_parents = s7q1c_6 if ipv_report_parents == .
	recode ipv_report_parents (2 = 0)


	foreach var of varlist ipv_report_* {
		lab val `var' report
	}

	gen ipv_report = (ipv_report_police + ipv_report_vc + ipv_report_parents)/3
	lab var ipv_report "[Mean of 3] Would you report instance of abuse?"


/* Section 8 - IPV Attitudes ___________________________________________________*/

	gen s8q2_ipv_t_prime = 0 if s7q9a == .
	replace s8q2_ipv_t_prime = 1 if s7q9a != .
	replace s8q2_ipv_t_prime = 2 if s7q9b != .
	lab def prime 0 "Control" 1 "Dont hit" 2 "Head of HH"
	lab val s8q2_ipv_t_prime prime 

	rename s7q9a s8q2a_ipv_nohit
	lab def everhit 0 "Never hit" 1 "Can hit"
	lab var s8q2a_ipv_nohit everhit
	lab var s8q2a_ipv_nohit "A man should not hit another hit if he is not threatened"

	rename s7q9b s8q2b_ipv_manhead
	lab def manhead 0 "Not head" 1 "Man is head"
	lab var s8q2b_ipv_manhead manhead
	lab var s8q2b_ipv_manhead "A man should be the head of his household"

	rename s7q10a ipv_rej_disobey

	rename s7q10a_1 ipv_rej_hithard
		recode ipv_rej_hithard (2=0)(1=1)(-999 = .d)(-888 = .r)	
		replace ipv_rej_hithard = 1 if ipv_rej_disobey == 0
		lab val ipv_rej_hithard reject

	rename s7q10a_2 ipv_rej_persists											// this has been missing for early varibales
		replace ipv_rej_persists = 1 if ipv_rej_disobey == 1
	
	rename s7q10b ipv_rej_cheats												// Added one
	rename s7q10c ipv_rej_kids
	rename s7q10d ipv_rej_elders

	foreach var of varlist ipv_rej_disobey ipv_rej_persists ipv_rej_cheats ipv_rej_kids ipv_rej_elders {
		recode `var' (1=0)(0=1)(.d=0)
		lab val `var' reject
	}
	
	** Create extended measure
	gen ipv_rej_disobey_long = .
		replace ipv_rej_disobey_long = 0 if ipv_rej_hithard == 0 & ipv_rej_disobey == 0
		replace ipv_rej_disobey_long = 1 if ipv_rej_hithard == 1 & ipv_rej_disobey == 0
		replace ipv_rej_disobey_long = 2 if ipv_rej_persists == 0 & ipv_rej_disobey == 1
		replace ipv_rej_disobey_long = 3 if ipv_rej_persists == 1 & ipv_rej_disobey == 1
		lab def ipv_rej_long 0 "Hit, hard" 1 "Hit, not hard" 2 "Dont hit, unless persists" 3 "Dont hit, even if persists"
		lab val ipv_rej_disobey_long ipv_rej_long

	destring s7q10yes_eligible, replace
	destring s7q10no_eligible, replace

	rename contradiction_rand s8q3_ipv_rand
	gen s8q3_ipv_conflict = 1 if s7q10yes_eligible == 1 & s7q10no_eligible == 1
	replace s8q3_ipv_conflict = 0 if s7q10yes_eligible == 0 | s7q10no_eligible == 0

	destring s8q3_ipv_rand, replace
	destring s8q3_ipv_conflict, replace

	gen s8q3_ipv_t_contradict = 1 if s8q3_ipv_rand < 0.5 & s8q3_ipv_conflict == 1
	replace s8q3_ipv_t_contradict  = 0 if s8q3_ipv_rand > 0.5 & s8q3_ipv_conflict == 1
	lab var s8q3_ipv_t_contradict "[Randomized] Assigned Contradiction]"

	rename s7q11 s8q3e_ipv_contradict 
	rename s8q12 ipv_rej_gossip

/* Section 9 - HIV / AIDS Knowledge + Stigma ___________________________________*/
	
	gen s9q5a_hiv_knowdrug = s8aq1 
	replace s9q5a_hiv_knowdrug = 0 if s9q5a_hiv_knowdrug == -999
	lab val s9q5a_hiv_knowdrug yesnodk

	gen s9q5c_hiv_knowarv = s8aq2 
	recode s9q5c_hiv_knowarv (2 = 0)
	replace s9q5c_hiv_knowarv = 0 if s9q5a_hiv_knowdrug == 0						// Dont know ARV if never heard of the drug
	lab def arv 0 "Don't Know ARV (no prompt)" 1 "Know ARV (no prompt)"
	lab val s9q5c_hiv_knowarv arv

	gen s9q5b_hiv_knowarv_prompt = s8aq3 
	replace s9q5b_hiv_knowarv_prompt = 1 if s9q5c_hiv_knowarv == 1					// If you know ARVs unprompted then know prompted
	replace s9q5b_hiv_knowarv_prompt = 0 if s9q5b_hiv_knowarv_prompt == -999
	lab def arv_prompt 0 "Dont Know ARV (prompt)" 1 "Know ARV (prompt)" -999 "Don't Know"
	lab val s9q5b_hiv_knowarv_prompt arv_prompt

	rename s8aq4 s9q6_hiv_knowpreg
	replace s9q6_hiv_knowpreg = 0 if s9q6_hiv_knowpreg == -999
	lab val s9q6_hiv_knowpreg yesnodk
	lab var s9q6_hiv_knowpreg "Can HIV be transmitted from a mother to her baby during pregnancy?"

	rename s8aq5 s9q7_hiv_spirit
	replace s9q7_hiv_spirit = 0 if s9q7_hiv_spirit == -999
	lab var s9q7_hiv_spirit "Do you believe spiritual efforts like prayer and traditional medicine are effective at treating HIV?"

	rename s8b1q1 s9q8_hiv_famshare
	rename s8b1q2 s9q9_hiv_boy
	rename s8b1q3 s9q9_hiv_house
	rename s8b1q4 s9q10_hiv_workself
	rename s8q5 s9q10_hiv_workcomm

	rename s8b1q6 s9q11_hiv

	gen hivdisclose_sharespouse = 1 if strpos(s9q11_hiv, "1")					// NEED TO
	gen hivdisclose_fam = 1 if strpos(s9q11_hiv, "2")
	gen hivdisclose_friend = 1 if strpos(s9q11_hiv, "3")
	gen hivdisclose_cowork = 1 if strpos(s9q11_hiv, "4")
	gen hivdisclose_none = 1 if strpos(s9q11_hiv, "5") 	

	lab def hiv_share 1 "Share" 0 "Don't share"

	foreach var of varlist hivdisclose_* {
		replace `var' = 0 if `var' == .
		lab val `var' hiv_share
	}
	
	egen hivdisclose_index = rowmean(hivdisclose_fam hivdisclose_friend hivdisclose_cowork)


/* Section 10 - Victim Response ________________________________________________*/
	rename s9q1 s10q1_ipv_tolerate	
	lab def tolerate 0 "Disagree" 1 "Agree"
	lab val s10q1_ipv_tolerate	 tolerate
		



/* Section 10 - IPV Norms ______________________________________________________*/
	rename s8q14 ipv_norm_rej
		recode ipv_norm_rej (0=1)(1=0)
		lab val ipv_norm_rej reject
		
	recode s8q15 	(3=1 "Outrage")(2 1 .d = 0 "No outrage"), ///
					gen(ipv_norm_outrage)
		lab val ipv_norm_outrage outrage
	
	rename s8q16 s11q3_ipv_knowlaw


/* Section 11 - Migration History ----------------------------------------------
rename s10bq0 s10bq0_hhhage
lab var s10bq0_hhhage "Age of head of household"

rename household_txt mig_hhref
rename s10bq1 mig_hhnum
lab var mig_hhnum "Number of people grew up in HH [grew up / currently live]"

* Run Loop Over Individual Migrants
destring mm_list_rpt_count, replace
sum mm_list_rpt_count
loc max = `r(max)'

foreach num of numlist 1/`max' { 													// Need to set this to a count

rename s10bq2a_r_`num' mig_age_`num'
lab var mig_age_`num' "Age"

rename s10bq3_r_`num' mig_gen_`num'
lab var mig_gen_`num' "Gender"

rename s10bq4_r_`num' mig_now_`num'												// Differentiates betwee people being asked about current versus past migrations
recode mig_now_`num' (1 = 0) (0 = 1)
lab var mig_now_`num' "Does X family member live outside the city now?"

rename s10bq5_r_`num' mig_everdum_`num'
lab var mig_everdum_`num' "Ever migrate"

rename s10bq6_r_`num' mig_evernum_`num'
lab var mig_evernum_`num' "Number of times migrated"

rename s10bq7_r_`num' mig_longstay_`num'
lab var mig_longstay_`num' "Length of stay"

rename rand_times_txt_`num' mig_tripnum_`num'									// Identifies the trip num
lab var mig_tripnum_`num' "[Randomly selected] Trip number"		

rename s10bq12_r_`num' mig_longaway_`num'
lab var mig_longaway_`num' "How long away"				

rename s10bq8_r_`num' mig_where_`num'											// Need to add in "other" option
destring mig_where_`num', replace
replace mig_where_`num' = s10bq13_r_`num' if mig_now_`num' == 0
lab var mig_where_`num' "Migration Location"

rename s10bq9_r_`num' mig_occup_`num'											// Need to add in "other" option	
replace s10bq14_r_`num' = s10bq14_r_`num' if mig_now_`num' == 0
lab var mig_occup_`num'	"Migration Occupation"

rename s10bq10_r_qty_`num' mig_remitqty_`num'
replace mig_remitqty_`num' = s10bq15_r_qty_`num' if mig_now_`num' == 0
lab var mig_remitqty_`num' "Remitance Quantity"

rename s10bq10_r_u_`num' mig_rmitunit_`num'
replace mig_rmitunit_`num' = s10bq15_r_u_`num' if mig_now_`num' == 0
lab var mig_rmitunit_`num' "Remittance Unit"

rename s10bq15_r_amt_`num' mig_rmitamnt_`num'
lab var mig_rmitamnt_`num' "On average, how much does ${mm_index_r} oldest person send each time they send?"	// This got left out of the previous

** NEED TO DO THIS FOR "OTHER" OPTIONS s10bq15_r  

rename s10bq11_`num' mig_remituse_`num'
replace mig_remituse_`num' = s10bq16_`num' if mig_now_`num' == 0

replace mig_remituse_`num' = subinstr(mig_remituse_`num', "-222", "other",.)	// Switch out subtrings 
replace mig_remituse_`num' = subinstr(mig_remituse_`num', "-999", "dontknow",.)
replace mig_remituse_`num' = subinstr(mig_remituse_`num', "-888", "refuse",.)
gen mig_remituse_edu_`num' = 1 if strpos(s3q2_ptix_contact, "1")				// NEED TO
gen mig_remituse_shock_`num' = 1 if strpos(s3q2_ptix_contact, "2")
gen mig_remituse_cerem_`num' = 1 if strpos(s3q2_ptix_contact, "3")
gen mig_remituse_reg_`num' = 1 if strpos(s3q2_ptix_contact, "4")
gen mig_remituse_biz_`num' = 1 if strpos(s3q2_ptix_contact, "6") 	
gen mig_remituse_invest_`num' = 1 if strpos(s3q2_ptix_contact, "7") 	
gen mig_remituse_gen_`num' = 1 if strpos(s3q2_ptix_contact, "8") 	
gen mig_remituse_asked_`num' = 1 if strpos(s3q2_ptix_contact, "9")
gen mig_remituse_oth_`num' = 1 if strpos(s3q2_ptix_contact, "oth")
gen mig_remituse_dk_`num' = 1 if strpos(s3q2_ptix_contact, "dontknow")

rename s10bq16_`num' mig_remituse_other_`num'
}
*/
*drop s10*
drop s10* 

/* Section 13 - Political Knowledge ____________________________________________*/

	lab define knowledge 0 "Don't Know" 1 "Know" -999 "Missing" 

	rename s11_1 s13q1_knw_president
	recode s13q1_knw_president (-999 = 0) (-222 = 0)
	lab val s13q1_knw_president knowledge

	rename s11_2 s13q2_knw_music
	recode s13q2_knw_music (2 = 1) (-999 = 0) (-222 = 0)
	replace s13q2_knw_music = 1 if s11_2_oth == "Aslay" | ///
								 s11_2_oth == "Aslay Isihaka"						// Keep adding to this
	lab val s13q2_knw_music knowledge

	rename s11_3 s13q3_knw_sport
	recode s13q3_knw_sport (-999 = 0) (-222 = 0)
	lab val s13q3_knw_sport knowledge

	gen s13q4_knw_mp = 1 if (s11_4 == 1 & svy_district_name == "Muheza") | ///
							(s11_4 == 2 & svy_district_name == "Korogwe") | ///
							(s11_4 == 3 & svy_district_name == "Tanga") | ///
							(s11_4 == 4 & svy_district_name == "Handeni") | ///
							(s11_4 == 5 & svy_district_name == "Mkinga")
	replace s13q4_knw_mp = -888 if s11_4 == -888
	replace s13q4_knw_mp = 0 if s13q4_knw_mp  == .
	lab val s13q4_knw_mp knowledge

		
/* Section 12 - Compliance _____________________________________________________*/

	rename s12q1 comply_attend
	rename s12q2 comply_topic													// Need to match to treatment assignment
	rename s12q5 comply_disc
	rename s12q6 comply_disc_who	

	replace comply_disc_who = subinstr(comply_dis	c_who, "-999", "dontknow",.)
	replace comply_disc_who = subinstr(comply_disc_who, "-888", "refuse",.)
	replace comply_disc_who = subinstr(comply_disc_who, "10", "other cm",.)

	gen comply_disc_spouse = 1 if strpos(s3q2_ptix_contact, "1")					// NEED TO
	gen comply_disc_child = 1 if strpos(s3q2_ptix_contact, "2")
	gen comply_disc_brosis = 1 if strpos(s3q2_ptix_contact, "3")
	gen comply_disc_dad = 1 if strpos(s3q2_ptix_contact, "4")
	gen comply_disc_mom = 1 if strpos(s3q2_ptix_contact, "5") 
	gen comply_disc_aunt = 1 if strpos(s3q2_ptix_contact, "6") 	
	gen comply_disc_uncle = 1 if strpos(s3q2_ptix_contact, "7") 	
	gen comply_disc_gparent = 1 if strpos(s3q2_ptix_contact, "8")
	gen comply_disc_cuz = 1 if strpos(s3q2_ptix_contact, "9")
	gen comply_disc_comlead = 1 if strpos(s3q2_ptix_contact, "other cm")

/* Section 13 - Conclusion _____________________________________________________*/

	rename s13q1 s13q1_followup
	rename s13q3 s13q4_otherspresent

	* Drop and rename
	drop conjoint*
	drop setofconjoint*
	drop times*
	

/* Save ________________________________________________________________________*/

	save  "${data}/01_raw_data/pfm_as_midline_clean.dta", replace



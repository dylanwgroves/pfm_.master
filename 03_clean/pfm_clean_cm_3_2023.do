
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survey 2 (November 2021)
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

	use "${data}/01_raw_data/03_surveys/pfm_nopii_cm_3_2023.dta", clear

	gen cm_3_2023 = 1
	
/* Pulled treatment assignment _________________________________________________*/

	gen  rd_sample 	= radio_sample 		// numeric binary for RD sample status
		la de rd_sample 0 "NOT RD sample" 1 "YES RD sample"
		la val rd_sample rd_sample
		
	gen treat_rd 	= radio_treat_num 	// numeric binary for RD sample status
		la de treat_rd 0 "Flashlight" 1 "Radio"
		la val treat_rd treat_rd

/* Converting don't know/refuse/other to extended missing values _______________*/

	qui ds, has(type numeric)
	recode `r(varlist)' (-888 = .r) (-999 = .d) (-222 = .o) (-666 = .o)

/* Labels _______________________________________________________________________*/

	lab def yesno 0 "No" 1 "Yes"
	lab def agree 0 "Disagree" 1 "Agree"
	lab def agree_likert_backwards 1 "Strongly Agree" 2 "Agree" 3 "Neither" 4 "Disagree" 5 "Strongly Disagree"
	lab def agree_likert 1 "Strongly Disagree" 2 "Disagree" 3 "Neither" 4 "Agree" 5 "Strongly Agree"

/* Pulled Data / Confirmations _________________________________________________*/

	destring resp_female, replace
	lab def resp_female 0 "Male" 1 "Female" , modify
	lab val resp_female resp_female 
	
		* check that resp_female was correctly replaced if gender was not confirmed from pull
		*rename gender_correction correction_gender
		*gen check_gender = (gender_confirm == 0)
			*tab resp_female correction_gender if check_gender == 1 
		*drop check_gender
	
	*tab info_confirm														

	rename info_correction_1	correction_name
	rename info_correction_2	correction_age
	rename info_correction_3	correction_marital
	rename info_correction_4	correction_village
	
	* clean by hand the strings, as need eye check: correct_name correct_village correct_subvillage
	
	* Age
		destring resp_age , replace
		gen age_check = resp_age if correction_age == 0 
		replace age_check = correct_age if correction_age == 1 & resp_age < correct_age & correct_age != . 
		gen check_age = (age_check != resp_age)
		tab resp_age age_check if check_age == 1 
		
		drop age_check check_age
		
	* Marital status
	destring resp_marital_status, replace
	replace resp_marital_status = correct_marital_status if correction_marital == 1

*	lab val resp_marital_status correct_marital_status
*	decode resp_marital_status, gen(resp_marital_status_n)
	
/* Survey Information __________________________________________________________*/

	rename visits_nbr svy_visitsnum
	
	rename enum svy_enum 
	rename consent svy_consent 
	
	
/* Respondent Information ______________________________________________________*/

	tab resp_describe_day, m
	
	gen resp_tribe_sambaa = (resp_tribe == 32)
	gen resp_tribe_digo = (resp_tribe == 38)
	
	tab values_tzvstribe, m
	recode values_tzvstribe	(1 2 = 1 "TZ > Tribe") (3 4 5 = 0 "TZ <= Tribe"), gen(values_tzovertribe_dum)
	
	
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
						
	foreach var of varlist ptixpref* {
		fre `var'
	}
	

/* Environment Causes __________________________________________________________*/
		
	fre ccimpact_betterworse
	
	*ccimpact_problems
	
	recode env_ccknow_mean (1 2 3 = 1)(4 5 6 7 -888 -999 .d = 0), gen(enviro_ccknow_mean_dum)
	lab var enviro_ccknow_mean_dum "Dummy: Know meaning of climate change"
	fre env_ccknow_mean

	rename envgender_family_0  enviro_affects_none
	rename envgender_family_1  enviro_affects_m
	rename envgender_family_2  enviro_affects_w
	rename envgender_family_3  enviro_affects_grandpa
	rename envgender_family_4  enviro_affects_grandma
	rename envgender_family_5  enviro_affects_boys15plus
	rename envgender_family_6  enviro_affects_girls15plus
	rename envgender_family_7  enviro_affects_boys15low
	rename envgender_family_8  enviro_affects_girls15up
	rename envgender_family_9  enviro_affects_children
	rename envgender_family_10  enviro_affects_oldbro
	rename envgender_family_11  enviro_affects_oldsis
	rename envgender_family_12  enviro_affects_pregnant
	rename envgender_family_13  enviro_affects_uncle
	rename envgender_family_14  enviro_affects_auntie
	rename envgender_family_15	enviro_affects_me
	rename envgender_family__222  enviro_affects_oth
	rename envgender_family__888  enviro_affects_dk
	rename envgender_family__999  enviro_affects_refuse
	
	egen enviro_affects_num = rowtotal(enviro_affects_*)
	fre enviro_affects_num
	
	egen enviro_affects_women = 	rowmax(enviro_affects_w ///
											enviro_affects_grandma ///
											enviro_affects_girls15plus ///
											enviro_affects_girls15up ///
											enviro_affects_oldsis ///
											enviro_affects_pregnant ///
											enviro_affects_auntie)
	tab enviro_affects_women , m
	
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
	
	egen env_cause_second_num = rowtotal(enviro_cause_second_*)

	egen enviro_cause_second_humans = 	rowmax(enviro_cause_second_vill ///
											enviro_cause_second_othvill ///
											enviro_cause_second_othtz ///
											enviro_cause_second_intl ///
											enviro_cause_second_gov)
																
	recode env_cause (4 5 6 7 8 = 2)(1 2 3 9 10 -222 -999 = 0), gen(enviro_cause_human)	
	lab var enviro_cause_human "Environmental problems primarily caused by humans, secondarily, or not at all"
	replace enviro_cause_human = 1 if enviro_cause_second_humans == 1 & enviro_cause_human == 0
	fre enviro_cause_human
	
	recode env_cause (7 = 1)(1 2 3 4 5 6 8 9 10 -222 -999 = 0), gen(enviro_cause_intl)
	lab var enviro_cause_intl "Dummy: enviro prob caused by international folks"
	replace enviro_cause_intl = 1 if enviro_cause_second_intl == 1 
	fre enviro_cause_intl

	/* Environment Outcomes ________________________________________________________*/

	recode envatt_general (1 = 1 "Enviro > Dev Projects")(2 = 0 "Dev Projects > Enviro"), gen(enviro_attitudes)
		lab var enviro_attitudes "Enviro over dev projects"
	fre enviro_attitudes
		
	recode envnorm_community (1 = 1 "Enviro > Dev Projects")(2 = 0 "Dev Projects > Enviro"), gen(enviro_norm)
		lab var enviro_norm "Enviro over dev projects"
	fre enviro_norm
	
	recode envoutcm_politician (1 = 0 "Sell the forest land")(2 = 1 "Protect the land"), gen(enviro_voteenviro)
		lab var enviro_voteenviro "Enviro vote (not vignette)"
	fre enviro_voteenviro
	
		/* Experimental tabs */
	
		gen rand_pi_environment_n = real(rand_pi_environment)
		
		gen treat_pi_env = ""
		replace treat_pi_env = "treat"		if rand_pi_environment_n>=0.5
		replace treat_pi_env = "control"	if rand_pi_environment_n<0.5
	
		tab envoutcm_cutting_wood treat_pi_env	, col
		
		
		
/*  ENV Indeces																	 // need to revise 
		
		gen enviro_ccknow_short = enviro_ccknow_mean_dum
		gen enviro_cause_human_short = enviro_cause_human/2
		egen enviro_know_index = rowmean(enviro_ccknow_mean_dum enviro_cause_human_short enviro_cause_intl)

		
		egen enviro_attitudes_index = rowmean(enviro_attitudes enviro_voteenviro)
			
		gen ptixpref2_rank_enviro_short = (ptixpref2_rank_enviro-1)/2 
		gen socpref1_rank_enviro_short = (socpref1_rank_enviro-1)/3
		egen enviro_prior_index = rowmean(enviro_elect ptixpref2_rank_enviro_short ///
										socpref1_rank_enviro_short)
										
		egen enviro_partner_prior_index = rowmean(ptixpref2_partner_enviro socpref1_partner_enviro)
		
		gen socpref1_rank_bribes_short = socpref1_rank_bribes/4
		gen thermo_leader_short = thermo_local_leader_num/100
		egen corruption_index = rowmean(ppart_corruption socpref1_rank_bribes_short thermo_leader_short)	
		
 */		
 
*	foreach var of varlist enviro_* {
*		fre enviro_*
*	}

	/* Environment and Gender __________________________________________________*/	

	la var env_cause_gender "Who is more part of cause of climate change?"
	fre env_cause_gender	
	la var env_victim_gender "Who is victim of climate change?"
	fre env_victim_gender	
	
	la var env_plan_know "Hear about Uzikwasa's environmental village plans?"
	fre env_plan_know		
	la var env_plan_gender "Whose responsibility to implement Uzikwasa's environmental village plans?"
	fre env_plan_gender		
				
				/* Experimental tabs */
				
				gen env_gend_clip = ""
					replace env_gend_clip = "man cause" 	if treatment_code1 == "treatment 1"
					replace env_gend_clip = "women conseq" 	if treatment_code1 == "treatment 2"
					replace env_gend_clip = "control" 		if treatment_code1 == "control"
				
				tab env_cause_gender 	env_gend_clip	, col
				tab env_victim_gender 	env_gend_clip	, col
				tab env_plan_know 		env_gend_clip	, col
				tab env_plan_gender		env_gend_clip	, col
	
				
	
	la var 	envgender_attitude 	"Who to involve in village plans"
	la de 	envgender_attitude 	1 "women" 2 "men" , modify
	la val 	envgender_attitude	envgender_attitude
	tab envgender_attitude	, m
	
	// change option 2 to less easy, drop part of it: 
*Villagers have different ideas about how to implement changes in the way of life.
*Please tell me which statement you agree with more:
*Statement 1: "In our district, we must involve women into community projects that help us protect the environment because they are suffering the most from the drier land.""
*Statement 2: "In our district, we must involve men into community projects  that help us protect the environment because they are the ones responsible for our land, so we can hold on to our traditions and make sure our women have enough time at home to look after our children."

**Statement 2 NEW: "In our district, we must involve men into community projects  that help us protect the environment because they are the ones responsible for our land."

	la val 	envgender_nrom	envgender_attitude
	tab envgender_nrom		, m

			
	
		/* Agricultural Work ___________________________________________________________*/

			* Were you already married when you started working in agriculture?
			tab agr_married if resp_female == 1 , m

				rename agr_cropsnow_1 agr_cropsnow_sisal 
				rename agr_cropsnow_2 agr_cropsnow_cashew 
				rename agr_cropsnow_3 agr_cropsnow_fruit 
				rename agr_cropsnow_4 agr_cropsnow_maize 
				rename agr_cropsnow_5 agr_cropsnow_beans 
				rename agr_cropsnow_6 agr_cropsnow_spices 
				rename agr_cropsnow_7 agr_cropsnow_cassava 
				rename agr_cropsnow_8 agr_cropsnow_banana 
				rename agr_cropsnow_9 agr_cropsnow_coconuts 
				rename agr_cropsnow_10 agr_cropsnow_swtpotato 
				rename agr_cropsnow_11 agr_cropsnow_choloko 
				rename agr_cropsnow_12 agr_cropsnow_peas 
				rename agr_cropsnow_13 agr_cropsnow_kunde 
				rename agr_cropsnow_14 agr_cropsnow_sgrcane 
				rename agr_cropsnow_15 agr_cropsnow_cotton 
				rename agr_cropsnow_16 agr_cropsnow_wheat 
				rename agr_cropsnow__222 agr_cropsnow_other 
				rename agr_cropsnow__888 agr_cropsnow_refuse

				foreach var of varlist agr_cropsnow_* {
					cap replace `var' = .r if agr_cropsnow_refuse == .r
				}

				rename agr_cropspast_1 agr_cropspast_sisal 
				rename agr_cropspast_2 agr_cropspast_cashew 
				rename agr_cropspast_3 agr_cropspast_fruit 
				rename agr_cropspast_4 agr_cropspast_maize 
				rename agr_cropspast_5 agr_cropspast_beans 
				rename agr_cropspast_6 agr_cropspast_spices 
				rename agr_cropspast_7 agr_cropspast_cassava 
				rename agr_cropspast_8 agr_cropspast_banana 
				rename agr_cropspast_9 agr_cropspast_coconuts 
				rename agr_cropspast_10 agr_cropspast_swtpotato 
				rename agr_cropspast_11 agr_cropspast_choloko 
				rename agr_cropspast_12 agr_cropspast_peas 
				rename agr_cropspast_13 agr_cropspast_kunde 
				rename agr_cropspast_14 agr_cropspast_sgrcane 
				rename agr_cropspast_15 agr_cropspast_cotton 
				rename agr_cropspast_16 agr_cropspast_wheat 
				rename agr_cropspast__222 agr_cropspast_other 
				rename agr_cropspast__888 agr_cropspast_refuse

				foreach var of varlist agr_cropspast_* {
					cap replace `var' = .r if agre_cropspast_refuse == .r
				}

			* Which crops do you cultivate? Are there any other crops that you used to cultivate in the past, but you do not anymore?
			* // TO CLEAN AND MAKE gen past != now	

			/* "Do you think that recently you have less productivity? 
			la de agr_productivity 	0 "same productivity" 		///
									1 "less than 1 years"		/// 
									2 "less than 2-5 years"		/// 
									3 "less then 5-10 years"	/// 
									4 "less than >10 years"	
			la val agr_productivity agr_productivity
			tab agr_productivity, m
			*/	
				*tab agr_productivity_branched, m
				
				egen agr_productivity_climate = rowmax(	agr_productivity_branched_3 ///
														agr_productivity_branched_4 ///
														agr_productivity_branched_5 /// 
														agr_productivity_branched_6 /// 
														agr_productivity_branched_7 ///
														agr_productivity_branched_9 ///
														agr_productivity_branched_10)
				la de agr_productivity_climate 0 "not climate change" 1 "climate change"
				la val agr_productivity_climate agr_productivity_climate
				
				rename agr_productivity_branched_1 agr_prod_seeds
				rename agr_productivity_branched_2 agr_prod_insects
				rename agr_productivity_branched_3 agr_prod_rainy
				rename agr_productivity_branched_4 agr_prod_dry
				rename agr_productivity_branched_5 agr_prod_unprerain
				rename agr_productivity_branched_6 agr_prod_hot
				rename agr_productivity_branched_7 agr_prod_soil
				rename agr_productivity_branched_8 agr_prod_betterweat		
				rename agr_productivity_branched_9 agr_prod_othweat		
				rename agr_productivity_branched_10 agr_prod_othcc	
				rename agr_productivity_branched_11 agr_prod_othnotcc	
				rename agr_productivity_branched__888 agr_prod_refuse	
				foreach var of varlist agr_prod_* {
					cap replace `var' = .r if agr_prod_refuse == .r
				}
			
			* Why less productivity? [sel mult -- summarized]
			tab agr_productivity_climate , m
				
				rename agr_conseq_1 	agr_conseq_lessmoney 		// have LESS MONEY than in the past
				rename agr_conseq_98 	agr_conseq_morewomen 		// have to ask WOMEN in the family to WORK IN THE FARM too, which they did less of in the past
				rename agr_conseq_99 	agr_conseq_womenoutside 	// have to ask WOMEN in the family TO WORK OUTSIDE OF THE FARM, which they did less of in the past
				rename agr_conseq_2 	agr_conseq_kids 			// have to ask KIDS in the family TO WORK IN THE FARM too, which they did less of in the past
				rename agr_conseq_3 	agr_conseq_lesstime 		// work LESS HOURS in agriculture than in the past, and GOT OTHER JOBS TOO
				rename agr_conseq_4 	agr_conseq_moretime 		// work MORE HOURS than in the past

				foreach var of varlist agr_conseq_* {
					cap replace `var' = .r if agr_conseq_refuse == .r
				}				
				foreach var of varlist agr_conseq_* {
			cap tab `var' , m
				}
			* Which are consequences of less productivity? [sel mult -- summarized]
			tab agr_conseq_morewomen , m
			
			* - treatment here - *
			
			* Do you think it is ok for women to work more than they used to?
			tab agr_exp , m

			* If women work more, they might need to take time off of something else. If they had to choose, what would be best for them to do less of?
				rename agr_workmoreconseq_0		agr_workmoreconseq_nowork 	// They should not work, they need to give all their time to the family
				rename agr_workmoreconseq_1		agr_workmoreconseq_husb		// They could dedicate less time to their HUSBAND
				rename agr_workmoreconseq_2		agr_workmoreconseq_child	// They could dedicate less time to their CHILDREN
				rename agr_workmoreconseq_3		agr_workmoreconseq_house	// They could dedicate less time to their HOUSE
				rename agr_workmoreconseq_4		agr_workmoreconseq_soc		// They could dedicate less time to SOCIALIZE
				rename agr_workmoreconseq_5		agr_workmoreconseq_rest		// They could dedicate less time to REST / SLEEP 	
				rename agr_workmoreconseq__888	agr_workmoreconseq_refuse
				rename agr_workmoreconseq__999	agr_workmoreconseq_dk
				foreach var of varlist agr_workmoreconseq_* {
					cap replace `var' = .r if agr_workmoreconseq_refuse == .r
				}
			
				foreach var of varlist agr_workmoreconseq_* {
			cap tab `var' , m
				}
				
				/* Experimental tabs */
				
				gen agr_treat_txt = ""
				replace agr_treat_txt = "climate" 		if agr_treat == "treated_v1"
				replace agr_treat_txt = "globalization" if agr_treat == "treated_v2"
				replace agr_treat_txt = "control" if agr_treat == "control"
			
				
				tab agr_exp agr_treat_txt	, col
					foreach var of varlist agr_workmoreconseq_* {
				tab `var' 	agr_treat_txt	, col
					}
			
			* envgender_open_audio "How do you think climate change has affected women?
			* // open-ended recorded that needs to be transcribed and translated // can use the clips for treatments in the future
			
			
					
		
		
/* Gender ______________________________________________________________________*/ 

	
	* classic
		
		recode ge_job (2 = 1 "Women equal job rights")(1 = 0 "Women less job rights"), gen(ge_job_new)
		recode ge_leaders (1 = 1 "Wom = Men as lead")(2 = 0 "Wom < Men as lead"), gen(ge_leaders_new)
		gen wpp_attitude2_dum = ge_leaders_new
		recode ge_business (1 = 1 "Wom = Men as bus")(2 = 0 "Wom < Men as bus"), gen(ge_business_new)
		recode ge_earn (2 = 1 "Wom > $ Men OK")(1 = 0 "Wom > $ Men problems"), gen(ge_earn_new)
		recode fm_attitude_1 (2 = 1 "Against FM")(1 = 0 "Pro FM"), gen(ge_fm_new)
		recode em_attitude_religion (2 = 1 "Against EM for rel")(1 = 0 "Pro EM for rel"), gen(ge_em_rel_new)
		recode em_attitude_pregnant (2 = 1 "Against EM for pregn")(1 = 0 "Pro EM for pregn"), gen(ge_em_preg_new)
		
		egen ge_any = rowmean(ge_job_new ge_leaders_new ge_business_new ge_earn_new ge_fm_new ge_em_rel_new ge_em_preg_new)
	
	foreach var of varlist ge_* {
		fre `var'
	}
	
		recode ge_earn_2 (1 = 1 "Wom > $ Men OK")(2 = 0 "Wom > $ Men problems"), gen(ge_earn_2_new)
	tab ge_earn_2_new

	* about men
	
		recode ge_manchores (1 = 1 "M help W if W work")(2 = 0 "M NOT help W if W work"), gen(ge_manchores_new)
		recode ge_manrespect (2 = 1 "M < respect if W work")(1 = 0 "M = respect if W work"), gen(ge_manrespect_new)
		
		egen ge_man_any = rowmean(ge_manchores_new ge_manrespect_new)
	
	foreach var of varlist ge_man* {
		fre `var'
	}
		
		recode ge_backlashngo (1 = 1 "NGO should serve W")(2 = 0 "NGO should serve M"), gen(ge_backlashngo_new)
	fre ge_backlashngo_new
	
		recode ge_resentment (1 = 0 "W push too far")(2 = 1 "W finally well"), gen(ge_resentment_new)
	fre ge_resentment_new
	
		egen ge_backlash_any = rowmean(ge_backlashngo_new ge_resentment_new)
	tab ge_backlash_any

	* IPV
	recode ipv_attitudes (1=0 "Accept IPV (disobey)")(0=1 "Reject IPV (disobey)"), gen(ipv_reject_gossip)	
	fre ipv_reject_gossip
	
	* VAC
		recode vac_attitude (2 = 0 "Accept VAC (hit)")(1 = 1 "Reject IPV (hit)"), gen(vac_attitude_new)
		fre vac_attitude_new
		
		recode vac_attitude_stick  (2 = 0 "Accept VAC (hit stick)")(1 = 1 "Reject IPV (hit stick)"), gen(vac_attitude_stick_new)
		fre vac_attitude_stick_new
	
	egen vac_any = rowmean(vac_attitude_new vac_attitude_stick_new)
	tab vac_any

	
		
/* GBV _________________________________________________________________________*/
																				
	* risky boda att + norm
	recode gbv_safe_boda (2 = 1 "Generally risky")(1 = 0 "Generally safe"), gen(gbv_risky_boda_short)
	tab gbv_risky_boda_short 	, m

	*Street
	tab gbv_resp_streets_self if resp_female == 1, m
	rename gbv_resp_streets_self gbv_safe_streets_self_short 

	* Party
	tab gbv_safe_party_norm, m
	
	* GBV Response
	gen gbv_response_gov = (gbv_response == 2)
	tab gbv_response_gov	, m
	
	* Court 
	recode court_boda_sex (1 = 1 "Testify")(2 = 0 "Don't testify"), gen(gbv_testify)
	tab gbv_testify 		, m
	recode court_boda_sex_norm (1 = 1 "Testify")(2 = 0 "Don't testify"), gen(gbv_testify_norm)
	tab gbv_testify_norm 	, m
	
		/* Experimental tabs 

		gen rand_pi_testify_n = real(rand_pi_testify)
	
		gen treat_pi_gbv = ""
		replace treat_pi_gbv = "treat"		if rand_pi_testify_n>=0.5
		replace treat_pi_gbv = "control"	if rand_pi_testify_n<0.5
	
		tab gbv_testify 		treat_pi_gbv	, col
		tab gbv_testify_norm 	treat_pi_gbv	, col
		
		*/
		
	/*  GBV Indeces */
	
		rename gbv_boda_risky_* gbv_risky_boda_* 
		egen gbv_risk_index = rowmean(gbv_risky_boda_short ///
										gbv_safe_streets_self_short)
	tab gbv_risk_index
	
		egen gbv_response_index = rowmean(gbv_response_gov gbv_testify)		
	tab gbv_response_index
	
		gen ptixpref1_rank_gbv_short = (ptixpref1_rank_gbv-1)/2 
		egen gbv_prior_index = rowmean(gbv_elect ptixpref1_rank_gbv_short)
	tab gbv_prior_index
			
			
/* GBV for Boda Drivers ________________________________________________________*/
	

	
/* NPA meetings ________________________________________________________________*/
	
	foreach var of varlist npa* {
		fre `var'
	}
	
/* Womens Political Participation ______________________________________________*/

	
	tab wpp_behavior, m
	
	* combo of woman would you run, and man would you let your wife run
	rename wpp_intention_woman wpp_behavior_self
	gen wpp_behavior_self_short = wpp_behavior_self/3 
	rename wpp_intention_man wpp_behavior_wife
	egen wpp_behavior_adult = rowmean(wpp_behavior_self_short wpp_behavior_wife)
	tab wpp_behavior_adult , m
	
/* Openness ____________________________________________________________________*/
	
	gen prej_yesnbr_hiv = neighbor_hiv
	gen prej_yesnbr_unmarried = neighbor_unmarried
	gen prej_yesnbr_albino = neighbor_albino
	egen prej_yesnbr_index = rowmean(prej_yesnbr_hiv prej_yesnbr_unmarried prej_yesnbr_albino)
	
	tab prej_yesnbr_index , m
		
/* Kid Marry ___________________________________________________________________*/

	gen prej_kidmarry_notrelig = kidmarry_notreligion
		replace prej_kidmarry_notrelig = kidmarry_notreligion_replchr if svy_type == 4 & resp_religion == 2
		replace prej_kidmarry_notrelig = kidmarry_notreligion_replmus if svy_type == 4 & resp_religion == 3
	gen prej_kidmarry_nottribe = kidmarry_nottribe
	gen prej_kidmarry_nottz = kidmarry_nottz
	
	egen prej_kidmarry_index = rowmean(prej_kidmarry_notrelig prej_kidmarry_nottribe prej_kidmarry_nottz)
	tab prej_kidmarry_index , m

	
/* Political participation and attitudes _______________________________________*/
	
	rename ppart_meeting ptixpart_raiseissue
	lab var ptixpart_raiseissue "Raised issue with gov't official in last year"
	
	rename ppart_meeting_which_1 ptixpart_raiseissue_gbv
	lab var ptixpart_raiseissue_gbv "Raised issue of GBV with gov't official"
	
	rename ppart_meeting_which_2 ptixpart_raiseissue_enviro
	lab var ptixpart_raiseissue_enviro "Raised issue of environment with gov't official"
	
	rename ppart_meeting_which_3 ptixpart_raiseissue_corrupt
	lab var ptixpart_raiseissue_corrupt "Raised issue of corruption with gov't official"
	
	rename ppart_meeting_which_4 ptixpart_raiseissue_safe
	lab var ptixpart_raiseissue_safe "Raised issue of safety with gov't official"
	
	foreach var of varlist ptixpart_raiseissue_* {
		replace `var' = 0 if ptixpart_raiseissue == 0
	}
		
	tab ppart_corruption , m
	
	recode crime_national (2 = 0 "Rare")(1 = 1 "Widespread"), gen(crime_natl)
		drop crime_national
		
	foreach var of varlist ppart_* crime_* {
		fre `var'
	}
		
/* Political knowledge and interest ____________________________________________*/

	recode pknow_interest (1 = 3 "Very interested")(2 = 2 "Somewhat interested")(3 = 1 "Not very interested")(4 = 0 "Not at all interested"), gen(ptixpart_interest)
	
	tab pknow_vp	
		rename pknow_vp sb_pknow_vp
		recode sb_pknow_vp (3 = 1 "Correct") (.o .d 4 2 1 -999 -222 = 0 "Wrong"), gen(ptixknow_natl_vp)
		
		rename pknow_ruto sb_pknow_ruto												// Decide whether to recode
		recode sb_pknow_ruto (2 = 1 "Correct") (.o .d 1 -999 -222 -888 = 0 "Wrong"), gen(ptixknow_fopo_ruto)
			
	lab var pknow_currentevent "Heard DP World story"
	gen ptixknow_natl_ports = pknow_currentevent
	
	rename pknow_responsibility ptixpref_resp

	tab ptixpref_resp
/**/		tab ptixpref_resp, gen(ptixpref_resp_)
		rename ptixpref_resp_1 ptixpref_resp_vill
		rename ptixpref_resp_2 ptixpref_resp_locgov 
		rename ptixpref_resp_3 ptixpref_resp_district 
		rename ptixpref_resp_4 ptixpref_resp_natgov
		
	gen ptixpref_resp_gov = ptixpref_resp_locgov + ptixpref_resp_natgov
	
/**/	tab pknow_trust
		tab pknow_trust, gen(pknow_trust_)
		rename pknow_trust_1 ptixknow_trustloc
		rename pknow_trust_2 ptixknow_trustnat
		rename pknow_trust_3 ptixknow_trustrel
		rename pknow_trust_4 ptixknow_trustradio
		cap rename pknow_trust_0 ptixknow_trustnone
		
	foreach var of varlist pknow_* {
		fre `var'
	}
	
	
/* Media Consumption ___________________________________________________________*/ // need to revise totally with Pangani Comm Survey cleaning

	* two weeks
		fre media_listen_radio
		rename media_listen_radio radio_listen
		gen radio_listen_twoweek = 1 if radio_listen == 1 | radio_listen == 2 | radio_listen == 3
				replace radio_listen_twoweek = 0 if radio_listen == 0
	fre radio_listen_twoweek	
			

			* 3 months
	rename media_radio_3month radio_ever
		replace radio_ever = 1 if  			radio_listen == 1 | ///
											radio_listen == 2 | ///
											radio_listen == 3 

	* hrs listening
	rename media_listen_radio_time radio_listen_hrs 
		replace radio_listen_hrs = 0 if radio_listen == 0

	* programs
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

		tab media_programs_oth														

	tab media_programs_total
	tab radio_type_ptix
	
	* radio statioms
		rename media_listen_sm_oth radio_stations_other
		egen radio_stations_total = rowtotal(media_listen_sm_*)	

		rename media_listen_sm_1 radio_stations_voa
		rename media_listen_sm_2 radio_stations_tbc
		rename media_listen_sm_3 radio_stations_tbctaifa
		rename media_listen_sm_4 radio_stations_efm
		rename media_listen_sm_5 radio_stations_breeze
		rename media_listen_sm_6 radio_stations_clouds
		rename media_listen_sm_7 radio_stations_maria
		rename media_listen_sm_8 radio_stations_rone
		rename media_listen_sm_9 radio_stations_huruma
		rename media_listen_sm_10 radio_stations_mwambao
		rename media_listen_sm_11 radio_stations_wasafi
		rename media_listen_sm_12 radio_stations_nuru
		rename media_listen_sm_13 radio_stations_uhuru
		rename media_listen_sm_14 radio_stations_bbc
		rename media_listen_sm_15 radio_stations_sautiyaamerica
		rename media_listen_sm_16 radio_stations_tk
		rename media_listen_sm_17 radio_stations_pfm
		rename media_listen_sm_18 radio_stations_ihsaan
		rename media_listen_sm_19 radio_stations_nuur
		rename media_listen_sm_20 radio_stations_rfa
		rename media_listen_sm_21 radio_stations_eastafricaradio
		rename media_listen_sm_22 radio_stations_othrelig
		rename media_listen_sm_23 radio_stations_kenyan
		rename media_listen_sm_24 radio_stations_imani
		rename media_listen_sm_25 radio_stations_safina
		rename media_listen_sm_26 radio_stations_utume
		rename media_listen_sm_27 radio_stations_kiss
		rename media_listen_sm_28 radio_stations_abood

		tab radio_stations_other										
		
			foreach var of varlist radio_stations_* {
				cap replace `var' = 0 if radio_ever == 0
			}
		
	tab radio_stations_total
	tab radio_stations_pfm
		
		rename media_hearleader_natl radio_natleader


/* Thermometer _________________________________________________________________*/

	gen thermo_local_leader1_num = thermo_local_leader_gen*5
	gen thermo_local_leader2_num = thermo_local_leader_spe*5
	egen thermo_local_leader_num = rowmax(thermo_local_leader1_num thermo_local_leader2_num)
	
	gen thermo_business_num = thermo_business*5

	gen thermo_boda1_num = thermo_boda_gen*5
	gen thermo_boda2_num = thermo_boda_spe*5
	egen thermo_boda_num = rowmax(thermo_boda1_num thermo_boda2_num)
	
	gen thermo_usa_num = thermo_usa*5

	gen thermo_samia_num = thermo_samiahassan*5
	
	tab thermo_local_leader_num
	tab thermo_business_num
	tab thermo_boda_num
	tab thermo_usa_num
	tab thermo_samia_num
	
	sum thermo_local_leader_num thermo_business_num thermo_boda_num  thermo_usa_num thermo_samia_num

	gen thermo_boda_short = thermo_boda_num/100									// recode		
	tab thermo_boda_short
		
/* Boda bora compliance __________________________________________________*/

	fre media_bodabora
	fre media_bodabora_content
	fre media_bodabora_text

/* Radio distribution compliance _______________________________________________*/

	rename s30q1 rd_receive
		replace rd_receive = 0 if rd_sample == 1 & rd_receive != 1
	rename s30q2 rd_stillhave
		replace rd_stillhave = 0 if rd_receive == 0
	rename s30q3 rd_receive_whylost
	rename s30q4 rd_receive_stillhave_confirm
	rename s30q5 rd_receive_stillhave_working
	rename s30q6 rd_receive_stillhave_whynowork
	rename s30q7 rd_receive_wholisten 
	rename s30q8 rd_receive_primarycontrol
	
	foreach var of varlist rd_receive_* {
		tab `var', m
	}

* Save _________________________________________________________________________*/

	save "${data}/02_mid_data/pfm_cm_3_2023_clean.dta", replace
											
				
				

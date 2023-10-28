
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Community Survye 1
Purpose: Import raw data and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2023/10/28
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	
/* Import  _____________________________________________________________________*/

	use "${ipa_cm_1_2020}/pangani_community_survey_encrypted_clean.dta", clear


/* Export  _____________________________________________________________________*/

	/* PII */
	save "${data}/01_raw_data/03_surveys/pfm_pii_cm_1_2020.dta", replace

	/* No PII */
	drop resp_name s5q5_name_r_1 s5q5_name_r_2 s5q5_name_r_3 s7q5_first_name_r_1 s7q5_second_name_r_1 s7q5_third_name_r_1 child_full_name_1 s7q5_first_name_r_2 s7q5_second_name_r_2 s7q5_third_name_r_2 child_full_name_2 s7q5_first_name_r_3 s7q5_second_name_r_3 s7q5_third_name_r_3 child_full_name_3 s7q5_first_name_r_4 s7q5_second_name_r_4 s7q5_third_name_r_4 child_full_name_4 s7q5_first_name_r_5 s7q5_second_name_r_5 s7q5_third_name_r_5 child_full_name_5 child_full_name_6 s7q5_first_name_r_7 s7q5_second_name_r_7 s7q5_third_name_r_7 child_full_name_7 s7q5_first_name_r_8 s7q5_second_name_r_8 s7q5_third_name_r_8 child_full_name_8 s7q5_first_name_r_9 s7q5_second_name_r_9 s7q5_third_name_r_9 child_full_name_9 s7q5_first_name_r_10 s7q5_second_name_r_10 s7q5_third_name_r_10 child_full_name_10 s7q5_first_name_r_11 s7q5_second_name_r_11 s7q5_third_name_r_11 child_full_name_11 child_name1_r_1 s7q7_r_1 s7q9_r_1 s7q10_r_1 child_name1_r_2 child_name1_r_3 child_name1_r_4 child_name1_r_5 child_name1_r_6 child_name1_r_7 child_name1_r_8 child_name1_r_9 child_name1_r_10 child_name1_r_11 s15q2_name_r_1 s15q2_name_r_2 s15q2_name_r_3 s15q2_name_r_4 s20q1b s20q1b_oth s20q2longitude s20q2latitude
	
	save "${data}/01_raw_data/03_surveys/pfm_nopii_cm_1_2020.dta", replace


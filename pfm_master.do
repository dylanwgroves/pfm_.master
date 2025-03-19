/*______________________________________________________________________________
	
	Purpose: Run dofiles from cleaning to analysis for the Pangani FM project
			 
	Stata version: 16
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19
	Date last modified: 											
________________________________________________________________________________*/


/* Stata Prep __________________________________________________________________*/	
  
  clear all 
  clear matrix
  clear mata		
  set more off 
  set maxvar 30000

 /* Set Seed ___________________________________________________________________*/

	set seed 1956

 
/* Set Globals _________________________________________________________________*/

	
	foreach user in  	"X:/" ///
						"/Users/BeatriceMontano"{
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"


	foreach user in  	"X:/Box" ///
						"/Volumes/Secomba/BeatriceMontano/Boxcryptor/Box Sync"  {
							
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global userboxcryptor `dir'
	display "${userboxcryptor}"	

	
	cap assert "$`{globals_set}'" == "yes"
	if _rc!=0 {   
		do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"	
		}
	else { 
		di "Globals have already been set."
	}
	
/* Part 1: Import ______________________________________________________________

* Note: This can only be run by authors with Boxcryptor Access

	/* Radio Distribution */

		do "${code}/pfm_.master/01_import/pfm_import_rd_distribution_as.do" // Distribution - Audio Screening 1
		do "${code}/pfm_.master/01_import/pfm_import_rd_distribution_ne.do" // Distribution - Natural Experiment
		
	/* Audio Screening */

		do "${code}/pfm_.master/01_import/pfm_import_as_sample.do" 							// Sampling
		do "${code}/pfm_.master/01_import/pfm_import_as_baseline.do" 						// Baseline
		do "${code}/pfm_.master/01_import/pfm_import_as_midline.do" 						// Midline
		do "${code}/pfm_.master/01_import/pfm_import_as_endline.do" 						// Endline
		do "${code}/pfm_.master/01_import/pfm_import_as_endline_partner.do" 				// Endline (Partner)
		do "${code}/pfm_.master/01_import/pfm_import_as_endline_friend.do" 					// Endline (Friend)
		do "${code}/pfm_.master/01_import/pfm_import_as_endline_kid.do" 					// Endline (Kid)
	

	/* Natural Experiment */
	
		do "${code}/pfm_.master/01_import/pfm_import_ne_sample.do" 							// Sample
		do "${code}/pfm_.master/01_import/pfm_import_ne_baseline.do" 						// Baseline
		do "${code}/pfm_.master/01_import/pfm_import_ne_endline.do" 						// Endline
	
	
	/* Village Master */
	
		do "${code}/pfm_.master/01_import/pfm_import_villagemaster.do"  					// Tanzania census of all villages

	/* Village Leaders */	
		
		do "${code}/pfm_.master/01_import/pfm_import_leader.do" 							// Leader survey
	
	
	/* Audio Screening 2 */
	
																							// Sampling
		do "${code}/pfm_.master/01_import/pfm_import_as2_baseline.do" 						// Baseline
		do "${code}/pfm_.master/01_import/pfm_import_as2_midline.do" 						// Midline
		do "${code}/pfm_.master/01_import/pfm_import_as2_endline.do" 						// Endline
		do "${code}/pfm_.master/01_import/pfm_import_as2_endline_partner.do" 				// Endline (Partner)
		do "${code}/pfm_.master/01_import/pfm_import_as2_endline_kid.do" 					// Endline (Kid)

	/* Community Media in Pangani 	*/
																						
		do "${code}/pfm_.master/01_import/pfm_import_cm_1_2020.do" 						// First Wave 	2020
		do "${code}/pfm_.master/01_import/pfm_import_cm_2_2021.do" 						// Second Wave 	2021
		*do "${code}/pfm_.master/01_import/pfm_import_cm_3_2023.do" 						// Third Wave 	2023

*/	
		
/* Part 2: Randomization ________________________________________________________

	/* Radio Distribution */
		
		do "${code}/pfm_.master/02_randomization/pfm_randomization_rd_as.do" 				// Randomization of Radio Distribution in Audio screening
		do "${code}/pfm_.master/02_randomization/pfm_randomization_rd_ne.do" 				// Randomization of Radio Distribution in Natural experiment
		*do "${code}/pfm_.master/02_randomization/pfm_ri_rd_as.do"
		*do "${code}/pfm_.master/02_randomization/pfm_ri_rd_ne.do"

	/* Audio Screening */

		do "${code}/pfm_.master/02_randomization/pfm_randomization_as.do" 					// Randomization - Audio screening 1
	
	
	/* Natural Experiment */
	
		* No Randomization for Natural Experiment: it was instead generated using GenMatch								

	/* Audio Screening 2 */
	
		do "${code}/pfm_.master/02_randomization/pfm_randomization_as2.do" 					// Randomization - Audio screening 2
		
		/* Community Media */
	
		* No Randomization for Community Media

*/

/* Part 2: Cleaning ____________________________________________________________
Tasks: Clean, and generate variables 
	Note: Preliminary data collection and PII removal occurs in Box Folders
		  Need to go back and do recoding throughout 							*/

	/* Radio Distribution */
	
		do "${code}/pfm_.master/03_clean/pfm_clean_rd_distribution_as.do" 					// Distribution - Audio Screening
		do "${code}/pfm_.master/03_clean/pfm_clean_rd_distribution_ne.do" 					// Distribution - Natural Experiment
	
		
	/* Audio Screening */

		do "${code}/pfm_.master/03_clean/pfm_clean_as_baseline.do" 							// Baseline	
		do "${code}/pfm_.master/03_clean/pfm_clean_as_midline.do" 							// Midline
		do "${code}/pfm_.master/03_clean/pfm_clean_as_endline.do" 							// Endline
		do "${code}/pfm_.master/03_clean/pfm_clean_as_endline_partner.do"					// Endline (Partner)
		do "${code}/pfm_.master/03_clean/pfm_clean_as_endline_friend.do"					// Endline (Friend)		
		do "${code}/pfm_.master/03_clean/pfm_clean_as_endline_kid.do"						// Endline (Kid)
	
					
	/* Natural Experiment */
	
		do "${code}/pfm_.master/03_clean/pfm_clean_ne_baseline.do" 							// Baseline
		do "${code}/pfm_.master/03_clean/pfm_clean_ne_endline.do" 							// Endline
	
	
	/* Audio Screening 2 */

		do "${code}/pfm_.master/03_clean/pfm_clean_as2_baseline.do" 						// Baseline	
		do "${code}/pfm_.master/03_clean/pfm_clean_as2_midline.do" 							// Midline
		do "${code}/pfm_.master/03_clean/pfm_clean_as2_endline.do" 							// Endline
		do "${code}/pfm_.master/03_clean/pfm_clean_as2_endline_partner.do"					// Endline (Partner)
		do "${code}/pfm_.master/03_clean/pfm_clean_as2_endline_kid.do"						// Endline (Kid)
*		do "${code}/pfm_.master/03_clean/pfm_surveyCTO_as2_endline.do"						// Endline - cases with randomizations within surveyCTO
*		do "${code}/pfm_.master/03_clean/pfm_surveyCTO_as2_endline.do"						// Endline (Partner) - cases with randomizations within surveyCTO
*		do "${code}/pfm_.master/03_clean/pfm_surveyCTO_as2_endline.do"						// Endline (Kid) - cases with randomizations within surveyCTO
	
	
/* Part 3: Merge _______________________________________________________________
	Tasks: Merge different samples into one dta 								 */
 
		/* Main Files */

			do "${code}/pfm_.master/04_merge/pfm_merge_cm.do" 								// Community Surveys
			do "${code}/pfm_.master/04_merge/pfm_merge_ne.do" 								// Natural Experiment
			do "${code}/pfm_.master/04_merge/pfm_merge_as.do" 								// Audio Screening
			do "${code}/pfm_.master/04_merge/pfm_merge_as2.do" 								// Audio Screening 2


		/* Append Together AS1 + NE */
		
			do "${code}/pfm_.master/04_merge/pfm_append_as1_ne.do" 								// Append Natural Experiment and Audio Screening 1

		/* Append Together AS1 + AS2 */
		
			do "${code}/pfm_.master/04_merge/pfm_append_as1_as2.do" 							// Append Audio Screening 1 and Audio Screening 2
	
		
			
	

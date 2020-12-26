/*______________________________________________________________________________
	
	Purpose: Run dofiles from cleaning to analysis for the Pangani FM project
			 
	Stata version: 15
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19
	Date last modified: 											
________________________________________________________________________________*/


/* Stata Prep __________________________________________________________________*/	
  
  *version 15 
  clear all 
  clear matrix
  clear mata		
  set more off 
 
 
 

/* Part 0: Set Globals _________________________________________________________*/

	foreach user in  "X:" "/Users/BeatriceMontano" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"

	cap assert "$`{globals_set}'" == "yes"
	if _rc!=0 {  
		* Set the path below to lead to the globals dofile. 
		do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"	
		* Now open the globals dofile, and set paths as needed 
		}
	else { 
		di "Globals have already been set."
	}



/* Part 1: Import ______________________________________________________________*/

* Tasks: Import files from Box, remove PII
* Note: This can only be run by authors with Boxcryptor Access

	/* Radio Distribution */
		
		do "${code}/01_import/pfm_import_rd_randomization_ne.do" // Randomization - Audio screening
		do "${code}/01_import/pfm_import_rd_randomization_ne.do" // Randomizatoin - Natural experiment

		do "${code}/01_import/pfm_import_rd_distribution_as.do" // Distribution - Audio Screening
		do "${code}/01_import/pfm_import_rd_distribution_ne.do" // Distribution - Natural Experiment
		
	/* Audio Screening */

		do "${code}/01_import/pfm_import_as_sample.do" 							// Randomization
		do "${code}/01_import/pfm_import_as_baseline.do" 						// Baseline
		do "${code}/01_import/pfm_import_as_midline.do" 						// Midline
		do "${code}/01_import/pfm_import_as_endline.do" 						// Endline
		do "${code}/01_import/pfm_import_as_endline_partner.do" 				// Endline (Partner)

	/* Natural Experiment */
	
		do "${code}/01_import/pfm_import_ne_sample.do" 							// Sample
		do "${code}/01_import/pfm_import_ne_baseline.do" 						// Baseline
		do "${code}/01_import/pfm_import_ne_endline.do" 						// Endline


	/* Village Master */
	
		do "${code}/01_import/pfm_import_villagemaster.do" // Tanzania census of all villages




/* Part 2: Randomzation ________________________________________________________

Note that only radio distribution and audio screening are randomized, the natural
experiment was generated using GenMatch											*/


	/* Radio Distribution */
		
		do "${code}/02_randomization/pfm_randomization_rd_as.do" 				// Randomization - Audio screening
		do "${code}/02_randomization/pfm_randomization_rd_ne.do" 				// Randomization - Natural experiment
		*do "${code}/02_randomization/pfm_ri_rd_as.do"
		*do "${code}/02_randomization/pfm_ri_rd_ne.do"

	/* Audio Screening */

		do "${code}/02_randomization/pfm_randomization_as.do" 					// Randomization
	
	/* Natural Experiment */
	
		* No Randomization for Natural Experiment 								





/* Part 2: Cleaning ____________________________________________________________

Tasks: Clean, and generate variables 
	Note: Prelimenary data collection and PII removal occurs in Box Folders
		  Need to go back and do recoding throughout 							*/

	/* Radio Distribution */
	
		do "${code}/03_clean/pfm_clean_rd_distribution_as.do" 					// Distribution - Audio Screening
		do "${code}/03_clean/pfm_clean_rd_distribution_ne.do" 					// Distribution - Natural Experiment

		
	/* Audio Screening */

		do "${code}/03_clean/pfm_clean_as_baseline.do" 							// Baseline
		do "${code}/03_clean/pfm_clean_as_midline.do" 							// Midline
		do "${code}/03_clean/pfm_clean_as_endline.do" 							// Endline
		do "${code}/03_clean/pfm_clean_as_endline_partner.do"					// Endline (Partner)

	
	/* Natural Experiment */
	
		do "${code}/03_clean/pfm_clean_ne_baseline.do" 							// Baseline
		do "${code}/03_clean/pfm_clean_ne_endline.do" 							// Endline

	
	
	
/* Part 3: Merge _______________________________________________________________*/

/* Tasks: Clean, and generate variables 
 Note: Prelimenary data collection and PII removal occurs in Box Folders */
 
 
		/* Main Files */

			do "${code}/04_merge/pfm_merge_ne.do" 									// Natural Experiment
			do "${code}/04_merge/pfm_merge_as.do" 									// Audio Screening


		/* Append Together */
		
			do "${code}/04_merge/pfm_append.do" 									// Append Natural Experiment and Audio Screening


			

/* Part 4: New Vars ____________________________________________________________

	CONSIDERING GETTING RID OF NEW VARS
		The thinking is that we should do new variables before cleaning/merging
		And anything necessary for a specific analysis that doenst affect
		the other projects can just be done with a "prelim" file in that project's
		folder
*/


* Tasks: Clean, and generate variables 
* Note: Prelimenary data collection and PII removal occurs in Box Folders

	*do "${code}/05_newvars/pfm_newvars.do" 	// Merge Audio Screening Baseline and Endline

			


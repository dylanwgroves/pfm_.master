
/*______________________________________________________________________________
	
	Purpose: Set globals for Pangani FM project
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19 											
________________________________________________________________________________*/


/* Stata Prep ___________________________________________________________________*/

	clear all 	
	clear matrix
	clear mata
	set more off 
	set maxvar 30000

/* Set Seed ___________________________________________________________*/

	set seed 1956

/* Set Globals _________________________________________________________*/

	
	foreach user in  	"X:/" ///
						"C:\Users\grovesd\" ///
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


/* Main folders ________________________________________________________________*/

		/* Main */
		global code "${user}/Documents"
		global data "${user}/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data"
		
		/* Output */
		global output "${user}/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs"
		global output_final "${user}/Dropbox/Apps/Overleaf"


/* Importing and Cleaning _______________________________________________________*/
				
		/* IPA source files */
		
			/* Community Surveys */
			global ipa_cm_1_2020 		"${userboxcryptor}/19_Community Media Endlines/07_Questionnaires & Data/05 Uzikwasa/03 Data Flow/03 clean"
			global ipa_cm_2_2021 		"${userboxcryptor}/30_Community Media II (Wellspring)/07&08 Questionnaires & Data/01_Community Survey/05_data/02_survey/03 clean"
			global ipa_cm_3_2023 		"${userboxcryptor}/07_Questionnaires & Data/05_Community survey/03 Data Flow/4_data_encrypted/2_survey"
		
			/* Natural Experiment */
			global ipa_ne 				"${userboxcryptor}/08_PanganiFM/PanganiFM/2 - Data and Analysis"
			global ipa_ne_endline 		"${userboxcryptor}/19_Community Media Endlines/07_Questionnaires & Data/06_NE/05_data_encrypted/02_survey/03_clean"
		
			/* Audio Screening */
			global ipa_as 				"${userboxcryptor}/17_PanganiFM_2/07&08 Questionnaires & Data/03 Baseline/04_Data Quantitative/02 Main Survey Data"
			global ipa_as_midline 		"${userboxcryptor}/19_Community Media Endlines/04_Research Design/04 Randomization & Sampling"
			global ipa_as_endline 		"${userboxcryptor}/19_Community Media Endlines/07_Questionnaires & Data/07_AS/05_data_encrypted/02_survey/03_clean"
			global ipa_as_endline_spill "${userboxcryptor}/19_Community Media Endlines/07_Questionnaires & Data/08_Spillover/05_data_encrypted/02_survey"
			global ipa_leader 			"${userboxcryptor}/19_Community Media Endlines/07_Questionnaires & Data/09_leaders/03 Data Flow/02_imported/"

			/* Audio Screening 2 */
			global ipa_as2 				"${userboxcryptor}/30_Community Media II (Wellspring)/07&08 Questionnaires & Data/03 Baseline/05_data/02_survey/3_clean/"
			global ipa_as2_midline 		"${userboxcryptor}/30_Community Media II (Wellspring)/07&08 Questionnaires & Data/04 Midline/05_data/02_survey/03_clean/"
			global ipa_as2_endline 		"${userboxcryptor}/07_Questionnaires & Data/04 Endline/03 Data Flow/4_data/2_survey_encrypted"
			

		
/* Analysis ____________________________________________________________________*/


		/* Natural Experiment */
		global data_ne 			"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Natural Experiment/01 Data"
		global ne_tables 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Natural Experiment/03 Tables and Figures"

		/* Audio Screening */
		
			/* FM */
			global data_as 			"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (efm)/01 Data"
			global data_as_village 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (midline)/01 Data"
			global as_tables 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (efm)/03 Tables and Figures"
			
			/* HIV Results */
			global data_hiv 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv)/01 Data"
			global hiv_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv)/03 Tables and Figures"

		/* Audio Screening 2*/	 
		
			/* Boda Bora */
			global data_bb 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening 2 (gbv)/01_data"
			global bb_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening 2 (gbv)/03_tables"
			
			/* Environment */
			global data_env 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening 2 (enviro)/01_data"
			global env_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening 2 (enviro)/03_tables"

			
		/* Radio Distribution */
		global data_rd 			"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/01 Data"
		global rd_tables 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/03 Tables and Figures"

		/* Political Priorities */
		global data_priorities 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Political Priorities/01_data"
		global priorities_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Political Priorities/03_tables"
		
		/* Court */
		global data_court 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Court/01_data"
		global court_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Court/03_tables"
		
		/* Development News */
		global data_devnews 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Development News/01_data"
		global devnews_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Development News/03_tables"
		
		/* Womens Political Participation */
		global data_wpp 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Womens Political Participation/01_data"
		global wpp_tables 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Womens Political Participation/03_tables"
		
		/* Enumerator Effects */
		global data_enumeffects 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Enumerator Effects/01_data"
		global enumeffects_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Enumerator Effects/03_tables"
		
		/* Election */
		global data_election 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania  - Election/01_data"
		global election_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania  - Election/03_tables"

		/* Household roles */
		global data_hhroles 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HH Roles/01_data"
		global hhroles_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HH Roles/03_output"
		
		/* Socialization */
		global data_socialization 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Socialization/01_data"
		global socialization_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Socialization/03_output"
		
		/* HetFX */
		global data_hetfx 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HetFX/01 Data"
		global hetfx_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HetFX/03 Tables and Figures"
		
		/* Spillovers */
		global data_spill 		"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Spillovers/01 Data"
		global spill_tables 	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Spillovers/03 Tables and Figures"

			
/* Clean Tables and Figures ____________________________________________________*/

	/* Natural Experiment */
	global ne_clean_tables 		"${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment/Tables"
	global ne_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment/Figures"
	global ne_clean_tables_new 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment Research Note/Tables"
	global ne_clean_figures_new "${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment Research Note/Figures"
	
	/* WPP Experiment */
	global wpp_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - WPP/Tables"
	global wpp_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - WPP/Figures"

	/* Radio Distribtuion */
	global rd_clean_tables 		"${user}/Dropbox/Apps/Overleaf/Tanzania - Radio Distribution/Tables"
	global rd_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Radio Distribution/Figures"
	
	/* EFM Audio Screening */
	global as_clean_tables 		"${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (efm)/Tables"
	global as_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (efm)/Figures"
	
	/* HetFX */	
	global hetfx_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Heterogeneous Treatment Effects/Tables"
	global hetfx_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Heterogeneous Treatment Effects/Figures" 
	
	/* Court */
	global court_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Court/Tables"
	global court_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Court/Figures" 
		
	/* Development News */
	global devnews_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Development News/Tables"
	global devnews_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Development News/Figures" 
	
	/* Spillovers */
	global spill_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Spillovers/Tables"
	global spill_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Spillovers/Figures"

	/* BodaBora - Audio Screening 2 */
	global bb_clean_tables 		"${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (bodabora)/01_Tables"
	global bb_clean_figures 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (bodabora)/02_Figures"
	
	/* Political Priorities */
	global priorities_clean_tables 	"${user}/Dropbox/Apps/Overleaf/Tanzania - Political Priorities/01_Tables"
	global priorities_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Political Priorities/02_Figures"
	
	
/* Set Date _____________________________________________________________________*/

	global date : di %tdDNCY daily("$S_DATE", "DMY")

	
/* Indicate whether the globals have been set __________________________________*/

	global globals_set "yes"

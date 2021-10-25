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

	foreach user in  "X:" "/Users/BeatriceMontano" "/Users/Bardia" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"

	foreach user in  "X:" "/Volumes/Secomba/BeatriceMontano/Boxcryptor" "/Volumes/Secomba/Bardia/Boxcryptor" {
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
		
			/* Natural Experiment */
			global ipa_ne "${userboxcryptor}/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis"
			global ipa_ne_endline "${userboxcryptor}/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/06_NE/05_data_encrypted/02_survey/03_clean"
		
			/* Audio Screening */
			global ipa_as "${userboxcryptor}/Box Sync/17_PanganiFM_2/07&08 Questionnaires & Data/03 Baseline/04_Data Quantitative/02 Main Survey Data"
			global ipa_as_midline "${userboxcryptor}/Box Sync/19_Community Media Endlines/04_Research Design/04 Randomization & Sampling"
			global ipa_as_endline "${userboxcryptor}/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/07_AS/05_data_encrypted/02_survey/03_clean"
			global ipa_as_endline_spill "${userboxcryptor}/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/08_Spillover/05_data_encrypted/02_survey"
			global ipa_leader "${userboxcryptor}/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/09_leaders/03 Data Flow/02_imported/"


		global ipa_endline "${userboxcryptor}/Box Sync/19_Community Media Endlines"


		
/* Analysis ____________________________________________________________________*/


		/* Natural Experiment */
		global data_ne "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Natural Experiment/01 Data"
		global ne_tables	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Natural Experiment/03 Tables and Figures"
		
		/* Audio Screening */	
			/* FM */
			global data_as "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (endline)/01 Data"
			global as_tables	"${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (endline)/03 Tables and Figures"
			
			/* HIV Results */
			global data_hiv "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv)/01 Data"
			global hiv_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv)/03 Tables and Figures"

		/* Radio Distribution */
		global data_rd "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/01 Data"
		global rd_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/03 Tables and Figures"
		
		/* Court */
		global data_court "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Court/01_data"
		global court_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Court/03_tables"
		
		/* Development News */
		global data_devnews "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Development News/01_data"
		global devnews_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Development News/03_tables"
		
		/* Womens Political Participation */
		global data_wpp "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Womens Political Participation/01_data"
		global wpp_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Womens Political Participation/03_tables"
		
		/* Pluralistic Ignorance */
		global data_pi "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Pluralistic Ignorance/01_data"
		global pi_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Pluralistic Ignorance/03_output"
		
		/* Enumerator Effects */
		global data_enumeffects "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Enumerator Effects/01_data"
		global enumeffects_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Enumerator Effects/03_tables"
		
		/* Election */
		global data_election "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania  - Election/01_data"
		global election_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania  - Election/03_tables"

		/* Household roles */
		global data_hhroles "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HH Roles/01_data"
		global hhroles_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HH Roles/03_output"
		
		/* Socialization */
		global data_socialization "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Socialization/01_data"
		global socialization_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Socialization/03_output"
		
		/* HetFX */
		global data_hetfx "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HetFX/01 Data"
		global hetfx_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - HetFX/03 Tables and Figures"
		
		/* Spillovers */
		global data_spill "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Spillovers/01 Data"
		global spill_tables "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Spillovers/03 Tables and Figures"

			
/* Clean Tables and Figures ____________________________________________________*/

	/* Natural Experiment */
	global ne_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment/Tables"
	global ne_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Natural Experiment/Figures"

	/* WPP Experiment */
	global wpp_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - WPP/Tables"
	global wpp_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - WPP/Figures"

	/* Radio Distribtuion */
	global rd_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Radio Distribution/Tables"
	global rd_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Radio Distribution/Figures"
	
	/* EFM Audio Screening */
	global as_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (FM)/Tables"
	global as_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (FM)/Figures"
	
	/* HetFX */
	global hetfx_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Heterogeneous Treatment Effects/Tables"
	global hetfx_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Heterogeneous Treatment Effects/Figures" 
	
	/* Court */
	global court_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Court/Tables"
	global court_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Court/Figures" 
	
	/* Development News */
	global devnews_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Development News/Tables"
	global devnews_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Development News/Figures" 
	
	/* Spillovers */
	global spill_clean_tables "${user}/Dropbox/Apps/Overleaf/Tanzania - Spillovers/Tables"
	global spill_clean_figures "${user}/Dropbox/Apps/Overleaf/Tanzania - Spillovers/Figures"


	
	
/* Set Date _____________________________________________________________________*/

	global date : di %tdDNCY daily("$S_DATE", "DMY")

	
/* Indicate whether the globals have been set __________________________________*/

	global globals_set "yes"


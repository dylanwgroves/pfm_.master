/*______________________________________________________________________________
	
	
	Purpose: Set globals for Pangani FM project
			 
	Stata version: 15
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19
	
	Set Seeed
	Set Globals
	Set Date
	Run Programs
	
 											
______________________________________________________________________________*/


/* Stata Prep ___________________________________________________________________*/

	*version 15 
	clear all 
	clear matrix
	clear mata
	set more off 
	set maxvar 30000


/* Set Seed ___________________________________________________________*/

	set seed 1956

 
/* Set Globals _________________________________________________________*/

	/* Bea */
	foreach user in  "X:" "/Users/BeatriceMontano" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"

		/* Main */
		global code "${user}/Documents/pfm_.master"
		global data "${user}/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data"
		
		/* Output */
		global output "${user}/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs"
		global output_final "${user}/Dropbox/Apps/Overleaf"
		
		/* IPA source files */
			/* Natural Experiment */
			global ipa_ne "${user}\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis"
			global ipa_ne_endline "${user}\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\06_NE\05_data_encrypted\02_survey\03_clean"
		
			/* Audio Screening */
			global ipa_as "${user}\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data"
			global ipa_as_endline "${user}/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/07_AS/05_data_encrypted/02_survey/03_clean"
		
			global ipa_endline "${user}\Box Sync\19_Community Media Endlines"
		
		/* Natural Experiment */
		global data_ne "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Natural Experiment/01 Data"
		global ne_tables	"${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Natural Experiment\03 Tables and Figures"
		
		/* Audio Screening */	
			/* FM */
			global data_as "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (endline)/01 Data"
			global as_tables	"${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Audio Screening (endline)\03 Tables and Figures"
		
			/* HIV Results */
			global data_hiv "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv)/01 Data"
			global hiv_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Audio Screening (hiv)\03 Tables and Figures"

		/* Radio Distribution */
		global data_rd "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Radio Distribution/01 Data"
		global rd_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Radio Distribution\03 Tables and Figures"
		
		/* Court */
		global data_court "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Court/01_data"
		global court_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Court\03_tables"
		
		/* Womens Political Participation */
		global data_wpp "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Womens Political Participation/01_data"
		global wpp_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Womens Political Participation\03_tables"
		
		/* Pluralistic Ignorance */
		global data_pi "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Pluralistic Ignorance/01_data"
		global pi_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Pluralistic Ignorance\03_tables"
		
		/* Enumerator Effects */
		global data_enumeffects "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Enumerator Effects/01_data"
		global enumeffects_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania - Enumerator Effects\03_tables"
	
		/* Election */
		global data_enumeffects "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania  - Election/01_data"
		global enumeffects_tables "${user}\Dropbox\Wellspring Tanzania Papers\Wellspring Tanzania  - Election\03_tables"
	
/*		
	
	/* Dylan */
	if "`c(username)'" == "dylan" {
			
		/* Maine */
		global code "X:\Documents/pfm_.master"
		global data "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data"
		
		/* Output */
		global output "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\02_outputs"
		global output_final "X:\Dropbox/Apps/Overleaf"
		
		/* IPA source files */
		global ipa_ne "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis"
		global ipa_ne_endline "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\06_NE\05_data_encrypted\02_survey\03_clean"
		global ipa_as "X:\Box Sync\17_PanganiFM_2\07&08 Questionnaires & Data\03 Baseline\04_Data Quantitative\02 Main Survey Data"
		global ipa_as_endline "X:/Box Sync/19_Community Media Endlines/07_Questionnaires & Data/07_AS/05_data_encrypted/02_survey/03_clean"
		global ipa_endline "X:\Box Sync\19_Community Media Endlines"
		
	}

*/

/* Set Date _____________________________________________________________________*/

	global date : di %tdDNCY daily("$S_DATE", "DMY")


/* Indicate Globals Set _________________________________________________________*/

	global globals_set "yes"


	di "${code}"
	di "${data}"



/* Page 2: Run Programs ________________________________________________________

do "${code}/02_code/pfm_programs.do"

*/

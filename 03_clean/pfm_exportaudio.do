	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Courts and Attitudes
Purpose: Analysis Prelimenary Work
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/01/01


	This mostly just subsets the data and does anything else necessary before
	running the analysis
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_partner
	tempfile temp_friend

	
/* Deal with Partner Survey ____________________________________________________*/

	use "${data}/03_final_data/pfm_appended_noprefix.dta", clear
	drop 
	keep if p_svy_partner == 1
	keep p_* id_village_uid
	rename p_* *
	rename s17q8 audio
	
	global source_as "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\01_raw\media"
	
	*make folders	
	cap mkdir "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\em_records\partner\"
	
	count
	local num = r(N)

	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof id_resp_uid, local(sb_uid)
				global uid `sb_uid'
					
			replace audio = subinstr(audio, "media\", "", .)
			
				*capture original file name
				levelsof audio, local(sb_file)
				global file `sb_file'
				
			cap copy 	"${source_as}/${file}" ///
					"X:\Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/em_records/partner/${uid}.wav"
							
				macro drop uid
				macro drop file
				macro drop typefile 
				
		restore
	
		}

/* Deal with Main Survey ____________________________________________________*/

	use "${data}/03_final_data/pfm_appended_noprefix.dta", clear
	rename s17q8 audio
	
	global source_as "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\01_raw\media"
	
	*make folders	
	cap mkdir "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\em_records\main\"
	
	count
	local num = r(N)

	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof id_resp_uid, local(sb_uid)
				global uid `sb_uid'
					
			replace audio = subinstr(audio, "media\", "", .)
			
				*capture original file name
				levelsof audio, local(sb_file)
				global file `sb_file'
				
			cap copy 	"${source_as}/${file}" ///
						"X:\Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/em_records/main/${uid}.wav"
							
				macro drop uid
				macro drop file
				macro drop typefile 
				
		restore
	
		}

		
		
/* Deal with Main Survey ____________________________________________________*/

	use "${data}/03_final_data/pfm_appended_noprefix.dta", clear
	drop s17q8
	keep if f_svy_friend== 1
	keep f_* id_village_uid id_resp_uid
	rename f_* *
	rename s17q8 audio
	
	global source_as "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\08_Spillover\05_data_encrypted\02_survey\01_raw\media"
	
	*make folders	
	cap mkdir "X:\Dropbox\Wellspring Tanzania Papers\wellspring_01_master\01_data\02_mid_data\em_records\friend\"
	
	count
	local num = r(N)

	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof id_resp_uid, local(sb_uid)
				global uid `sb_uid'
					
			replace audio = subinstr(audio, "media\", "", .)
			
				*capture original file name
				levelsof audio, local(sb_file)
				global file `sb_file'
				
			cap copy 	"${source_as}/${file}" ///
					"X:\Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/em_records/friend/${uid}.wav"
							
				macro drop uid
				macro drop file
				macro drop typefile 
				
		restore
	
		}

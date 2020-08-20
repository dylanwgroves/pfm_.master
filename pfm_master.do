/*______________________________________________________________________________
	
	Purpose: Run dofiles from cleaning to analysis for the Pangani FM project
			 
	Stata version: 15
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date created: 2020/08/19
	Date last modified: 											
______________________________________________________________________________*/


* Stata Prep
  version 15 
  clear all 
  clear matrix
  clear mata
  set more off 
  set maxvar 30000
 
 
* Part 0: Set Globals _________________________________________________________*

gl code "C:\Users\dylan\Documents\pfm_.master\03_cleaning"						// These need to be updated
gl dta "X:\Box Sync\Wellspring Tanzania Papers"

*_______________________________________________________________________________



/* Part 1: Cleaning __________________________________________________________*/


* Tasks: Clean, and generate variables 
* Note: Prelimenary data collection and PII removal occurs in Box Folders

			do "${code}\pfm_ne_baseline_cleaning.do" 	// Natural Experiment Baseline
			do "${code}\pfm_as_baseline_cleaning.do"  	// Audio Screening Baseline
			do "${code}\pfm_as_midline_cleaning.do" 	// Audio Screening Midline
			
*_______________________________________________________________________________
			

			
			
/* Part 2: Merging ____________________________________________________________*/


* Tasks: Clean, and generate variables 
* Note: Prelimenary data collection and PII removal occurs in Box Folders

			do "${code}\pfm_ne_baseline_cleaning.do" 	// Merge Audio Screening Baseline and Endline
			do "${code}\pfm_as_baseline_cleaning.do"  	// Merge Screening
			
*_______________________________________________________________________________



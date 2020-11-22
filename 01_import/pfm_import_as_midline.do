
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening  
Purpose: Import midline and remove PII
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	set seed 1956

/* Import  _____________________________________________________________________*/

	import delimited "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\02_uzikwasa_survey\pfm_uzikwasasurvey_sample_v2.csv", clear 


/* Randomize ___________________________________________________________________*/

sort distance
gen random1 = runiform()
gen random2 = runiform()

sort block random1 random2
bys block : gen rank = _n

sort block random2 random1
bys ward_name: gen rank_ward = _n

** Randomly select by ward
gen ward_sample = 0
replace ward_sample = 1 if rank_ward == 1

** Generate Sampled Variables
gen uzikwasa_sample = 0
replace uzikwasa_sample = 1 if block == 4 & rank <= 3
replace uzikwasa_sample = 1 if block == 3 & rank <= 4
replace uzikwasa_sample = 1 if block == 2 & rank == 1	// Only one in the city
replace uzikwasa_sample = 1 if block == 1 & rank <= 5



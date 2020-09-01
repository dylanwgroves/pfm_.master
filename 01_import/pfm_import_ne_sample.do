
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening  
Purpose: Import treatment assignment
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/

	clear all	
	clear matrix
	clear mata
	set more off
	version 15 
	set maxvar 30000

/* Import  _____________________________________________________________________*/

	import delimited "${ipa_ne}/2 - Final Data/genmatch_sample_2018.08.01.csv", encoding(ISO-8859-1)
	
	
/* Basic Cleaning ______________________________________________________________*/

	keep objectid region_cod region_nam district_c district_n ward_code ward_name ///
				vil_mtaa_c vil_mtaa_n shape_leng shape_area vtreat match ///
				q1_2_geopointlatitude q1_2_geopointlongitude q1_2_geopointaltitude ///
				q1_2_geopointaccuracy q4_0_geopointlatitude q4_0_geopointlongitude ///
				q4_0_geopointaltitude q4_0_geopointaccuracy

	rename region_cod region_c
	rename region_nam region_n
	rename ward_code ward_c
	rename ward_name ward_n
	rename vil_mtaa_c village_c
	rename vil_mtaa_n village_n
	rename vtreat treat
	rename q1_2_geopointlatitude latitude
	rename q1_2_geopointlongitude longitude
	
	order region_n region_c district_c district_n ward_c ward_n village_n village_c
	
	egen village_id = concat(district_c ward_c village_c), punct(_)
	
	gen sample = "ne"


/* Export  _____________________________________________________________________*/

	save "${data}\01_raw_data\pfm_sample_ne.dta", replace



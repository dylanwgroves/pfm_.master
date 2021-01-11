
/* Basics ______________________________________________________________________

Project: Wellspring Tanzania Tanzania Villages
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

	import delimited "${user}/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/TZvillages.csv", encoding(ISO-8859-2) clear 

/* Clean _______________________________________________________________________*/

	rename region_cod 	id_region_c
	rename region_nam 	id_region_n
	rename district_c 	id_district_c
	rename district_n 	id_district_n
	rename ward_code 	id_ward_c
	rename ward_name	id_ward_n
	rename vil_mtaa_c	id_village_c
	rename vil_mtaa_n	id_village_n
	
	keep if id_region_n == "Tanga"
	
	egen village_id = concat(id_district_c id_ward_c id_village_c), punct(-)
	
	drop shape_leng shape_area distance x250_cov v1
	
/* Export  _____________________________________________________________________*/

	save "${data}/01_raw_data/pfm_allvills_clean.dta", replace



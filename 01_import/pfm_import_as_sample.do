
/* _____________________________________________________________________________

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

	import delimited "${data}/01_raw_data/01_sample/pfm_as_villages.csv", clear 
	drop if ward_n == "Ndolwa"		// Kept for replacement

/* Clean _______________________________________________________________________*/

	keep district_c district_n ward_c ward_n village_n village_c radius dist_road ///
			dist_pfm dist_town area region_n region_c length latitude longitude ///
			dist_road_cent dist_coast vill_dist_pfm vill_dist_road vill_dist_town ///
			villcent_lat villcent_long vill_id
	
	order region_n region_c district_c district_n ward_c ward_n village_n village_c ///
			length area latitude longitude radius dist_road dist_pfm ///
			dist_town dist_road_cent dist_coast vill_dist_pfm vill_dist_road ///
			vill_dist_town villcent_lat villcent_long
	
	rename length shape_leng
	rename area shape_area
	
	gen sample = "as"
	egen village_id = concat(district_c ward_c village_c), punct(-)

/* Export  _____________________________________________________________________*/

	save "${data}/01_raw_data/pfm_as_villagesample.dta", replace



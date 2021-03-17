
/* Background __________________________________________________________________

	Project: Wellspring Tanzania, Natural Experiment
	Purpose: Clean village scoping data
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2021/03/10

*/


/* Introduction ________________________________________________________________*/

clear all
clear matrix
clear mata
set more off
version 15 
set maxvar 30000


/* Load Data ___________________________________________________________________*/

	use "${data}/01_raw_data/pfm_sample_ne.dta", clear

	
/* Clean Variables _____________________________________________________________*/

	rename vtreat_cel v_cellpfm
		lab var v_cellpfm "Village radio access - cell phone"
	
	rename vtreat_rad v_radiopfm
		lab var v_radiopfm "Village radio access"
	
	rename cell v_cell
		lab var v_cell "Village cell phone acess"
		
	rename cell_bar v_cell_bar
		lab var v_cell_bar "Village cell phone access (bars)"
		
	rename traveltime v_timetotown
		lab var v_timetotown "Village travel time to nearest town (min)"
		
	rename electricity v_electricity
		lab var v_electricity "Village has electricity"
		
	rename rel_muslim v_muslim 
		lab var v_muslim "Village is primarily Muslim"
		
	rename rel_mix v_mixed
		lab var v_mixed "Village is mixed Muslim/Christian"
		
	rename rel_noworship v_noworship
		lab var v_noworship "Village no worship"
		
	rename rel_mosques v_mosques
		lab var v_mosques "Village # mosques"
		
	rename rel_churches v_churches
		lab var v_churches "Village # churches"
		
	rename rel_totworship v_totworship
		lab var v_totworship "Village total number of worship centers"
		
	rename villexec v_villexec
		lab var v_villexec "Village available village executive officer"
		
	rename dem_pop v_pop
		lab var v_pop "Village population"
		
	rename dem_subvil_tot v_subvills
		lab var v_subvills "Village # subvillages"
		
	rename poplist v_poplist
		lab var v_poplist "Village available census"
		
	rename poplist_complete v_poplist_final 
		lab var v_poplist_final "Village census complete"
		
	rename subvil_reach v_subvil_reachable
		lab var v_subvil_reachable "Village - reachable subvillage"
		
	rename subvil_cel v_subvil_cell
		lab var v_subvil_cell "Village - subvill has cell phone"
		
	rename svtreat_cel v_subvil_cellpfm
		lab var v_subvil_cellpfm "Village - subvill cell reaches PFM"
		
	rename svtreat_rad v_subvil_radpfm
		lab var v_subvil_radpfm "Village - subvill radio reaches PFM"

		
	recode v_* (-99 = .d)(-999 = .d)(-888 = .r)

/* Save ________________________________________________________________________*/

	save "${data}/02_mid_data/pfm_ne_scoping_clean.dta", replace
											
				
				

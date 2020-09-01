
/* _____________________________________________________________________________

Project: Pangani FM 2
File: Audio Screening Randomization
Date: 8/22/2019
Author: Dylan Groves, dgroves@poverty-action.org
verview: This imports radio distribution randomization file

________________________________________________________________________________*/


/* Notes _______________________________________________________________________*/

* We are randomly selecting one village within each ward


/* Introduction ________________________________________________________________*/

clear all
set more off
set seed 1956


/* Import ______________________________________________________________________*/

	import delimited "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis\2 - Final Data\5_Radio Distribution\panganifm_radio distribution randomization_2018.04.15.csv", clear 

	/* One village has a bunch of NAs, so need to draw correct respids back */
	replace respid = "15395007" if resp_name == "Bihusi Abrahaman Hamza"
	replace respid = "15395065" if resp_name == "Fathila zuberi"
	replace respid = "15395056" if resp_name == "Friday Khaji"
	replace respid = "15395060" if resp_name == "GOODLUCK DICKSON "
	replace respid = "15395063" if resp_name == "HASSAN AMDANI "
	replace respid = "15395032" if resp_name == "Joyce shato"
	replace respid = "15395015" if resp_name == "MARIAMU ATHUMANI"
	replace respid = "15395061" if resp_name == "MUSSA RASHIDI "
	replace respid = "15395059" if resp_name == "Mbaruku  Juma "
	replace respid = "15395026" if resp_name == "Miraji Shabani"
	replace respid = "15395025" if resp_name == "Mwanaidi sebalua"
	replace respid = "15395058" if resp_name == "Mwanakombo mauridi"
	replace respid = "15395012" if resp_name == "Omari Ally "
	replace respid = "15395006" if resp_name == "PENIELI YOHANA"
	replace respid = "15395038" if resp_name == "Petro Hassani Karata "
	replace respid = "15395041" if resp_name == "Raheli Stephano "
	replace respid = "15395004" if resp_name == "THABITINA NURU"
	
	/* Two with a mistake - tracked down correct in id in preceding file */
	replace respid = "14861003" if resp_name == "Amina Ayubu "
	replace respid = "14861001" if resp_name == "Amina Mohamed "
	
	/* ID cleaning */
	tostring id, replace
	replace id  = "6" if  keyx == "uuid:5d6e817c-e87b-4631-9ce9-1a800c95e0ba"
	replace id  = "10" if keyx == "uuid:098bbc57-afc6-4281-9b5f-a2e770e6153f"
	replace id  = "13" if keyx == "uuid:d3147a0d-f40f-47a1-a751-3ede7eae672a"
	replace id  = "22" if keyx == "uuid:429fd374-a0af-4416-8605-cd7106789259"
	replace id  = "38" if keyx == "uuid:13dd632b-7f34-461e-9187-c3a96edf04c0"
	replace id  = "41" if keyx == "uuid:82514855-7e78-423f-a363-52370f3df060"
	replace id  = "44" if keyx == "uuid:7d7e4a59-168a-4c8e-ac2d-858ad1515544"
	replace id  = "51" if keyx == "uuid:1ff2aa64-db3d-4a79-8c4e-24dd4e8bdd70"
	replace id  = "67" if keyx == "uuid:bb327259-8175-4bbb-b783-238e1a18b586"
	replace id  = "71" if keyx == "uuid:14ab5a2a-5868-4f10-b3d8-66470495b251"
	replace id  = "74" if keyx == "uuid:5d902b47-f737-4ddf-b468-bc778746619e"
	replace id  = "76" if keyx == "uuid:d20b7f08-39e6-47e4-8bf9-2bf7583ca92b"
	replace id  = "79" if keyx == "uuid:09699282-bb9a-4f93-90a3-c8ab46874184"
	replace id  = "99" if keyx == "uuid:582e9a89-715b-4c4c-a0df-e6c7240537f4"
	replace id  = "99" if keyx == "uuid:59e46e33-d26b-47f5-85d8-43f3d238c2ac"
	replace id =  "98" if keyx == "uuid:cedf83e9-2107-4365-8159-f2aed9000eea"
	
	rename rdtreat real_treat
	rename survey_villageid village_c
	rename survey_villagename village_n 
	gen object_id = village_c
	sort keyx
	bys village_c : gen uid = _n
	
	/* Generate unique ID */
	egen resp_id = concat(village_c id), punct(_)
	
	keep resp_id respid uid village_c real_treat 
	order village_c uid respid resp_id real_treat
	
	export delimited using "X:\Box Sync\08_PanganiFM\PanganiFM\2 - Data and Analysis\2 - Final Data\5_Radio Distribution\pfm_ri_base.csv", replace
	

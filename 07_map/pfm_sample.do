* villages sample

clear all
import delimited "/Volumes/Secomba/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/genmatch sample_2018.02.17_west.csv", encoding(ISO-8859-1)
keep objectid region_cod region_nam district_c district_n ward_code ward_name vil_mtaa_c vil_mtaa_n shape_leng shape_area vtreat match q1_2_geopointlatitude q1_2_geopointlongitude q1_2_geopointaltitude q1_2_geopointaccuracy q4_0_geopointlatitude q4_0_geopointlongitude q4_0_geopointaltitude q4_0_geopointaccuracy
rename region_cod region_c
rename region_nam region_n
rename ward_code ward_c
rename ward_name ward_n
rename vil_mtaa_c village_c
rename vil_mtaa_n village_n
rename vtreat treat
gen sample = "ne"
rename q1_2_geopointlatitude latitude
rename q1_2_geopointlongitude longitude
save "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/ne_sample_villages.dta", replace

use "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (hiv midline)/01 Data/pfm2_randomized_vills.dta", clear
keep district_c district_n ward_c ward_n village_n village_c radius dist_road dist_pfm dist_town area region_n region_c length latitude longitude dist_road_cent dist_coast vill_dist_pfm vill_dist_road vill_dist_town villcent_lat villcent_long treat 
order region_n region_c district_c district_n ward_c ward_n village_n village_c length area treat  latitude longitude radius dist_road dist_pfm dist_town dist_road_cent dist_coast vill_dist_pfm vill_dist_road vill_dist_town villcent_lat villcent_long
rename length shape_leng
rename area shape_area
gen sample = "as"
save "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/as_sample_villages.dta", replace

append using "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/ne_sample_villages.dta"

sort region_n district_n ward_c 
order region_c region_n district_c district_n ward_c ward_n village_c village_n sample  treat

export excel region_c region_n district_c district_n ward_c ward_n village_c village_n sample  treat latitude longitude using "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/01_sample/villages.xls", firstrow(variables) replace

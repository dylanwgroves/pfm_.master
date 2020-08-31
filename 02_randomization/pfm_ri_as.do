
/* _____________________________________________________________________________

Project: Wellspring Tanzania, Audio Screening  
Purpose: Randomization Inference
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/08/19
________________________________________________________________________________*/


/* Notes _______________________________________________________________________

* We are randomly selecting one village within each ward

________________________________________________________________________________*/



/* Introduction ________________________________________________________________*/

use "${data}\01_raw_data\pfm_as_villagesample.dta", clear

* Stable Sort
sort vill_id

forval num = 1/10000 {

* Set Seed
set seed `num'

* Randomly Select Villages
* We are randomly selecting one village within each ward

* (1) Generate Random Number
gen random_2 = runiform()

* (2) Identify Largest Random Number in Each Ward
bys district_c ward_c: egen r2_median = median(random_2)
gen treat_`num' = 1 if random_2 > r2_median
replace treat_`num' = 0 if random_2 < r2_median

drop random_2 r2_median
}

drop vill_id


/* Save ________________________________________________________________________*/

save "${data}/02_mid_data/pfm_ri_as.dta", replace




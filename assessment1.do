
clear all
set more off

use "C:/Users/Sushant/Desktop/Stanford/natl2012.dta"

append using "C:/Users/Sushant/Desktop/Stanford/natl2013.dta"

append using "C:/Users/Sushant/Desktop/Stanford/natl2014.dta"

keep dob_yy dob_mm dlmp_yy dlmp_mm sex dbwt combgest ab_nicu dplural mager ///
meduc mar mracehisp mbcntry precare wic me_rout mbstate_rec dmar

** Keeping only the variables that are of interest to us

// MBCNTRY: The mother's birth country is not available in the data that we used for 2012 and 2013.  
// Geographic codes are not available in the U.S. file. 

drop if meduc == .
drop if precare == .

** Combining marriage status as a single variable. 
gen mar_total = 0
replace mar_total = 1 if mar == 1
replace mar_total = 1 if dmar == 1
label var mar_total "Creating dummy for marital status by combining dataset from 2012-2014"


generate ldbwt = (dbwt<2500)
label var ldbwt "low birth weight (<2500)"
generate vldbwt = (dbwt<1500)
label var vldbwt "very low birth weight (<2500)"

generate ptb = (combgest <37)
label var ptb "pre-term birth (<37 weeks)"

gen ind_nicu = (ab_nicu == "Y")
label var ind_nicu "Indicator fo child being dmitted to NICU"

gen ind_single = (dplural == 1)
label var ind_single "Indicator for singleton birth"

gen ind_mbstate = (mbstate_rec ==1)
label var ind_mbstate "Indicator for mother born inside 50 state -only 2014 data"

** Dummies for Mother's education for ease of plotting in graph graph
generate dummy_meduc = . 
replace dummy_meduc = 1 if meduc < 3
replace dummy_meduc = 2 if meduc==3
replace dummy_meduc = 3 if meduc == 4 | meduc == 5
replace dummy_meduc = 4 if meduc > 5 & meduc < 9
drop if dummy_meduc == . 

** Create a similar dummy variable as the previous part. Using this for regression in part 4
gen meduc_ss = (meduc <3)
label var meduc_ss "Less than high school"

gen meduc_hs = (meduc == 3)
label var meduc_hs "high school/GED"

gen meduc_scol = (meduc == 4 | meduc == 5 )
label var meduc_scol "Some college"

gen meduc_colx = (meduc > 5 & meduc < 9)
label var meduc_colx "College graduate plus"

gen ind_mar = (mar_total ==1)
label var ind_mar "Mother's marital status"

**Mother's race ethinicity Creating dummies for race
generate dummy_mrac = . 
replace dummy_mrac = 1 if mracehisp == 6
replace dummy_mrac = 2 if mracehisp == 7
replace dummy_mrac = 3 if mracehisp <= 5
replace dummy_mrac = 4 if mracehisp == 8
drop if dummy_mrac == . 

** Creating dummy for race. We use these variables for the regression table
gen mrac_nhw = (mracehisp ==6)
label var mrac_nhw "non hispanic white"

gen mrac_nhb = (mracehisp ==7)
label var mrac_nhb "non hispanic black"

gen mrac_h = (mracehisp <= 5)
label var mrac_h "hispanic"

gen mrac_nho = (mracehisp ==8)
label var mrac_nho "non hispanic other"


*Creating pre-natal care in 1st trimester
gen precare_tri = (precare <=3 & precare > 0)
label var precare_tri "prenatal care"

gen wic_ind = (wic == "Y")
label var wic_ind "indicator for WIC"

gen c_sect = (me_rout == "4")
label var c_sect "Delivery by C-Section"

** Drawing bar graphs with for lbdwt, pbt and wic_ind

graph bar (mean) ldbwt, over(dummy_meduc, relabel(1 "Below HS" 2 "HS" 3 "Clg" 4 "Grad +")) over(ind_mar, relabel(1 "Unmarried" 2 "Married")) ///
		legend( label(1 "Unmarried") label(2 "Married") ) ///
		ytitle("Low Baby Weight") ///
		title("Low Baby Weight by m_educated and marital status") ///
		subtitle("By Marital status and mother's education") ///
		note("Data: Natality Birth Rate")
		graph export 3a.pdf, replace
		
graph bar (mean) ptb, over(dummy_meduc, relabel(1 "Below HS" 2 "HS" 3 "Clg" 4 "Grad +")) over(ind_mar, relabel(1 "Unmarried" 2 "Married")) ///                               
		legend( label(1 "Unmarried") label(2 "Married") ) ///   
		ytitle("Pre-Term Birth") ///
		title("Pre-Term Birth") ///                
		subtitle("By Marital status and mother's education") ///                
		note("Data: Natality Birth Rate")
		graph export 3b.pdf, replace
				
graph bar (mean) wic_ind, over(dummy_meduc, relabel(1 "Below HS" 2 "HS" 3 "Clg" 4 "Grad +")) over(ind_mar, relabel(1 "Unmarried" 2 "Married")) ///
		legend( label(1 "Unmarried") label(2 "Married") ) ///
		ytitle("WIC benefit receipt") ///
		title("WIC benefit receipt") ///
		subtitle("By Marital status and mother's education") ///
		note("Data: Natality Birth Rate")
		graph export 3c.pdf, replace
				
graph bar (mean) c_sect, over(dummy_meduc, relabel(1 "Below HS" 2 "HS" 3 "Clg" 4 "Grad +")) over(ind_mar, relabel(1 "Unmarried" 2 "Married")) ///
		legend( label(1 "Unmarried") label(2 "Married") ) ///                 
		ytitle("C-Section Delivery") ///
		title("C-Section Delivery") ///
		subtitle("By Marital status and mother's education") ///
		note("Data: Natality Birth Rate")
		graph export 3d.pdf, replace
				
*** Question 4***
gen D_mager = (mager > 34)
gen sex_D = (sex == "M")

** To use the fixed effect in the regression, we create month_year variable
gen month_year = ym(dob_yy, dob_mm)
format month_year %tm

xtset month_year

preserve

keep if mager >= 32 & mager <= 37

quietly xtreg ptb D_mager meduc_ss meduc_hs meduc_scol meduc_colx ///
mrac_nhw mrac_nhb mrac_h mrac_nho ind_mar precare_tri sex_D mager, fe robust
outreg2 using "C:/Users/Sushant/Desktop/Stanford/prob4.tex", ctitle("pbt")

quietly xtreg c_sect D_mager meduc_ss meduc_hs meduc_scol meduc_colx ///
mrac_nhw mrac_nhb mrac_h mrac_nho ind_mar precare_tri sex_D mager, fe robust
outreg2 using "C:/Users/Sushant/Desktop/Stanford/prob4.tex", ctitle("wic")

quietly xtreg ind_nicu D_mager meduc_ss meduc_hs meduc_scol meduc_colx ///
mrac_nhw mrac_nhb mrac_h mrac_nho ind_mar precare_tri sex_D mager, fe robust
outreg2 using "C:/Users/Sushant/Desktop/Stanford/prob4.tex", ctitle("c_sect")

restore

save "assessment1.dta", replace


//Heterogeneity Analysis

cd "/Github"

use "Build/Output/Firm_green_harmon_2000-2016", clear

global control Age Asset ROAA Capint Top10 Cash SA Finance

//Different standards
preserve
global y "test quality safety environment compatibility terminology network measurement"
foreach var of global y {
  gen ln_`var' = ln(wh_`var' +1)
  reghdfe greenness_tot ln_`var' $control , ab(year industry fid) cl(fid) 
}
restore


//Sub-sample regression
//Industries with varying levels of carbon emissions
preserve
merge m:1 IndustryCode using "Build/Heterogeneity/Industry total carbon emissions grouping"
drop _merge

forvalues i=1(1)3{
  reghdfe greenness_tot lnwharmon $control if carbon_group==`i', ab(year industry fid) cl(fid)
}
restore


//Equity nature (Ownership)
preserve
merge 1:1 fid year using "Data/Control/Ownership_2003-2016", keepusing(OwnershipType OwnershipCode)
drop if _merge==2
drop _merge

gen soe=1 if OwnershipCode=="1"
replace soe=0 if soe==.

reghdfe greenness_tot lnwharmon $control if soe==1, ab(year industry fid) cl(fid)  

reghdfe greenness_tot lnwharmon $control if soe==0, ab(year industry fid) cl(fid)  
restore


//Business orientation
//Export share, GVC
preserve
merge m:1 fid using "Build/Heterogeneity/Export share & GVC grouping"

reghdfe greenness_tot lnwharmon $control if exr<medianexr, ab(year industry fid) cl(fid)  

reghdfe greenness_tot lnwharmon $control if exr>=medianexr, ab(year industry fid) cl(fid) 

reghdfe greenness_tot lnwharmon $control if GVC<mediangvc, ab(year industry fid) cl(fid) 

reghdfe greenness_tot lnwharmon $control if GVC>=mediangvc, ab(year industry fid) cl(fid) 
restore




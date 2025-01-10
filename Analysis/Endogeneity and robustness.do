
//Robustness

cd "/Github"

use "Build/Output/Firm_green_harmon_2000-2016", clear

global control Age Asset ROAA Capint Top10 Cash SA Finance

//Replace carbon emission measurement
reghdfe greenness_pro lnwharmon $control , ab(year industry fid) cl(fid)


//Retain continuous export sample group
preserve
bys fid : egen a=count(year)
reghdfe greenness_tot lnwharmon $control if a>=5, ab(year industry fid) cl(fid) 
restore


//Control concurrent policies
//FTA
preserve
merge 1:1 fid year using "Build/Output/Robust/Robust_FTA_2000-2016"
drop if _merge==2
drop _merge

reghdfe greenness_tot FTA_lnwh $control , ab(year industry fid) cl(fid) 
restore

//BRI
preserve
merge 1:1 fid year using "Build/Output/Robust/Robust_BRI_2000-2016"
drop if _merge==2
drop _merge

reghdfe greenness_tot BRI_lnwh $control , ab(year industry fid) cl(fid)  
restore

//FTA & BRI
preserve
merge 1:1 fid year using "Build/Output/Robust/Robust_FTA_BRI_2000-2016"
drop if _merge==2
drop _merge

reghdfe greenness_tot FTA_BRI_lnwh $control , ab(year industry fid) cl(fid) 
restore


//Endogeneity
//Steel, non-ferrous metals, coal, electricity, oil and petrochemicals, chemical industry, building materials, textiles, papermaking industry
//Exclude enterprises
preserve
merge m:1 FirmName using "Data/Robust/List of thousand enterprises"
drop if _merge==3
drop _merge

reghdfe greenness_tot lnwharmon $control , ab(year industry fid) cl(fid) 
restore

//Exclude industries
preserve
merge m:1 IndustryCode using "Build/Output/Robust/Matched industries"
drop if _merge==3
drop _merge

reghdfe greenness_tot lnwharmon $control , ab(year industry fid) cl(fid)
restore


//Propensity score matching
use "Build/Output/Robust/Robust_PSM_2000-2016", clear
global control Age Asset ROAA Capint Top10 Cash SA Finance

reghdfe greenness_tot lnwharmon $control if _support == 1 , ab(year industry fid) cl(fid)


//Parallel trends test
use "Build/Output/Firm_green_harmon_2000-2016", clear
global control Age Asset ROAA Capint Top10 Cash SA Finance

bys fid: gen treated=1 if lnwharmon>0
replace treated=0 if treated==.

bys fid: egen birth_year = min(cond(lnwharmon > 0, year, .))
gen event = year - birth_year

tab event

replace event = -4 if event < -4   //Tail trimming treatment
replace event = 4 if event > 4

forvalues i=4(-1)1{
  gen pre`i'=(event==-`i'& treated==1)
}

gen current=(event==0 & treated==1)

forvalues i=1(1)4{
  gen post`i'=(event==`i'& treated==1)
}

replace pre1=0   //Base period

reghdfe greenness_tot pre* current post* $control , ab(year industry fid) cl(fid) 
est store m1

#delimit ;
  coefplot m1, keep(pre* current post*)
  aseq swapnames noeqlabels vertical omitted
  ciopt(recast(rarea) color(gs14))
  msize(*0.5) c(l) color(gs0) 
  xlabel(1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" 9 "4" , labsize(*0.85))
  ylabel(-0.5 "-0.50" -0.25 "-0.25" 0 "0.00" 0.25 "0.25" 0.5 "0.50" , angle(0) format(%4.0f) labsize(*0.85) nogrid)
  xline(4, lp(dash))
  yline(0, lp(dash))
  ytitle("Coefficients")
  xtitle("Years Before or After Policy(=0)")
  legend(off)
  graphregion(fcolor(gs16) lcolor(gs16)) 
  plotregion(lcolor("white") lwidth(*0.9));
#delimit cr

graph save Graph "Analysis/Output/Parallel trends test.gph", replace
graph export "Analysis/Output/Parallel trends test.png", replace



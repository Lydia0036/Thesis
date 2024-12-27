
//Baseline analysis

cd "/Users/lydia/Desktop/申博/Github"

clear all
use "Build/Output/Firm_green_harmon_2000-2016", clear

global control Age Asset ROAA Capint Top10 Cash SA Finance

reghdfe greenness_tot lnwharmon , ab(fid) cl(fid) 
est sto m1

reghdfe greenness_tot lnwharmon $control , ab(fid) cl(fid) 
est sto m2

reghdfe greenness_tot lnwharmon $control , ab(year fid) cl(fid)
est sto m3

reghdfe greenness_tot lnwharmon $control , ab(year industry fid) cl(fid) 
est sto m4

esttab m* using "Analysis/Output/Baseline.rtf",  ///
b(%8.4f) se(%8.4f) ar2(%8.4f) star(* 0.1 ** 0.05 *** 0.01) ///
scalar(N) replace compress nogaps


//Descriptive statistics
sum2docx greenness_tot greenness_pro lnwharmon $control  using "Analysis/Output/Descriptive statistics.docx", ///
replace stats(N mean(%9.4f) sd(%9.4f) min(%9.4f) median(%9.4f) max(%9.4f)) title(Descriptive statistics)

preserve
keep if lnwharmon==0
sum2docx greenness_tot greenness_pro lnwharmon $control  using "Analysis/Output/Control_descriptive statistics.docx", ///
replace stats(N mean(%9.4f) sd(%9.4f) min(%9.4f) median(%9.4f) max(%9.4f)) title(Descriptive statistics for control group)
restore

preserve
keep if lnwharmon!=0
sum2docx greenness_tot greenness_pro lnwharmon $control  using "Analysis/Output/Treated_descriptive statistics.docx", ///
replace stats(N mean(%9.4f) sd(%9.4f) min(%9.4f) median(%9.4f) max(%9.4f)) title(Descriptive statistics for treated group)
restore

preserve
replace lnwharmon=1 if lnwharmon!=0
ttable2 greenness_tot greenness_pro $control , by(lnwharmon)
restore






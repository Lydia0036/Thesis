
//Robustness

cd "/Github"

//Concurrent policy exclusion: free trade agreements/Belt and Road Initiative
use "Build/Output/Product_harmon_2000-2016", clear

//Free trade agreements
drop if c_d=="ISL" |c_d=="CHE" |c_d== "AUS" |c_d== "KOR"
//2013, Iceland and Switzerland; 2015, Australia and South Korea

//Clustered at firm level
bys fid year : egen exp = total(USD)
label var exp "Export total value of products with standard data"
bys fid year : egen FTA_wh=total(harmon * (USD / exp))
sort fid year
duplicates drop fid year, force
gen FTA_lnwh=ln(FTA_wh+1)
keep fid year FTA_wh FTA_lnwh

tab year
save "Build/Output/Robust/Robust_FTA_2000-2016", replace


//Belt and Road Initiative
use "Build/Output/Product_harmon_2000-2016", clear

gen BRI=.
joinby c_d using "Data/Robust/OBOR2016", update unmatched(both)
drop if _merge==2
drop _merge

count if BRI==.    //34071
keep if BRI==.

//Clustered at firm level
bys fid year : egen exp = total(USD)
label var exp "Export total value of products with standard data"
bys fid year : egen BRI_wh=total(harmon * (USD / exp))
sort fid year
duplicates drop fid year, force
gen BRI_lnwh=ln(BRI_wh+1)
keep fid year BRI_wh BRI_lnwh

tab year
save "Build/Output/Robust/Robust_BRI_2000-2016", replace


//FTA & BRI
use "Build/Output/Product_harmon_2000-2016", clear

gen BRI=.
joinby c_d using "Data/Robust/OBOR2016", update unmatched(both)
drop if _merge==2
drop _merge
keep if OBOR==. 
drop if c_d=="ISL" |c_d=="CHE" |c_d== "AUS" |c_d== "KOR"

//Clustered at firm level
bys fid year : egen exp = total(USD)
label var exp "Export total value of products with standard data"
bys fid year : egen FTA_BRI_wh=total(harmon * (USD / exp))
sort fid year
duplicates drop fid year, force
gen FTA_BRI_lnwh=ln(FTA_BRI_wh+1)
keep fid year FTA_BRI_wh FTA_BRI_lnwh

tab year
save "Build/Output/Robust/Robust_FTA_BRI_2000-2016", replace



//Endogeneity
use "Build/Output/Firm_green_harmon_2000-2016", clear

merge m:1 FirmName using "Data/Robust/List of thousand enterprises"
keep if _merge==3
keep fid FirmName ShortName IndustryName IndustryCode LegalRepresentative PROVINCE industry ind
duplicates drop IndustryCode, force
sort IndustryCode
keep IndustryName IndustryCode industry ind
save "Build/Output/Robust/Matched industries", replace



//PSM
use "Build/Output/Firm_green_harmon_2000-2016", clear

bys fid: gen treated=1 if lnwharmon>0
replace treated=0 if treated==.

set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1

global control Age Asset ROAA Capint Top10 Cash SA Finance

psmatch2 treated $control , outcome(greenness_tot) radius caliper(0.005) ate ties logit common    //radius matching					  				  
pstest, both graph saving(balancing_assumption, replace)  //balance test

save "Build/Output/Robust/Robust_PSM_2000-2016", replace





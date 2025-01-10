
//Merge harmonization and greenness data
//Add control variables

cd "/Github"

//
use "Build/Output/FirmGreenness_2000-2016", clear
merge 1:1 fid year using "Build/Output/Firm_harmon_2000-2016"
keep if _merge==3
drop _merge

xtset fid year
encode Industry, gen(industry)
label var industry "2-digit segmented industry"
encode PROVINCE, gen(prov)
encode CITY, gen(cty)


//Add control variables
//Financial indicators, ROA
merge 1:1 fid year using "Data/Control/Profitability_2000-2016", keepusing(ROAA-ROATTM)
drop if _merge==2
drop _merge

//Shareholders
//the proportion of shares held by the largest shareholder
//the shareholding ratio of the top 10 shareholders
merge 1:1 fid year using "Data/Control/Shareholding concentration_2003-2016", keepusing(Largest Top10)
drop if _merge==2
drop _merge

//Financing Constraints
merge 1:1 fid year using "Data/Control/Financing Constraints_FC_2000-2016", keepusing(FC)
drop if _merge==2
drop _merge
merge 1:1 fid year using "Data/Control/Financing Constraints_KZ_2000-2016", keepusing(KZ)
drop if _merge==2
drop _merge
merge 1:1 fid year using "Data/Control/Financing Constraints_SA_2000-2016", keepusing(SA)
drop if _merge==2  
drop _merge
merge 1:1 fid year using "Data/Control/Financing Constraints_WW_2000-2016", keepusing(WW)
drop if _merge==2  
drop _merge

save "Build/Output/Firm_green_harmon_2000-2016", replace



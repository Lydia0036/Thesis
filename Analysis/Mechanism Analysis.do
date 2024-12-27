
//Mechanism Analysis

cd "/Users/lydia/Desktop/申博/Github"

use "Build/Output/Firm_green_harmon_2000-2016", clear

global control Age Asset ROAA Capint Top10 Cash SA Finance


*** Comprehensive effect ***
//Total carbon emissions
reghdfe carbon_exp_tot lnwharmon $control , ab(year industry fid) cl(fid) 

reghdfe carbon_exp_pro lnwharmon $control , ab(year industry fid) cl(fid) 

//Total export value
replace X=X/1000     //million USD
reghdfe X lnwharmon $control , ab(year industry fid) cl(fid) 

//DVA
replace DVA=DVA/1000     //million USD
reghdfe DVA lnwharmon $control , ab(year industry fid) cl(fid) 

//Export share
replace exr=exr*100
reghdfe exr lnwharmon $control if year<2016, ab(year industry fid) cl(fid)



*** Demand effect ***
//Export price and quality
preserve
sort fid year
merge 1:1 fid year using "Build/Mechanism/Demand effect/Export price and quantity/Firm_export price_2000-2015", keepusing(wprice_m wprice_w)
drop if _merge==2
drop _merge
merge 1:1 fid year using "Build/Mechanism/Demand effect/Export quality/Firm_quality_2_2000-2015", keepusing(quality_m quality_w)
drop if _merge==2
drop _merge 
sum wprice_m-quality_w

foreach i in wprice_m wprice_w quality_m quality_w {
 gen ln`i'=ln(`i'+1)
 reghdfe ln`i' lnwharmon $control , ab(year industry fid) cl(fid)
}
restore


//Product differentiation
preserve
sort fid year
merge 1:1 fid year using "Build/Mechanism/Demand effect/Product differentiation/Firm_product differentiation_2000-2016", keepusing(wrauch_n)
drop if _merge==2
drop _merge

reghdfe wrauch_n lnwharmon $control , ab(year industry fid) cl(fid) 
restore


//Quantity, product level
use "Build/Output/ProductGreenness_2000-2016", clear
merge 1:1 fid year HS countrycode using "Build/Mechanism/Demand effect/Export price and quantity/Export_price & quantity_2000-2015", keepusing(Quantity)
drop if _merge==2
drop _merge

tab year if Quantity!=.
replace Quantity=. if Quantity==0
gen quantity=ln(Quantity+1)
label var quantity "ln(Quantity)"

destring hs92, gen(hs)
encode c_d, gen(cty)
egen id = group(fid hs cty)
xtset id year
sort fid year hs cty
encode field, gen(fld)
egen hscty = group(hs cty)

//Add control
merge m:1 fid year using "Data/Control/Profitability_2000-2016", keepusing(ROAA)
drop if _merge==2
drop _merge
merge m:1 fid year using "Data/Control/Shareholding concentration_2003-2016", keepusing(Top10)
drop if _merge==2
drop _merge
merge m:1 fid year using "Data/Control/Financing Constraints_SA_2000-2016", keepusing(SA)
drop if _merge==2  
drop _merge

global control Age Asset ROAA Capint Top10 Cash SA Finance
reghdfe quantity lnharmon $control , ab(hs year fld cty) cl(hscty)



*** Cost complementarity effect ***
//Full sample
use "Build/Output/Firm_green_harmon_2000-2016", clear
merge 1:1 year fid using "Data/Control/Fundamental analysis-Financial indicators_2000-2020", keepusing(salecost)
drop if _merge==2
drop _merge

gen lnscost=ln(salecost/1000 +1)

bys fid (year) : gen num=_n
gen a = salecost if num==1
bys fid : egen b = total(a)
gen basc = salecost/b
label var basc "sale cost_ratio to baseline"
drop a b
gen lnbasc=ln(basc +1)

reghdfe lnscost lnwharmon $control , ab(year industry fid) cl(fid) 

reghdfe lnbasc lnwharmon $control , ab(year industry fid) cl(fid)  


//Sub-sample
merge m:1 fid using "Build/Mechanism/Cost complementarity effect/Product varieties grouping", keepusing(group_varieties)
drop if _merge==2
drop _merge

merge m:1 fid using "Build/Mechanism/Cost complementarity effect/Export share grouping", keepusing(group_expshare)
drop if _merge==2
drop _merge

foreach i in group_varieties group_expshare {
  forvalues k=1(1)3 {
    reghdfe lnbasc lnwharmon $control if `i'==`k', ab(year industry fid) cl(fid)
  }
}



*** Technological effect ***
//Green patent, green innovation efficiency
use "Build/Output/Firm_green_harmon_2000-2016", clear
merge 1:1 fid year using "Build/Mechanism/Technological effect/Green innovation efficiency_2007-2021", keepusing(green_efficiency)
drop if _merge==2
drop _merge

merge 1:1 fid year using "Build/Mechanism/Technological effect/Green patent applications_2000-2019", keepusing(invention-total)
drop if _merge==2
drop _merge

sum green_efficiency-total
gen green_in=ln(invention+1)
gen green_us=ln(utility+1)
gen green_t=ln(total+1)
replace green_efficiency=green_efficiency*100

foreach i in in us t efficiency {
  reghdfe green_`i' lnwharmon $control , ab(year industry fid) cl(fid) 
}


//Overall innovation performance and efficiency
merge 1:1 fid year using "Build/Mechanism/Technological effect/Overall patent applications_2006-2021", keepusing(Patent1 Patent2 InnoEff2)
drop if _merge==2
drop _merge

merge 1:1 fid year using "Build/Mechanism/Technological effect/Overall innovation_2011-2021", keepusing(Patent)
drop if _merge==2
drop _merge

replace Patent=ln(Patent+1)
replace InnoEff2=InnoEff2*100

foreach i in Patent Patent1 Patent2 InnoEff2 {
  reghdfe `i' lnwharmon $control , ab(year industry fid) cl(fid) 
}




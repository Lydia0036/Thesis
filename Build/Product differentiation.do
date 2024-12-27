
//Product differentiation

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Product differentiation"

//HS-4-digit
use "ladder_hs6", clear
sum
gen hs92= substr(hs6,1,4)
bys hs92 : egen ladder_t = mean(t_ladder)
bys hs92 : egen ladder_m = mean(m_ladder)
duplicates drop hs92, force
keep hs92 ladder_t ladder_m
save "ladder_hs4", replace


//Cluster at firm level
use "/Users/lydia/Desktop/申博/Github/Build/Output/Product_harmon_2000-2016", clear
merge m:1 hs92 using "ladder_hs4"
drop if _merge==2   //master not matched 784
drop _merge
merge m:1 hs92 using "Rauch"
drop if _merge==2   //master all matched
drop _merge

bys fid year : egen exp = total(USD)
label var exp "total export"

foreach i in ladder_t ladder_m rauch_h rauch_n {
  bys fid year : egen w`i' = total(`i' * (USD / exp) )
}

duplicates drop fid year, force
keep fid year exp wladder_t-wrauch_n

save "Firm_product differentiation_2000-2016", replace

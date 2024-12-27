
//Firm level, export price

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect"

//Firm levle, export price
use "Export price and quantity/Export_price & quantity_2000-2015", clear
tab year
bys fid year : egen exp = total(USD)
label var exp "total export"

foreach i in m w {
bys fid year : egen wprice_`i'= total(Price_`i' * (USD / exp))
label var wprice_`i' "Firm_weighted price_`i'"
}

duplicates drop fid year, force
keep fid year exp wprice_m wprice_w

save "Export price and quantity/Firm_export price_2000-2015", replace


//Firm levle, export quality
use "Export quality/Quality_2_2000-2015", clear
tab year
duplicates drop fid year, force

keep fid year expquaf_m expquaf_w
ren expquaf_m quality_m
ren expquaf_w quality_w

save "Export quality/Firm_quality_2_2000-2015", replace

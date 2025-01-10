
//Number of export destination countries and product varieties

cd "/Github"

//Number of export destination countries
use "Build/Output/Product_harmon_2000-2016", clear
sort fid c_d hs year
keep fid-HS hs92-field
duplicates drop fid year c_d, force
bys fid year : egen countries = count(c_d)
label var countries "Number of export destination countries"
duplicates drop fid year, force

save "Build/Mechanism/Cost complementarity effect/Export destinations and varieties/Firm_export destinations_2000-2016.dta", replace


//Number of export product varieties
use "Build/Output/Product_harmon_2000-2016", clear
sort fid year hs
keep fid-HS hs92-field
duplicates drop fid year hs, force
bys fid year : egen products = count(hs)
label var products "Number of export product varieties"
duplicates drop fid year, force

save "Build/Mechanism/Cost complementarity effect/Export destinations and varieties/Firm_export varieties_2000-2016", replace



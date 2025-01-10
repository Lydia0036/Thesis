
//Standard harmonization events
//The original harmonization data is at product-original country-destination country level
//As we use Chinese customs data, the harmonization data would be at firm-product-export destination level
//All HS codes are converted to the HS 1992 version, 4-digit conversion

//fid=firm' ID; trade_code=import/export type code; HScode=HS-8 digit code; USD=product value;
//countrycode=destination code; countryname=destination name

//
cd "/Github/Data"

//2000-2001, convert HS1996
forvalues k=0(1)1{
  use firm_customs/200`k', clear
  keep if trade_code=="0"    //keep export
  keep fid year HScode USD countrycode countryname
  gen hs1996 = substr(HScode,1,4)     //extract 4-digit HS code
  label var hs1996 "HS1996-4-digit"   //sum the export value at 4-digit product level
  bys fid hs1996 countrycode : egen USD_hs=sum(USD)
  duplicates drop fid hs1996 countrycode, force
  drop USD
  ren USD_hs USD
  drop HScode      //drop 8-digit HS code
  merge m:1 hs1996 using "HS_conversion/hs1996-1992", keepusing(hs1992)     //merge 1992 HS code
  keep if _merge==3     //keep matched
  drop _merge
  ren hs1996 HS      //retain original HS code, 4-digit
  ren hs1992 hs92
  destring countrycode, replace
  merge m:1 countrycode using "customs-csmar-ISO", keepusing(iso2 iso3 country)   //merge ISO country code and name
  keep if _merge==3
  drop _merge
  ren iso3 c_d    //prepare for next merge, 2-digit country code
  destring year, replace
  joinby year c_d hs92 using "Standard/Standards_HS_2000-2016", unmatched(both)    //use destination country, product HS 4-digit code, and year merge standard data
  keep if _merge==3
  drop _merge

  ren harmon harmon_o    //aggregate standard quantity  
  global y "o EN test quality safety environment compatibility terminology network components measurement"
  foreach var of global y {
    bys fid c_d hs92 : egen h_`var' = total(harmon_`var')
	drop harmon_`var'
	ren h_`var' harmon_`var'
  }
  
  duplicates drop fid year c_d hs92, force
  ren harmon_o harmon
  sort fid
  duplicates list fid year c_d hs92
  save /Github/Build/Harmon/exportharmon_200`k' , replace
}

//2002-2006, convert HS2002
forvalues k=2(1)6{
  use firm_customs/200`k', clear
  keep if trade_code=="0"    //keep export
  keep fid year HScode USD countrycode countryname
  gen hs2002 = substr(HScode,1,4)
  label var hs2002 "HS2002-4-digit"
  bys fid hs2002 countrycode : egen USD_hs=sum(USD)
  duplicates drop fid hs2002 countrycode, force
  drop USD
  ren USD_hs USD
  drop HScode
  merge m:1 hs2002 using "HS_conversion/hs2002-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2002 HS
  ren hs1992 hs92
  destring countrycode, replace
  merge m:1 countrycode using "customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  destring year, replace
  joinby year c_d hs92 using "Standard/Standards_HS_2000-2016", unmatched(both)
  keep if _merge==3
  drop _merge

  ren harmon harmon_o
  foreach var of global y {
    bys fid c_d hs92 : egen h_`var' = total(harmon_`var')
	drop harmon_`var'
	ren h_`var' harmon_`var'
  }
  
  duplicates drop fid year c_d hs92, force 
  ren harmon_o harmon
  sort fid
  duplicates list fid year c_d hs92
  save /Github/Build/Harmon/exportharmon_200`k' , replace
}

//2007-2011, convert HS2007
global q "07 08 09 10 11"
foreach name of global q {
  use firm_customs/20`name', clear
  keep if trade_code=="0"    //keep export
  keep fid year HScode USD countrycode countryname
  gen hs2007 = substr(HScode,1,4)
  label variable hs2007 "HS2007-4-digit"
  bys fid hs2007 countrycode : egen USD_hs=sum(USD)
  duplicates drop fid hs2007 countrycode, force
  drop USD
  ren USD_hs USD
  drop HScode
  merge m:1 hs2007 using "HS_conversion/hs2007-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2007 HS
  ren hs1992 hs92
  destring countrycode, replace
  merge m:1 countrycode using "customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  destring year, replace
  joinby year c_d hs92 using "Standard/Standards_HS_2000-2016", unmatched(both)
  keep if _merge==3
  drop _merge

  ren harmon harmon_o
  foreach var of global y {
    bys fid c_d hs92 : egen h_`var' = total(harmon_`var')
	drop harmon_`var'
	ren h_`var' harmon_`var'
  }
  
  duplicates drop fid year c_d hs92, force  
  ren harmon_o harmon
  sort fid
  duplicates list fid year c_d hs92
  save /Github/Build/Harmon/exportharmon_20`name' , replace
}

//2012-2016, convert HS2012
forvalues k=12(1)16{
  use firm_customs/20`k', clear
  keep if trade_code=="0"    //keep export
  keep fid year HScode USD countrycode countryname
  gen hs2012 = substr(HScode,1,4)
  label variable hs2012 "HS2012-4-digit"
  bys fid hs2012 countrycode : egen USD_hs=sum(USD)
  duplicates drop fid hs2012 countrycode, force
  drop USD
  ren USD_hs USD
  drop HScode
  merge m:1 hs2012 using "HS_conversion/hs2012-1992", keepusing(hs1992)
  keep if _merge==3     //keep matched
  drop _merge
  ren hs2012 HS
  ren hs1992 hs92
  destring countrycode, replace
  merge m:1 countrycode using "customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  destring year, replace
  joinby year c_d hs92 using "Standard/Standards_HS_2000-2016", unmatched(both)
  keep if _merge==3
  drop _merge

  ren harmon harmon_o
  foreach var of global y {
    bys fid c_d hs92 : egen h_`var' = total(harmon_`var')
	drop harmon_`var'
	ren h_`var' harmon_`var'
  }
  
  duplicates drop fid year c_d hs92, force
  ren harmon_o harmon
  sort fid
  duplicates list fid year c_d hs92
  save /Github/Build/Harmon/exportharmon_20`k' , replace
}


//Merge all dataset
clear
cd "/Github/Build/Harmon"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'
sort fid year c_d hs92
tab year
sum
gen lnharmon=ln(harmon+1)
sum lnharmon
destring fid, replace
save "/Github/Build/Output/Product_harmon_2000-2016", replace



//Calculate standard quantity at firm level, weighted average

cd "/Github/Build/Output"

use "Product_harmon_2000-2016", clear
sort fid year 
bys fid year : egen export=total(USD)
label var export "total export_USD"
gen weight=USD/export

ren harmon harmon_o
global y "o EN test quality safety environment compatibility terminology network components measurement"
foreach var of global y {
  bys fid year : egen wh_`var'=total(harmon_`var' * weight)
  drop harmon_`var'
}

ren wh_o wharmon
label var wharmon "weighted harmonization events"
duplicates drop fid year, force
keep fid year wharmon-wh_measurement
gen lnwharmon=ln(wharmon+1)
label var lnwharmon "ln(wharmon+1)"
sum

save "Firm_harmon_2000-2016", replace




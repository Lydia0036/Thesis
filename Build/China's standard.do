
//Standard data, exports from China
cd "/Github/Data/Standard"

use "Standards_dataset", clear
keep if c_o=="CHN"     //export = China
tab year
keep if year>1999 & year<2017
tab year
sort year
sum
sum harmon, detail
save "Standards_CHN_2000-2016",replace


//China's standard data, convert HS first
use "Standards_CHN_2000-2016", clear
joinby field_group using "HS-ICS conversion/ICS-HS", unmatched(both)
keep if _merge==3
gen len=length(hs4)
gen hs92=hs4 if len==4   //7,594
drop if hs92==""
drop len hs4
drop _merge
duplicates list hs92 c_d field_group year
save "Standards_HS_2000-2016",replace

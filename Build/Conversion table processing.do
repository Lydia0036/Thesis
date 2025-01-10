
//HS codes are uniformly converted to the HS 1992 version because the ICS and HS conversion tables provided by the WTO are based on the HS 1992 version
//HS use 4-digit code conversion

//conversion table processing
cd "/Github/Data/HS_conversion"

//HS 1996-1992
import excel "origin/HS 1996 to HS 1992 Correlation and conversion tables.xls", sheet("Conversion Table") firstrow clear
replace From = "HS1996" in 1
replace To = "HS1992" in 1
nrow
label var HS1996 "HS1996-6-digit"
label var HS1992 "HS1992-6-digit"
gen hs1996 = substr(HS1996,1,4)
gen hs1992 = substr(HS1992,1,4)
label var hs1996 "HS1996-4-digit"
label var hs1992 "HS1992-4-digit"
duplicates drop hs1996 hs1992, force
keep hs1996 hs1992
duplicates drop hs1996, force
save "hs1996-1992",replace

//HS 2002-1992
import excel "origin/HS 2002 to HS 1992 Correlation and conversion tables.xls", sheet("Conversion Table") firstrow clear
replace From = "HS2002" in 1
replace To = "HS1992" in 1
nrow
label var HS2002 "HS2002-6-digit"
label var HS1992 "HS1992-6-digit"
gen hs2002 = substr(HS2002,1,4)
gen hs1992 = substr(HS1992,1,4)
label var hs2002 "HS2002-4-digit"
label var hs1992 "HS1992-4-digit"
duplicates drop hs2002 hs1992, force
keep hs2002 hs1992
duplicates drop hs2002, force
save "hs2002-1992",replace

//HS 2007-1992
import excel "origin/HS 2007 to HS 1992 Correlation and conversion tables.xls", sheet("Conversion Tables") firstrow clear
replace From = "HS2007" in 1
replace To = "HS1992" in 1
nrow
label var HS2007 "HS2007-6-digit"
label var HS1992 "HS1992-6-digit"
gen hs2007 = substr(HS2007,1,4)
gen hs1992 = substr(HS1992,1,4)
label var hs2007 "HS2007-4-digit"
label var hs1992 "HS1992-4-digit"
duplicates drop hs2007 hs1992, force
keep hs2007 hs1992
duplicates drop hs2007, force
save "hs2007-1992",replace

//HS 2012-1992
import excel "origin/HS 2012 to HS 1992 Correlation and conversion tables.xls", sheet("Conversion HS 2012-HS 1992") firstrow clear
keep C D
drop in 1/5
replace C = "HS2012" in 1
replace D = "HS1992" in 1
nrow
label var HS2012 "HS2012-6-digit"
label var HS1992 "HS1992-6-digit"
gen hs2012 = substr(HS2012,1,4)
gen hs1992 = substr(HS1992,1,4)
label var hs2012 "HS2012-4-digit"
label var hs1992 "HS1992-4-digit"
duplicates drop hs2012 hs1992, force
keep hs2012 hs1992
duplicates drop hs2012, force
save "hs2012-1992",replace


//HS-ICS conversion
cd "/Github/Data/HS-ICS conversion"

import excel "IcsClassification.xlsx", sheet("CorrIcsHsV6") firstrow clear
ren Ics field_group
label var field_group "ICS-5-digit"
ren Hs hs4
label var hs4 "HS1992-4-digit"
save "ICS-HS",replace



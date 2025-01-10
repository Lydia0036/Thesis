
//Stylized facts

//Schimdt data, harmonization events changes with year
cd "/Github"

//Total harmonization events
use "Data/Standard/Standards_CHN_2000-2016", clear
bys year : egen total_year=total(harmon)

global y "EN test quality safety environment compatibility terminology network components measurement"
 foreach var of global y {
 bys year : egen h_`var' = total(harmon_`var')
}

duplicates drop year, force
keep year total_year-h_measurement

//The total harmons in 2015 were very few, the least among all the years, with just 900+; 2016 had the highest.
save "Build/Stylized facts/Annual harmonization events_2000-2016", replace


#delimit
graph twoway 
  (bar total_year year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit total_year year), 
  ytitle("Number of harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(1000)3000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  title("Voluntary standard harmonization events");
#delimit cr

graph export "Build/Stylized facts/Annual harmonization events_2000-2016.png", replace

//Keyword, total harmonization events
use "Build/Stylized facts/Keyword_total harmonization events", clear
drop if key_tot=="EN"
gen a=_n

#delimit
graph twoway 
  (bar num a, barwidth(.9) fintensity(inten0) color(white) lcolor(black)), 
  ytitle("Number of harmonized standards", axis(1)) 
  xtitle("Categories") 
  xlabel(1 "Test" 2 "Quality" 3 "Safety" 4 "Environment" 5 "Compatibility" 6 "Terminology" 7 "Network" 8 "Components" 9 "Measurement", labsize(*0.75))       
  ylabel(0 "0" 5000 "5" 10000 "10" 15000 "15" 20000 "20", axis(1) nogrid)
  legend(off) 
  graphregion(color(white))
  title("Keywords from standard");
#delimit cr

graph export "Build/Stylized facts/Keyword_total harmonization events.png", replace


//Keyword, harmonization events, by year
clear all
use "Build/Stylized facts/Annual harmonization events_2000-2016", clear

#delimit
graph twoway 
  (bar h_test year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_test year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(1000)3000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("test")
  title("Test");
#delimit cr

#delimit
graph twoway 
  (bar h_quality year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_quality year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(500)1000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("quality")
  title("Quality");
#delimit cr

#delimit
graph twoway 
  (bar h_safety year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_safety year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(1000)2000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("safety")
  title("Safety");
#delimit cr

#delimit
graph twoway 
  (bar h_environment year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_environment year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(500)1000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("environment")
  title("Environment");
#delimit cr

#delimit
graph twoway 
  (bar h_compatibility year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_compatibility year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(250)500, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("compatibility")
  title("Compatibility");
#delimit cr

#delimit
graph twoway 
  (bar h_terminology year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_terminology year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(1000)3000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("terminology")
  title("Terminology");
#delimit cr

#delimit
graph twoway 
  (bar h_network year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_network year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(250)500, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("network")
  title("Network");
#delimit cr

#delimit
graph twoway 
  (bar h_components year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_components year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(500)1500, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("components")
  title("Components");
#delimit cr

#delimit
graph twoway 
  (bar h_measurement year, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit h_measurement year), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(1000)2500, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("measurement")
  title("Measurement");
#delimit cr

graph combine test quality safety environment compatibility terminology network components measurement, ///需组合的图片名
              graphregion(color(white)) plotregion(color(white))

graph export "Build/Stylized facts/Keyword_annual harmon_2000-2016.png", replace



//harmonization events by industry, by year
clear all
use "Data/Standard/Standards_CHN_2000-2016", clear
destring field, replace
bys year field : egen tot_harmon=total(harmon)
duplicates drop year field, force
gen fd=1 if field>=65 & field<=67
replace fd=2 if field>=91 & field<=93
replace fd=3 if field>=31 & field<=37
replace fd=4 if field>=17 & field<=29
replace fd=4 if field==39
replace fd=5 if field>=1 & field<=7
replace fd=6 if field>=11 & field<=13
replace fd=7 if field>=59 & field<=61
replace fd=7 if field>=71 & field<=87
replace fd=8 if field>=95 & field<=97
replace fd=9 if field>=43 & field<=55
bys year fd : egen tot_fd_har=total(tot_harmon)
duplicates drop year fd, force
keep year fd tot_fd_har
sort fd year

gen str var = "Agriculture" if fd==1
replace var = "Construction" if fd==2
replace var = "Electronics" if fd==3
replace var = "Engineering" if fd==4
replace var = "Generalities" if fd==5
replace var = "Health" if fd==6
replace var = "Materials" if fd==7
replace var = "Special" if fd==8
replace var = "Transport" if fd==9

* Create individual graphs
* ------------------------
#delimit
graph twoway 
  (bar tot_fd_har year if fd==1, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==1), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(50)100, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Agriculture")
  title("Agriculture and food technologies");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==2, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==2), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(50)100, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Construction")
  title("Construction");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==3, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==3), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(500)1000, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Electronics")
  title("Electronics, information technology and telecommunications");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==4, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==4), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(800)1800, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Engineering")
  title("Engineering technologies");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==5, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==5), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(100)200, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Generalities")
  title("Generalities, infrastructures and sciences");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==6, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==6), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(200)400, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Health")
  title("Health, safety and environment");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==7, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==7), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(200)400, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Materials")
  title("Materials technologies");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==8, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==8), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(100)200, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Special")
  title("Special technologies");
#delimit cr

#delimit
graph twoway 
  (bar tot_fd_har year if fd==9, barwidth(.9) fintensity(inten0) color(white) lcolor(black))
  (lfit tot_fd_har year if fd==9), 
  ytitle("Harmonized standards", axis(1)) 
  xtitle("Year") 
  ylabel(0(100)200, axis(1) labsize(*0.75) format(%9.0f) nogrid) 
  xlabel(2000(5)2015, labsize(*0.75)) 
  legend(off) 
  graphregion(color(white))
  name("Transport")
  title("Transport and distribution of goods");
#delimit cr

* Combine graphs into one
* -----------------------
graph combine Agriculture Construction Electronics Engineering Generalities Health Materials Special Transport, ///需组合的图片名
              graphregion(color(white)) plotregion(color(white))

graph save Graph "Build/Stylized facts/ICS category_harmon_2000-2016.gph", replace
graph export "Build/Stylized facts/ICS category_harmon_2000-2016.png", replace

save "Build/Stylized facts/ICS category_harmon_2000-2016", replace



//Firm level, greening and standard harmonization
//Year-standards and Enterprise GVC Greening
use "Build/Output/Firm_green_harmon_2000-2016", clear
sort fid year
gen green=ln(gvc_green_tot+1)

#delimit
binscatter green lnwharmon, n(10)  // Set the number of bins
  ytitle("Firm-level carbon intensity") 
  xtitle("Harmonized standards")
  ylabel( , nogrid);
#delimit cr

graph export "Build/Stylized facts/Firm level_carbon intensity and harmonization.png", replace



//Country-level export and standard harmonization
use "Build/Stylized facts/Country2000-2016", clear
merge 1:1 countrycode using "Build/Stylized facts/Export", keepusing(totexp meanexp)
keep if _merge==3
drop _merge
replace totexp=totexp/1000000
label var totexp "Million USD"
rename sum1 standard
drop if iso3=="USA"
drop if iso3=="NOR"
drop if iso3=="FIN"

#delimit
twoway qfitci totexp standard || scatter totexp standard,  mlabel(iso3)
  scheme(white_tableau)
  ytitle("Total exports")
  xtitle("Harmonized standards")
  msymbol(oh)
  mcolor("33 70 199")
  msize(medium)
  ylabel( , nogrid);
#delimit cr

graph save Graph "Build/Stylized facts/Country-level export and harmonization.gph", replace
graph export "Build/Stylized facts/Country-level export and harmonization.png", replace



//Harmonization and GVC Greening of Exporting Countries, total firm
use "Build/Output/ProductGreenness_2000-2016", clear
keep fid c_d country hs92 year
sort fid year c_d

merge m:1 fid year using "Build/Output/FirmGreenness_2000-2016", keepusing(gvc_green_tot)
keep if _merge==3
drop _merge

duplicates drop fid c_d year, force
gen green=ln(gvc_green_tot+1)
bys c_d year : egen mgreen=mean(green)
duplicates drop c_d year, force
bys c_d : egen tgreen=total(mgreen)
duplicates drop c_d, force

ren c_d iso3
merge 1:1 iso3 using "Build/Stylized facts/Country2000-2016", keepusing(sum1)
drop _merge
ren sum1 tharmon

keep country iso3 tgreen tharmon
drop if iso3=="NOR"       //24 countries
drop if iso3=="FIN"       //abnormal value

#delimit
twoway qfitci tgreen tharmon || scatter tgreen tharmon,  mlabel(iso3)
  scheme(white_tableau)
  ytitle("Total carbon intensity")
  xtitle("Harmonized standards")
  msymbol(oh)
  mcolor("33 70 199")
  msize(medium)
  ylabel( , nogrid);
#delimit cr

graph save Graph "Build/Stylized facts/Country level carbon intensity and harmonization.gph", replace
graph export "Build/Stylized facts/Country level carbon intensity and harmonization.png", replace





// Calculate the domestic value added of exports by subtracting the foreign value added from the total export value
// Use the previously adjusted listed company GVC data (Adjustment: Domestic sales revenue D = operating income - total exports)
// X=total export value, XP=processing export, XO=general export
// M=total import value, MP=processing import, MO=general import

//
cd "/Github"

use "Data/GVC participation_adjust 2000-2016", clear
gen DVA= X - ( MP + MO * (XO / (XO + D) ) )
label var DVA "export domestic value added_thousand USD"
sort fid year
sum DVA, detail
replace DVA=0 if DVA<0  //888
drop if DVA==.          //2
count if DVA==0         //2242
count if GVC==0         //2486


//Calculate the export share, total export value / total output value
gen exr= X / revenue
label var exr "export to total output value ratio"


//Construct greenness indicator
merge 1:1 fid year using "Data/Listed carbon emission_1992-2022"
keep if _merge==3  //10,306
drop _merge

replace TCE=. if TCE==0    //22
replace Production=. if Production==0    //22
replace exr=. if exr==0     //1,290

gen carbon_exp_tot= TCE * exr
label var carbon_exp_tot "total export carbon emissions"
gen carbon_exp_pro= Production * exr
label var carbon_exp_pro "carbon emissions from production process of exports"

gen gvc_green_tot= carbon_exp_tot / DVA
label var gvc_green_tot "export: total carbon emissions/domestic value added"
gen gvc_green_pro= carbon_exp_pro / DVA
label var gvc_green_pro "export: production process carbon emissions/domestic value added"

gen dvar=DVA/X
sum dvar, detail
label var dvar "export domestic value added rate"

gen carexp_tot_r= carbon_exp_tot / revenue
label var carexp_tot_r "carbon emissions per unit of output_total"
gen carexp_pro_r= carbon_exp_pro / revenue
label var carexp_pro_r "carbon emissions per unit of output_production"
sum carbon_exp_tot-carexp_pro_r

//Corporate global value chain greenness proxy indicator
gen ind = substr(IndustryCode, 1, 1)
label var ind "industry major category"
keep if ind=="C"
drop if gvc_green_tot==.      //1473
drop if gvc_green_tot==0      //0
gen greenness_tot = -ln(gvc_green_tot*100+1)     //main proxy indicator
gen greenness_pro = -ln(gvc_green_pro*100+1)
sum

save "Build/Output/FirmGreenness_2000-2016", replace



//Product level greenness indicator
//Firm level greenness * product's share of total export value

use "Build/Output/Product_harmon_2000-2016", clear

bys fid year : egen export= total(USD)
label var export "export total value"
gen product_share= USD/export
label var product_share "Product's share of total export value"

merge m:1 fid year using "Build/Output/FirmGreenness_2000-2016"
keep if _merge==3  //40,077
drop _merge

gen pgvc_green_tot= gvc_green_tot * product_share
label var pgvc_green_tot "product level: carbon intensity_total"
gen pgvc_green_pro= gvc_green_pro * product_share
label var pgvc_green_pro "product level: carbon intensity_production process"

//Product level greenness proxy indicator
drop if pgvc_green_tot==.      //2
drop if pgvc_green_tot==0      //51
gen pgreenness_tot = -ln(pgvc_green_tot*100+1)
gen pgreenness_pro = -ln(pgvc_green_pro*100+1)
sum greenness_tot-pgreenness_pro

save "Build/Output/ProductGreenness_2000-2016", replace




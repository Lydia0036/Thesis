
//Export product quality
//Customs data for 2016 do not have indicators of product prices and quantities

//Two methods:
//1. first calculate product quality at HS 8-digit level, then cluster to HS-4 digit level
//2. first cluster to HS-4 digit product level, then calculate product quality
//All clustering methods are simple average and weighted average respectively

//Trade mode, general trade = 1, processing trade = 2

//fid=firm' ID; 进出口分类代码_ImpExpTypeCd=import/export type; HS商品编码_HSCd=HS-8 digit code; 金额_美元_Sum_USD=product value;
//起运国或目的国代码_BegEndCntryCd=destination code; 起运国或目的国名称_BegEndCntryNm=destination name

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality"

*** Method 1 ***

//Calculate product quality at HS 8-digit level
//2000-2015
forvalues k=2000(1)2015{
  use BEC_Intermediary_process/`k' , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"      //keep export
  destring 价格_Price, replace
  gen logp=log(价格_Price)
  gen logs=log(金额_美元_Sum_USD)
  encode HS商品编码_HSCd, gen(HS)
  encode 起运国或目的国代码_BegEndCntryCd, gen(country)
  destring 贸易方式代码_TrdMdCd, gen(tradeway)
  destring 证券代码, gen(fid)
  sort fid HS country tradeway
  
  //Multidimensional fixed effects regression
  egen u1=group(fid country)   //fd, firm, product, (fd)multidimensional fixed effects
  egen u2=group(HS country)    //pd, product, destination, (pd)multidimensional fixed effects
  
  reghdfe logs logp , ab(FE1=u1 FE2=u2) resid  
  predict res, resid  //real meaning of stochastic disturbance term, eit.
  gen b=_b[logp]      //extract regression coefficient
  gen logph=b*logp    //calculate the fit value
   
  *Calculate export quality (firm-product-destination-trade mode-year). As the data is year data, no longer control year fixed effect
  gen expqua= logs-logph-FE2 //five dimensional unit export quality
  
  *Total export quality of firm, expquaf
  drop if expqua==.
  drop if expqua<0
  bys fid: egen minexpqua=min(expqua)  //minimum value of the five-dimensional unit
  bys fid: egen maxexpqua=max(expqua)  //maximum value of the five-dimensional unit
  gen expqua1=(expqua-minexpqua)/(maxexpqua-minexpqua)
  bys fid (HS country tradeway) : egen expquaf=mean(expqua1)
  
  *Firm-product-destination level export quality
  bys fid HS country (tradeway) : egen expquap=mean(expqua1)   //remove the classification of trade mode
  
  drop _reghdfe_resid FE1 FE2 res b logph minexpqua maxexpqua expqua1
  save HS8_quality/`k' , replace
}

//Convert HS1992 code, cluster to HS-4 digit level
//2000-2001, convert HS1996
forvalues k=2000(1)2001{
  use HS8_quality/`k' , clear
  drop HS fid country
  ren 证券代码 fid
  gen hs1996 = substr(HS商品编码_HSCd,1,4)
  label var hs1996 "HS-4 digit"
  merge m:1 hs1996 using "HS_conversion/hs1996-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs1996 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  bys fid hs92 c_d : egen quality_m=mean(expqua)
  label var quality_m "Method_1_mean_quality"
  bys fid hs92 c_d : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d : egen quality_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * expqua)
  label var quality_w "Method_1_weight_quality"
  duplicates drop fid hs92 c_d, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  save HS8_quality/output_year/`k' , replace
}

//2002-2006, convert HS2002
forvalues k=2002(1)2006{
  use HS8_quality/`k' , clear
  drop HS fid country
  ren 证券代码 fid
  gen hs2002 = substr(HS商品编码_HSCd,1,4)
  label var hs2002 "HS-4 digit"
  merge m:1 hs2002 using "HS_conversion/hs2002-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2002 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  bys fid hs92 c_d : egen quality_m=mean(expqua)
  label var quality_m "Method_1_mean_quality"
  bys fid hs92 c_d : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d : egen quality_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * expqua)
  label var quality_w "Method_1_weight_quality"
  duplicates drop fid hs92 c_d, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  save HS8_quality/output_year/`k' , replace
}

//2007-2011, convert HS2007
forvalues k=2007(1)2011{
  use HS8_quality/`k' , clear
  drop HS fid country
  ren 证券代码 fid
  gen hs2007 = substr(HS商品编码_HSCd,1,4)
  label var hs2007 "HS-4 digit"
  merge m:1 hs2007 using "HS_conversion/hs2007-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2007 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  bys fid hs92 c_d : egen quality_m=mean(expqua)
  label var quality_m "Method_1_mean_quality"
  bys fid hs92 c_d : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d : egen quality_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * expqua)
  label var quality_w "Method_1_weight_quality"
  duplicates drop fid hs92 c_d, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  save HS8_quality/output_year/`k' , replace
}

//2012-2015, convert HS2012
forvalues k=2012(1)2015{
  use HS8_quality/`k' , clear
  drop HS fid country
  ren 证券代码 fid
  gen hs2012 = substr(HS商品编码_HSCd,1,4)
  label var hs2012 "HS-4 digit"
  merge m:1 hs2012 using "HS_conversion/hs2012-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2012 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  bys fid hs92 c_d : egen quality_m=mean(expqua)
  label var quality_m "Method_1_mean_quality"
  bys fid hs92 c_d : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d : egen quality_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * expqua)
  label var quality_w "Method_1_weight_quality"
  duplicates drop fid hs92 c_d, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  save HS8_quality/output_year/`k' , replace
}

//Merged all dataset
clear all
cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality/HS8_quality/output_year"
local Files: dir . files "*.dta"
clear
append using `Files'
sort fid year
tab year
sum
destring fid year, replace
destring hs92, gen(hs)
ren 金额_美元_Sum_USD USD
label var expquaf "Firm_quality"
keep fid year countrycode countryname HS hs92 hs iso2 c_d country expquaf quality_m quality_w USD
save "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality/Quality_1_2000-2015", replace



*** Method 2 ***

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality"

//First convert all HS code to HS1992 version, and cluster product value and price to HS-4 digit level, then calculate product quality
//2000-2001, convert HS1996
forvalues k=2000(1)2001{
  use BEC_Intermediary_process/`k' , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"    //keep export
  ren 证券代码 fid
  gen hs1996 = substr(HS商品编码_HSCd,1,4)
  label var hs1996 "HS-4 digit"
  merge m:1 hs1996 using "HS_conversion/hs1996-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs1996 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  destring 价格_Price, replace
  destring 贸易方式代码_TrdMdCd, gen(tradeway)
  bys fid hs92 c_d tradeway : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d tradeway : egen 价格_Price_m=mean(价格_Price)
  bys fid hs92 c_d tradeway : egen 价格_Price_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * 价格_Price)
  duplicates drop fid hs92 c_d tradeway, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  
  *Calculate product quality at HS 4-digit level
  gen logs=log(金额_美元_Sum_USD)
  sort fid hs92 c_d tradeway
  
  //Multidimensional fixed effects regression
  egen u1=group(fid c_d)     //fd, firm, product, (fd)multidimensional fixed effects
  egen u2=group(hs92 c_d)    //pd, product, destination, (pd)multidimensional fixed effects
  
  foreach i in m w {
    gen logp=log(价格_Price_`i')

    reghdfe logs logp , ab(FE1=u1 FE2=u2) resid  
    predict res, resid  //real meaning of stochastic disturbance term, eit.
    gen b=_b[logp]      //extract regression coefficient
    gen logph=b*logp    //calculate the fit value
    
    *Calculate export quality (firm-product-destination-trade mode-year)
    gen expqua_`i'= logs-logph-FE2 //five dimensional unit export quality
    
	*Total export quality of firm, expquaf
    drop if expqua_`i'==.
    drop if expqua_`i'<0
    bys fid: egen minexpqua=min(expqua_`i')  //minimum value of the five-dimensional unit
    bys fid: egen maxexpqua=max(expqua_`i')  //maximum value of the five-dimensional unit
    gen expqua1=(expqua_`i'-minexpqua)/(maxexpqua-minexpqua)
    bys fid (hs92 c_d tradeway) : egen expquaf_`i'=mean(expqua1)
	
	*Firm-product-destination level export quality
    bys fid hs92 c_d (tradeway) : egen mexpqua_`i' = mean(expqua1)   //remove the classification of trade mode
    replace expqua_`i' = mexpqua_`i'
    drop logp _reghdfe_resid FE1 FE2 res b logph minexpqua maxexpqua expqua1 mexpqua_`i'
  }
  
  duplicates drop fid hs92 c_d, force
  save HS4_quality/`k' , replace
}

//2002-2006, convert HS2002
forvalues k=2002(1)2006{
  use BEC_Intermediary_process/`k' , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"    //keep export
  ren 证券代码 fid
  gen hs2002 = substr(HS商品编码_HSCd,1,4)
  label var hs2002 "HS-4 digit"
  merge m:1 hs2002 using "HS_conversion/hs2002-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2002 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  destring 价格_Price, replace
  destring 贸易方式代码_TrdMdCd, gen(tradeway)
  bys fid hs92 c_d tradeway : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d tradeway : egen 价格_Price_m=mean(价格_Price)
  bys fid hs92 c_d tradeway : egen 价格_Price_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * 价格_Price)
  duplicates drop fid hs92 c_d tradeway, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  
  *Calculate product quality at HS 4-digit level
  gen logs=log(金额_美元_Sum_USD)
  sort fid hs92 c_d tradeway
  
  //Multidimensional fixed effects regression
  egen u1=group(fid c_d)     //fd, firm, product, (fd)multidimensional fixed effects
  egen u2=group(hs92 c_d)    //pd, product, destination, (pd)multidimensional fixed effects
  
  foreach i in m w {
    gen logp=log(价格_Price_`i')

    reghdfe logs logp , ab(FE1=u1 FE2=u2) resid  
    predict res, resid  //real meaning of stochastic disturbance term, eit.
    gen b=_b[logp]      //extract regression coefficient
    gen logph=b*logp    //calculate the fit value
    
    *Calculate export quality (firm-product-destination-trade mode-year)
    gen expqua_`i'= logs-logph-FE2 //five dimensional unit export quality
    
	*Total export quality of firm, expquaf
    drop if expqua_`i'==.
    drop if expqua_`i'<0
    bys fid: egen minexpqua=min(expqua_`i')  //minimum value of the five-dimensional unit
    bys fid: egen maxexpqua=max(expqua_`i')  //maximum value of the five-dimensional unit
    gen expqua1=(expqua_`i'-minexpqua)/(maxexpqua-minexpqua)
    bys fid (hs92 c_d tradeway) : egen expquaf_`i'=mean(expqua1)
	
	*Firm-product-destination level export quality
    bys fid hs92 c_d (tradeway) : egen mexpqua_`i' = mean(expqua1)   //remove the classification of trade mode
    replace expqua_`i' = mexpqua_`i'
    drop logp _reghdfe_resid FE1 FE2 res b logph minexpqua maxexpqua expqua1 mexpqua_`i'
  }
  
  duplicates drop fid hs92 c_d, force
  save HS4_quality/`k' , replace
}


//2007-2011, convert HS2007
forvalues k=2007(1)2011{
  use BEC_Intermediary_process/`k' , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"    //keep export
  ren 证券代码 fid
  gen hs2007 = substr(HS商品编码_HSCd,1,4)
  label var hs2007 "HS-4 digit"
  merge m:1 hs2007 using "HS_conversion/hs2007-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2007 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  destring 价格_Price, replace
  destring 贸易方式代码_TrdMdCd, gen(tradeway)
  bys fid hs92 c_d tradeway : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d tradeway : egen 价格_Price_m=mean(价格_Price)
  bys fid hs92 c_d tradeway : egen 价格_Price_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * 价格_Price)
  duplicates drop fid hs92 c_d tradeway, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  
  *Calculate product quality at HS 4-digit level
  gen logs=log(金额_美元_Sum_USD)
  sort fid hs92 c_d tradeway
  
  //Multidimensional fixed effects regression
  egen u1=group(fid c_d)     //fd, firm, product, (fd)multidimensional fixed effects
  egen u2=group(hs92 c_d)    //pd, product, destination, (pd)multidimensional fixed effects
  
  foreach i in m w {
    gen logp=log(价格_Price_`i')

    reghdfe logs logp , ab(FE1=u1 FE2=u2) resid  
    predict res, resid  //real meaning of stochastic disturbance term, eit.
    gen b=_b[logp]      //extract regression coefficient
    gen logph=b*logp    //calculate the fit value
    
    *Calculate export quality (firm-product-destination-trade mode-year)
    gen expqua_`i'= logs-logph-FE2 //five dimensional unit export quality
    
	*Total export quality of firm, expquaf
    drop if expqua_`i'==.
    drop if expqua_`i'<0
    bys fid: egen minexpqua=min(expqua_`i')  //minimum value of the five-dimensional unit
    bys fid: egen maxexpqua=max(expqua_`i')  //maximum value of the five-dimensional unit
    gen expqua1=(expqua_`i'-minexpqua)/(maxexpqua-minexpqua)
    bys fid (hs92 c_d tradeway) : egen expquaf_`i'=mean(expqua1)
	
	*Firm-product-destination level export quality
    bys fid hs92 c_d (tradeway) : egen mexpqua_`i' = mean(expqua1)   //remove the classification of trade mode
    replace expqua_`i' = mexpqua_`i'
    drop logp _reghdfe_resid FE1 FE2 res b logph minexpqua maxexpqua expqua1 mexpqua_`i'
  }
  
  duplicates drop fid hs92 c_d, force
  save HS4_quality/`k' , replace
}

//2012-2015, convert HS2012
forvalues k=2012(1)2015{
  use BEC_Intermediary_process/`k' , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"    //keep export
  ren 证券代码 fid
  gen hs2012 = substr(HS商品编码_HSCd,1,4)
  label var hs2012 "HS-4 digit"
  merge m:1 hs2012 using "HS_conversion/hs2012-1992", keepusing(hs1992)
  keep if _merge==3
  drop _merge
  ren hs2012 HS
  ren hs1992 hs92
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  destring countrycode, replace
  merge m:1 countrycode using "/Users/lydia/Desktop/申博/Github/Data/customs-csmar-ISO", keepusing(iso2 iso3 country)
  keep if _merge==3
  drop _merge
  ren iso3 c_d
  drop if 金额_美元_Sum_USD==.
  destring 价格_Price, replace
  destring 贸易方式代码_TrdMdCd, gen(tradeway)
  bys fid hs92 c_d tradeway : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys fid hs92 c_d tradeway : egen 价格_Price_m=mean(价格_Price)
  bys fid hs92 c_d tradeway : egen 价格_Price_w=total( (金额_美元_Sum_USD/金额_美元_Sum_hs) * 价格_Price)
  duplicates drop fid hs92 c_d tradeway, force
  drop 金额_美元_Sum_USD
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  
  *Calculate product quality at HS 4-digit level
  gen logs=log(金额_美元_Sum_USD)
  sort fid hs92 c_d tradeway
  
  //Multidimensional fixed effects regression
  egen u1=group(fid c_d)     //fd, firm, product, (fd)multidimensional fixed effects
  egen u2=group(hs92 c_d)    //pd, product, destination, (pd)multidimensional fixed effects
  
  foreach i in m w {
    gen logp=log(价格_Price_`i')

    reghdfe logs logp , ab(FE1=u1 FE2=u2) resid  
    predict res, resid  //real meaning of stochastic disturbance term, eit.
    gen b=_b[logp]      //extract regression coefficient
    gen logph=b*logp    //calculate the fit value
    
    *Calculate export quality (firm-product-destination-trade mode-year)
    gen expqua_`i'= logs-logph-FE2 //five dimensional unit export quality
    
	*Total export quality of firm, expquaf
    drop if expqua_`i'==.
    drop if expqua_`i'<0
    bys fid: egen minexpqua=min(expqua_`i')  //minimum value of the five-dimensional unit
    bys fid: egen maxexpqua=max(expqua_`i')  //maximum value of the five-dimensional unit
    gen expqua1=(expqua_`i'-minexpqua)/(maxexpqua-minexpqua)
    bys fid (hs92 c_d tradeway) : egen expquaf_`i'=mean(expqua1)
	
	*Firm-product-destination level export quality
    bys fid hs92 c_d (tradeway) : egen mexpqua_`i' = mean(expqua1)   //remove the classification of trade mode
    replace expqua_`i' = mexpqua_`i'
    drop logp _reghdfe_resid FE1 FE2 res b logph minexpqua maxexpqua expqua1 mexpqua_`i'
  }
  
  duplicates drop fid hs92 c_d, force
  save HS4_quality/`k' , replace
}

//Merged all dataset
clear all
cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality/HS4_quality"
local Files: dir . files "*.dta"
clear
append using `Files'
sort fid year
tab year
sum
destring fid year, replace
destring hs92, gen(hs)
ren 金额_美元_Sum_USD USD
label var expquaf_m "Method_2_Firm_quality"
label var expqua_m "Method_2_quality"
keep fid year countrycode countryname HS hs92 hs iso2 c_d country expqua_m expquaf_m expqua_w expquaf_w USD
save "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export quality/Quality_2_2000-2015", replace



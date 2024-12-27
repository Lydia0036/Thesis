
//Calculate the average price and total quantity of export products
//Unify all codes for trade mode: processing trade=="2", general trade=="1"

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export price and quantity/clean"

//2000-2001, convert HS1996
forvalues k=2000(1)2001{
  //BEC
  use /Users/lydia/Desktop/三重实证/上市公司/上市公司匹配海关详细数据2000-2016/`k', clear
  keep  经营单位名称_EntNm 证券代码 year 营业收入 ListedCoID SecurityID 进出口分类代码_ImpExpTypeCd 进出口分类名称_ImpExpTypeNm ///
  HS商品编码_HSCd 金额_美元_Sum_USD 贸易方式代码_TrdMdCd 贸易方式名称_TrdMdNm 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm ///
  数量_Quantity 价格_Price 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  keep if 贸易方式代码_TrdMdCd=="10"|贸易方式代码_TrdMdCd=="14"|贸易方式代码_TrdMdCd=="15"   //retain only the import and export data for general trade and processing trade
  replace 贸易方式代码_TrdMdCd="2" if 贸易方式代码_TrdMdCd=="14"|贸易方式代码_TrdMdCd=="15"  //unify all codes for trade mode
  replace 贸易方式代码_TrdMdCd="1" if 贸易方式代码_TrdMdCd=="10" 
  save `k'/贸易方式处理 , replace 

  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="2"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  save `k'/加工贸易进口 , replace     //import data for processing trade
  
  use `k'/贸易方式处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  save `k'/所有出口 , replace     //all export data
  
  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="1"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS96 = substr(HS商品编码_HSCd,1,6)
  save `k'/真正用于中间投入的一般贸易进口 , replace
  merge m:1 HS96 using "BEC4 to HS/HS96 00-01"
  keep if _merge==3
  keep if BEC=="111"|BEC=="121"|BEC=="21"|BEC=="22"|BEC=="31"|BEC=="322"|BEC=="42"|BEC=="53"
  drop HS96 BEC Relationship _merge
  save `k'/真正用于中间投入的一般贸易进口 , replace   //general trade imports genuinely used for intermediate inputs
  
  use `k'/加工贸易进口 , clear
  append using `k'/真正用于中间投入的一般贸易进口
  append using `k'/所有出口
  save `k'/BEC处理 , replace     //import and export data after excluding capital goods and consumer goods from general trade imports
  erase `k'/加工贸易进口.dta
  erase `k'/所有出口.dta
  erase `k'/真正用于中间投入的一般贸易进口.dta

  //Intermediary processing
  use `k'/BEC处理 ,clear
  keep if 进出口分类代码_ImpExpTypeCd=="1" 
  gen HS96 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS96 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==3
  destring 金额_美元_Sum_USD, replace
  replace mk=0 if mk==1
  replace 金额_美元_Sum_USD = 金额_美元_Sum_USD/(1-mk)
  drop HS96 _merge mk
  save `k'/含中间商的进口 ,replace    //imports through intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS96 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS96 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==1
  destring 金额_美元_Sum_USD, replace
  drop HS96 _merge mk
  save `k'/不含中间商的进口 ,replace    //imports without intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  destring 金额_美元_Sum_USD, replace
  append using `k'/含中间商的进口
  append using `k'/不含中间商的进口
  drop if strpos(经营单位名称_EntNm, "进出口")!=0|strpos(经营单位名称_EntNm, "经贸")!=0|strpos(经营单位名称_EntNm, "贸易")!=0|strpos(经营单位名称_EntNm, "科贸")!=0|strpos(经营单位名称_EntNm, "外经")!=0
  save `k'/BEC和中间商处理 , replace      //considering indirect imports through intermediaries, exclude intermediaries
  erase `k'/含中间商的进口.dta
  erase `k'/不含中间商的进口.dta
  
  //Calculate the average price and total quantity of export products
  use `k'/BEC和中间商处理, clear
  replace 进出口分类代码_ImpExpTypeCd="M" if 进出口分类代码_ImpExpTypeCd=="1"
  replace 进出口分类代码_ImpExpTypeCd="X" if 进出口分类代码_ImpExpTypeCd=="0"
  keep if 进出口分类代码_ImpExpTypeCd=="X"    //keep export
  keep 证券代码 year HS商品编码_HSCd 金额_美元_Sum_USD 数量_Quantity 价格_Price 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  gen hs1996 = substr(HS商品编码_HSCd,1,4)
  label var hs1996 "HS-4-digit"
  destring 数量_Quantity 价格_Price, replace
  bys 证券代码 hs1996 起运国或目的国代码_BegEndCntryCd : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys 证券代码 hs1996 起运国或目的国代码_BegEndCntryCd : egen 数量_Quantity_hs=sum(数量_Quantity)
  bys 证券代码 hs1996 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_m=mean(价格_Price)
  bys 证券代码 hs1996 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_w=total( (金额_美元_Sum_USD / 金额_美元_Sum_hs) * 价格_Price )
  duplicates drop 证券代码 hs1996 起运国或目的国代码_BegEndCntryCd, force
  drop 金额_美元_Sum_USD 数量_Quantity 价格_Price
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  drop HS商品编码_HSCd
  ren hs1996 HS
  save output_year/`k', replace
}


//2002-2006, convert HS2002
forvalues k=2002(1)2006{
  //BEC
  use /Users/lydia/Desktop/三重实证/上市公司/上市公司匹配海关详细数据2000-2016/`k', clear
  keep  经营单位名称_EntNm 证券代码 year 营业收入 ListedCoID SecurityID 进出口分类代码_ImpExpTypeCd 进出口分类名称_ImpExpTypeNm ///
  HS商品编码_HSCd 金额_美元_Sum_USD 贸易方式代码_TrdMdCd 贸易方式名称_TrdMdNm 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm ///
  数量_Quantity 价格_Price 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  keep if 贸易方式代码_TrdMdCd=="10"|贸易方式代码_TrdMdCd=="14"|贸易方式代码_TrdMdCd=="15"   //retain only the import and export data for general trade and processing trade
  replace 贸易方式代码_TrdMdCd="2" if 贸易方式代码_TrdMdCd=="14"|贸易方式代码_TrdMdCd=="15"  //unify all codes for trade mode
  replace 贸易方式代码_TrdMdCd="1" if 贸易方式代码_TrdMdCd=="10"
  save `k'/贸易方式处理 , replace 

  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="2"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  save `k'/加工贸易进口 , replace     //import data for processing trade
  
  use `k'/贸易方式处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  save `k'/所有出口 , replace     //all export data
  
  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="1"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS02 = substr(HS商品编码_HSCd,1,6)
  save `k'/真正用于中间投入的一般贸易进口 , replace
  merge m:1 HS02 using "BEC4 to HS/HS02 02-06"
  keep if _merge==3
  keep if BEC=="111"|BEC=="121"|BEC=="21"|BEC=="22"|BEC=="31"|BEC=="322"|BEC=="42"|BEC=="53"
  drop HS02 BEC Relationship _merge
  save `k'/真正用于中间投入的一般贸易进口 , replace   //general trade imports genuinely used for intermediate inputs
  
  use `k'/加工贸易进口 , clear
  append using `k'/真正用于中间投入的一般贸易进口
  append using `k'/所有出口
  save `k'/BEC处理 , replace     //import and export data after excluding capital goods and consumer goods from general trade imports
  erase `k'/加工贸易进口.dta
  erase `k'/所有出口.dta
  erase `k'/真正用于中间投入的一般贸易进口.dta

  //Intermediary processing
  use `k'/BEC处理 ,clear
  keep if 进出口分类代码_ImpExpTypeCd=="1" 
  gen HS02 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS02 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==3
  destring 金额_美元_Sum_USD, replace
  replace mk=0 if mk==1
  replace 金额_美元_Sum_USD = 金额_美元_Sum_USD/(1-mk)
  drop HS02 _merge mk
  save `k'/含中间商的进口 ,replace    //imports through intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS02 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS02 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==1
  destring 金额_美元_Sum_USD, replace
  drop HS02 _merge mk
  save `k'/不含中间商的进口 ,replace    //imports without intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  destring 金额_美元_Sum_USD, replace
  append using `k'/含中间商的进口
  append using `k'/不含中间商的进口
  drop if strpos(经营单位名称_EntNm, "进出口")!=0|strpos(经营单位名称_EntNm, "经贸")!=0|strpos(经营单位名称_EntNm, "贸易")!=0|strpos(经营单位名称_EntNm, "科贸")!=0|strpos(经营单位名称_EntNm, "外经")!=0
  save `k'/BEC和中间商处理 , replace      //considering indirect imports through intermediaries, exclude intermediaries
  erase `k'/含中间商的进口.dta
  erase `k'/不含中间商的进口.dta
  
  //Calculate the average price and total quantity of export products
  use `k'/BEC和中间商处理, clear
  replace 进出口分类代码_ImpExpTypeCd="M" if 进出口分类代码_ImpExpTypeCd=="1"
  replace 进出口分类代码_ImpExpTypeCd="X" if 进出口分类代码_ImpExpTypeCd=="0"
  keep if 进出口分类代码_ImpExpTypeCd=="X"    //keep export
  keep 证券代码 year HS商品编码_HSCd 金额_美元_Sum_USD 数量_Quantity 价格_Price 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  gen hs2002 = substr(HS商品编码_HSCd,1,4)
  label var hs2002 "HS-4-digit"
  destring 数量_Quantity 价格_Price, replace
  bys 证券代码 hs2002 起运国或目的国代码_BegEndCntryCd : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys 证券代码 hs2002 起运国或目的国代码_BegEndCntryCd : egen 数量_Quantity_hs=sum(数量_Quantity)
  bys 证券代码 hs2002 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_m=mean(价格_Price)
  bys 证券代码 hs2002 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_w=total( (金额_美元_Sum_USD / 金额_美元_Sum_hs) * 价格_Price )
  duplicates drop 证券代码 hs2002 起运国或目的国代码_BegEndCntryCd, force
  drop 金额_美元_Sum_USD 数量_Quantity 价格_Price
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  drop HS商品编码_HSCd
  ren hs2002 HS
  save output_year/`k', replace
}


//2007-2011, convert HS2007
//The codes for processing trade and general trade were changed to 1 and 2
forvalues k=2007(1)2011{
  //BEC
  use /Users/lydia/Desktop/三重实证/上市公司/上市公司匹配海关详细数据2000-2016/`k', clear
  keep  经营单位名称_EntNm 证券代码 year 营业收入 ListedCoID SecurityID 进出口分类代码_ImpExpTypeCd 进出口分类名称_ImpExpTypeNm ///
  HS商品编码_HSCd 金额_美元_Sum_USD 贸易方式代码_TrdMdCd 贸易方式名称_TrdMdNm 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm ///
  数量_Quantity 价格_Price 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  keep if 贸易方式代码_TrdMdCd=="2"|贸易方式代码_TrdMdCd=="1"   //retain only the import and export data for general trade and processing trade
  save `k'/贸易方式处理 , replace 

  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="2"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  save `k'/加工贸易进口 , replace     //import data for processing trade
  
  use `k'/贸易方式处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  save `k'/所有出口 , replace     //all export data
  
  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="1"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS07 = substr(HS商品编码_HSCd,1,6)
  save `k'/真正用于中间投入的一般贸易进口 , replace
  merge m:1 HS07 using "BEC4 to HS/HS07 07-11"
  keep if _merge==3
  keep if BEC=="111"|BEC=="121"|BEC=="21"|BEC=="22"|BEC=="31"|BEC=="322"|BEC=="42"|BEC=="53"
  drop HS07 BEC Relationship _merge
  save `k'/真正用于中间投入的一般贸易进口 , replace   //general trade imports genuinely used for intermediate inputs
  
  use `k'/加工贸易进口 , clear
  append using `k'/真正用于中间投入的一般贸易进口
  append using `k'/所有出口
  save `k'/BEC处理 , replace     //import and export data after excluding capital goods and consumer goods from general trade imports
  erase `k'/加工贸易进口.dta
  erase `k'/所有出口.dta
  erase `k'/真正用于中间投入的一般贸易进口.dta

  //Intermediary processing
  use `k'/BEC处理 ,clear
  keep if 进出口分类代码_ImpExpTypeCd=="1" 
  gen HS07 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS07 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==3
  destring 金额_美元_Sum_USD, replace
  replace mk=0 if mk==1
  replace 金额_美元_Sum_USD = 金额_美元_Sum_USD/(1-mk)
  drop HS07 _merge mk
  save `k'/含中间商的进口 ,replace    //imports through intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS07 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS07 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==1
  destring 金额_美元_Sum_USD, replace
  drop HS07 _merge mk
  save `k'/不含中间商的进口 ,replace    //imports without intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  destring 金额_美元_Sum_USD, replace
  append using `k'/含中间商的进口
  append using `k'/不含中间商的进口
  drop if strpos(经营单位名称_EntNm, "进出口")!=0|strpos(经营单位名称_EntNm, "经贸")!=0|strpos(经营单位名称_EntNm, "贸易")!=0|strpos(经营单位名称_EntNm, "科贸")!=0|strpos(经营单位名称_EntNm, "外经")!=0
  save `k'/BEC和中间商处理 , replace      //considering indirect imports through intermediaries, exclude intermediaries
  erase `k'/含中间商的进口.dta
  erase `k'/不含中间商的进口.dta
  
  //Calculate the average price and total quantity of export products
  use `k'/BEC和中间商处理, clear
  replace 进出口分类代码_ImpExpTypeCd="M" if 进出口分类代码_ImpExpTypeCd=="1"
  replace 进出口分类代码_ImpExpTypeCd="X" if 进出口分类代码_ImpExpTypeCd=="0"
  keep if 进出口分类代码_ImpExpTypeCd=="X"    //keep export
  keep 证券代码 year HS商品编码_HSCd 金额_美元_Sum_USD 数量_Quantity 价格_Price 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  gen hs2007 = substr(HS商品编码_HSCd,1,4)
  label var hs2007 "HS-4-digit"
  destring 数量_Quantity 价格_Price, replace
  bys 证券代码 hs2007 起运国或目的国代码_BegEndCntryCd : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys 证券代码 hs2007 起运国或目的国代码_BegEndCntryCd : egen 数量_Quantity_hs=sum(数量_Quantity)
  bys 证券代码 hs2007 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_m=mean(价格_Price)
  bys 证券代码 hs2007 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_w=total( (金额_美元_Sum_USD / 金额_美元_Sum_hs) * 价格_Price )
  duplicates drop 证券代码 hs2007 起运国或目的国代码_BegEndCntryCd, force
  drop 金额_美元_Sum_USD 数量_Quantity 价格_Price
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  drop HS商品编码_HSCd
  ren hs2007 HS
  save output_year/`k', replace
}


//2012-2015, convert HS2012
//The code for processing trade was changed to 23
//There is no quantity and price data for 2016
forvalues k=2012(1)2015{
  //BEC
  use /Users/lydia/Desktop/三重实证/上市公司/上市公司匹配海关详细数据2000-2016/`k', clear
  rename 产消国代码_PrdMktCntryCd 起运国或目的国代码_BegEndCntryCd 
  rename 产消国名称_PrdMktCntryNm 起运国或目的国名称_BegEndCntryNm
  keep  经营单位名称_EntNm 证券代码 year 营业收入 ListedCoID SecurityID 进出口分类代码_ImpExpTypeCd 进出口分类名称_ImpExpTypeNm ///
  HS商品编码_HSCd 金额_美元_Sum_USD 贸易方式代码_TrdMdCd 贸易方式名称_TrdMdNm 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm ///
  数量_Quantity 价格_Price 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  keep if 贸易方式代码_TrdMdCd=="23"|贸易方式代码_TrdMdCd=="1"    //retain only the import and export data for general trade and processing trade
  replace 贸易方式代码_TrdMdCd="2" if 贸易方式代码_TrdMdCd=="23"  //unify all codes for trade mode
  save `k'/贸易方式处理 , replace 

  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="2"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  save `k'/加工贸易进口 , replace     //import data for processing trade
  
  use `k'/贸易方式处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  save `k'/所有出口 , replace     //all export data
  
  use `k'/贸易方式处理 , clear
  keep if 贸易方式代码_TrdMdCd=="1"
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS12 = substr(HS商品编码_HSCd,1,6)
  save `k'/真正用于中间投入的一般贸易进口 , replace
  merge m:1 HS12 using "BEC4 to HS/HS12 12-16"
  keep if _merge==3
  keep if BEC=="111"|BEC=="121"|BEC=="21"|BEC=="22"|BEC=="31"|BEC=="322"|BEC=="42"|BEC=="53"
  drop HS12 BEC Relationship _merge
  save `k'/真正用于中间投入的一般贸易进口 , replace   //general trade imports genuinely used for intermediate inputs
  
  use `k'/加工贸易进口 , clear
  append using `k'/真正用于中间投入的一般贸易进口
  append using `k'/所有出口
  save `k'/BEC处理 , replace     //import and export data after excluding capital goods and consumer goods from general trade imports
  erase `k'/加工贸易进口.dta
  erase `k'/所有出口.dta
  erase `k'/真正用于中间投入的一般贸易进口.dta

  //Intermediary processing
  use `k'/BEC处理 ,clear
  keep if 进出口分类代码_ImpExpTypeCd=="1" 
  gen HS12 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS12 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==3
  destring 金额_美元_Sum_USD, replace
  replace mk=0 if mk==1
  replace 金额_美元_Sum_USD = 金额_美元_Sum_USD/(1-mk)
  drop HS12 _merge mk
  save `k'/含中间商的进口 ,replace    //imports through intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="1"
  gen HS12 = substr(HS商品编码_HSCd,1,6)
  merge m:1 HS12 贸易方式代码_TrdMdCd using /Users/lydia/Desktop/三重实证/上市公司/上市公司进出口国家总额/`k'/mk, keepusing(mk)
  keep if _merge==1
  destring 金额_美元_Sum_USD, replace
  drop HS12 _merge mk
  save `k'/不含中间商的进口 ,replace    //imports without intermediaries
  
  use `k'/BEC处理 , clear
  keep if 进出口分类代码_ImpExpTypeCd=="0"
  destring 金额_美元_Sum_USD, replace
  append using `k'/含中间商的进口
  append using `k'/不含中间商的进口
  drop if strpos(经营单位名称_EntNm, "进出口")!=0|strpos(经营单位名称_EntNm, "经贸")!=0|strpos(经营单位名称_EntNm, "贸易")!=0|strpos(经营单位名称_EntNm, "科贸")!=0|strpos(经营单位名称_EntNm, "外经")!=0
  save `k'/BEC和中间商处理 , replace      //considering indirect imports through intermediaries, exclude intermediaries
  erase `k'/含中间商的进口.dta
  erase `k'/不含中间商的进口.dta
  
  //Calculate the average price and total quantity of export products
  use `k'/BEC和中间商处理, clear
  replace 进出口分类代码_ImpExpTypeCd="M" if 进出口分类代码_ImpExpTypeCd=="1"
  replace 进出口分类代码_ImpExpTypeCd="X" if 进出口分类代码_ImpExpTypeCd=="0"
  keep if 进出口分类代码_ImpExpTypeCd=="X"    //keep export
  keep 证券代码 year HS商品编码_HSCd 金额_美元_Sum_USD 数量_Quantity 价格_Price 起运国或目的国代码_BegEndCntryCd 起运国或目的国名称_BegEndCntryNm 数量单位代码_QuantityUnitCd 数量单位名称_QuantityUnitNm
  gen hs2012 = substr(HS商品编码_HSCd,1,4)
  label var hs2012 "HS-4-digit"
  destring 数量_Quantity 价格_Price, replace
  bys 证券代码 hs2012 起运国或目的国代码_BegEndCntryCd : egen 金额_美元_Sum_hs=sum(金额_美元_Sum_USD)
  bys 证券代码 hs2012 起运国或目的国代码_BegEndCntryCd : egen 数量_Quantity_hs=sum(数量_Quantity)
  bys 证券代码 hs2012 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_m=mean(价格_Price)
  bys 证券代码 hs2012 起运国或目的国代码_BegEndCntryCd : egen 价格_Price_w=total( (金额_美元_Sum_USD / 金额_美元_Sum_hs) * 价格_Price )
  duplicates drop 证券代码 hs2012 起运国或目的国代码_BegEndCntryCd, force
  drop 金额_美元_Sum_USD 数量_Quantity 价格_Price
  ren 金额_美元_Sum_hs 金额_美元_Sum_USD
  drop HS商品编码_HSCd
  ren hs2012 HS
  save output_year/`k', replace
}


//Merge all data
clear all
cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export price and quantity/clean/output_year"
local theFiles: dir . files "*.dta"
clear
append using `theFiles'
sort 证券代码 year
tab year
ren 证券代码 fid
ren 金额_美元_Sum_USD USD
ren 起运国或目的国代码_BegEndCntryCd countrycode
ren 起运国或目的国名称_BegEndCntryNm countryname
ren 数量_Quantity_hs Quantity
ren 价格_Price_m Price_m
ren 价格_Price_w Price_w
ren 数量单位代码_QuantityUnitCd QuantityUnitCd
ren 数量单位名称_QuantityUnitNm QuantityUnitNm
sum
destring fid year countrycode, replace
save "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Demand effect/Export price and quantity/Export_price & quantity_2000-2015", replace



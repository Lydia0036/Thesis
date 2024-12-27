
//Preproccess, unify variable name

clear all

cd "/Users/lydia/Desktop/申博/Github/Data/firm_customs"

local files : dir . files "*.dta"
foreach f of local files {
  use `f', clear
  ren 证券代码 fid
  ren 营业收入 revenue
  ren 经营单位名称_EntNm firm_name
  ren 进出口分类代码_ImpExpTypeCd trade_code
  ren 进出口分类名称_ImpExpTypeNm trade_name
  ren HS商品编码_HSCd HScode
  ren 金额_美元_Sum_USD USD
  ren 起运国或目的国代码_BegEndCntryCd countrycode
  ren 起运国或目的国名称_BegEndCntryNm countryname
  ren 贸易方式代码_TrdMdCd trademode_code
  ren 贸易方式名称_TrdMdNm trademode_name
  save `f', replace
}


//customs-csmar-ISO, country code conversion
clear all

cd "/Users/lydia/Desktop/申博/Github/Data"

use "customs-csmar-ISO", clear
ren 国家代码 countrycode
ren 国家名称 countryname
ren 国泰安国家代码 csmar_ctycode
ren 国泰安国家名称 csmar_ctyname
label var OsirisCountry "大写 Osiris Country Name"
save "customs-csmar-ISO", replace


//
use "GVC participation_adjust 2000-2016", clear
ren 证券代码 fid
ren 营业收入_美元 revenue
ren 经营单位名称_EntNm  FirmName
ren 金额_美元_Sum_USDMO MO
ren 金额_美元_Sum_USDMP MP
ren 金额_美元_Sum_USDXO XO
ren 金额_美元_Sum_USDXP XP
ren 金额_美元_Sum_USDM M
ren 金额_美元_Sum_USDX X
ren GVC嵌入度 GVC
label var GVC "GVC participation"
ren 营业收入 revenue_CNY
ren 现金流比率 Cash
ren 财务费用率 Finance
ren 企业要素密集度 Capint
ren 企业年龄 Age
ren 企业规模 Asset
ren 财务杠杆 Leverage
ren 管理费用成本 Management
ren 邮编_ZipCd ZipCd
ren 电话_Telephone Telephone

foreach i in revenue MO MP XO XP M X D {
 replace `i'=`i'/1000
}

label var MO "general import_thousand USD"
label var MP "processing import_thousand USD"
label var XO "general export_thousand USD"
label var XP "processing export_thousand USD"
label var M "total import_thousand USD"
label var X "total export_thousand USD"
label var D "domestic sales_thousand USD"

save "GVC participation_adjust 2000-2016", replace


//Process listed company carbon emission data
clear
import excel "Listed carbon emission_1992-2022.xlsx", sheet("Sheet2") firstrow
ren 年 year
ren 证券代码 fid
ren 会计期间 acct_period
ren 月份 month
ren 行业 Industry
ren 上市公司碳排放总量吨 TCE      //Total Carbon Emissions
ren 化石燃料燃烧排放 Fossil      //Fossil fuel combustion emission
ren 生物质燃料燃烧排放 Biomass   //Biomass fuel combustion emissions
ren 原料开采逃逸排放 Raw            //Raw material extraction fugitive emissions
ren 石油和天然气系统逃逸排放 Oilgas  //Oil and gas system fugitive emissions
ren 电力调入调出间接碳排放 Indirect    //Indirect carbon emissions from electricity import and export
ren 生产过程排放 Production          //Production process emissions
ren 固体废弃物焚烧排放 Solid          //Solid waste incineration emissions
ren 污水处理导致的排放 wastewater     //Emissions caused by wastewater treatment
ren 土地利用方式转变森林转为工业用地导致的排放 land  //Emissions from land use change, such as converting forests to industrial land

keep if month==12   //108,680
duplicates drop fid year, force  //0
save "Listed carbon emission_1992-2022", replace


//Control variables

cd "/Users/lydia/Desktop/申博/Github/Data/Control"

//ROA
use "/Users/lydia/Desktop/三重实证/上市公司/控制变量/上市公司盈利能力2000-2016", clear
ren 证券代码 fid
ren 总资产净利润率（ROA）A ROAA
ren 总资产净利润率（ROA）B ROAB
ren 总资产净利润率（ROA）C ROAC
ren 总资产净利润率（ROA）TTM ROATTM
keep fid year ROAA-ROATTM
save "Profitability_2000-2016", replace

//Shareholders
use "Shareholding concentration_2003-2016", clear
ren 证券代码 fid
ren 股权集中指标1 Largest
ren 股权集中指标4 Top10
save "Shareholding concentration_2003-2016", replace

//Financing Constraints
use "Financing Constraints_FC_2000-2016", clear
ren 证券代码 fid
ren FC指数 FC
save "Financing Constraints_FC_2000-2016", replace

use "Financing Constraints_KZ_2000-2016", clear
ren 证券代码 fid
ren KZ指数 KZ
save "Financing Constraints_KZ_2000-2016", replace

use "Financing Constraints_SA_2000-2016", clear
ren 证券代码 fid
ren SA指数 SA
save "Financing Constraints_SA_2000-2016", replace

use "Financing Constraints_WW_2000-2016", clear
ren 证券代码 fid
ren WW指数 WW
save "Financing Constraints_WW_2000-2016", replace

//Equity nature (Ownership)
use "Ownership_2003-2016", clear
ren 证券代码 fid
ren 股权性质 OwnershipType
ren 股权性质编码 OwnershipCode
save "Ownership_2003-2016", replace

//Endogeneity
cd "/Users/lydia/Desktop/申博/Github/Data/Robust"
use "List of thousand enterprises", clear
ren 企业名称 FirmName
save "List of thousand enterprises", replace

//Sales expenses
use "Fundamental analysis-Financial indicators_2000-2020", clear
ren 证券代码 fid
ren 销售费用 salecost
save "Fundamental analysis-Financial indicators_2000-2020", replace


//Technological effect

cd "/Users/lydia/Desktop/申博/Github/Build/Mechanism/Technological effect"

//Green innovation efficiency
use "Green innovation efficiency_2007-2021", clear
ren 股票代码 fid
ren 绿色创新效率 green_efficiency
save "Green innovation efficiency_2007-2021", replace

//Green invention patent applications
use "Green patent applications_2000-2019", clear
ren 证券代码 fid
ren 绿色发明专利申请量 invention
ren 绿色实用新型专利申请量 utility
ren 绿色专利申请量 total
save "Green patent applications_2000-2019", replace

//Overall innovation
use "Overall innovation_2011-2021", clear
ren 证券代码 fid
ren 当年独立申请专利总和 Patent
save "Overall innovation_2011-2021", replace

//Overall patent applications
use "Overall patent applications_2006-2021", clear
ren 证券代码 fid
save "Overall patent applications_2006-2021", replace










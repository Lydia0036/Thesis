
//Control variables, CSMAR data

cd "/Users/lydia/Desktop/国泰安数据"

//Financial indicators, dividend payout ratio
import excel "财务指标分析/财务指标分析-股利分配2000-2022/股利分配2000-2022/股利分配2000-2022.xlsx", sheet("sheet1") firstrow clear
nrow, keep    //use the first row as variable names and retain the first row
labone        //use the first row as variable labels
drop in 1/2   //delete the first two rows, including the labels and units in the original Excel
gen year=substr(统计截止日期,1,4)
destring year, replace
tab year      //view data for each year
drop if year>2016
rename 股票代码 证券代码
keep if 报表类型编码=="A"   //retain the consolidated financial statement data
destring 证券代码, replace
destring 每股税前现金股利-股利分配率3, replace
gen month=substr(统计截止日期,6,2)
destring month, replace
tab month
keep if month==12
save "/Users/lydia/Desktop/申博/Github/Data/Control/Dividend distribution_2000-2016",replace


//Shareholders
//the proportion of shares held by the largest shareholder
//the shareholding ratio of the top 10 shareholders
import excel "股东2003-2023/股权信息/十大股东股权集中文件/十大股东股权集中文件.xlsx", sheet("sheet1") firstrow clear
nrow, keep
labone
drop in 1/2
gen year=substr(统计截止日期,1,4)
destring year, replace
tab year
drop if year>2016
rename Shrcr1 股权集中指标1
rename Shrcr2 股权集中指标2
rename Shrcr3 股权集中指标3
rename Shrcr4 股权集中指标4
destring 证券代码, replace
destring 股权集中指标1-Herfindahl_10指数, replace
label var 股权集中指标1 "公司第一大股东持股比例"
label var 股权集中指标4 "公司前10位大股东持股比例之和"
gen month=substr(统计截止日期,6,2)
destring month, replace
tab month
keep if month==12
save "/Users/lydia/Desktop/申博/Github/Data/Control/Shareholding concentration_2003-2016",replace


//Governance structure
//Proportion of independent directors
import excel "治理结构2000-2022/高管动态/高管人数、持股及薪酬情况表2000-2022/高管人数、持股及薪酬情况表2000-2022.xlsx", sheet("sheet1") firstrow clear
nrow, keep
labone
drop in 1/2
gen year=substr(统计截止日期,1,4)
destring year, replace
tab year
drop if year>2016
keep if 统计口径=="1"
destring 证券代码, replace
destring 监管层总人数-持有本公司股份的监事人数, replace
gen month=substr(统计截止日期,6,2)
destring month, replace
tab month
keep if month==12
save "/Users/lydia/Desktop/申博/Github/Data/Control/Number of executives_2000-2016",replace

//Chairman and CEO dual role situation
import excel "治理结构2000-2022/基本数据/治理综合信息文件2000-2022/治理综合信息文件2000-2022.xlsx", sheet("sheet1") firstrow clear
nrow, keep
labone
drop in 1/2
gen year=substr(统计截止日期,1,4)
destring year, replace
tab year
drop if year>2016
destring 证券代码, replace
destring 股本结构是否变化-独立董事与上市公司工作地点一致性统计, replace
label var 董事长与总经理兼任情况 "1为是，2为否"
gen month=substr(统计截止日期,6,2)
destring month, replace
tab month
keep if month==12
save "/Users/lydia/Desktop/申博/Github/Data/Control/Comprehensive governance_2000-2016",replace


//Social responsibility
//whether it follows the GRI "Sustainability Reporting Guidelines"
//whether the auditor is from one of the Big Four accounting firms
import excel "社会责任2006-2021/上市公司社会责任报告基本信息表2006-2021/上市公司社会责任报告基本信息表2006-2021.xlsx", sheet("sheet1") firstrow clear
nrow, keep
labone
drop in 1/2
gen year=substr(统计截止日期,1,4)
destring year, replace
tab year
drop if year>2016
rename 股票代码 证券代码
destring 证券代码, replace
destring 纳税总额-审计师是否来自四大会计师事务所, replace
label var 是否参照GRI《可持续发展报告指南》 "1为是，2为否"
label var 审计师是否来自四大会计师事务所 "1为是，2为否"
gen month=substr(统计截止日期,6,2)
destring month, replace
tab month
keep if month==12
save "/Users/lydia/Desktop/申博/Github/Data/Control/Social responsibility_2006-2016",replace


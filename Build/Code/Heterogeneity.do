
//Heterogeneity

cd "/Users/lydia/Desktop/申博/Github"

//Industries with varying levels of carbon emissions
use "Build/Output/Firm_green_harmon_2000-2016", clear
keep fid IndustryName IndustryCode year TCE
bys fid : egen meanfid=mean(TCE)
duplicates drop fid, force

bys IndustryCode : egen meanc=mean(meanfid)
bys IndustryCode : egen sdc=sd(meanfid)
duplicates drop IndustryCode, force
keep IndustryName IndustryCode meanc sdc

drop if sdc==.      //25 sub-sectors of manufacturing industry
sort meanc
gen carbon_group=group(3)
label var carbon_group "group by the average total carbon emissions of firms, 3-severe"
save "Build/Heterogeneity/Industry total carbon emissions grouping", replace


//Business orientation
//Export share, GVC
use "Build/Output/Firm_green_harmon_2000-2016", clear
bys fid : egen meanexr=mean(exr)
bys fid : egen meangvc=mean(GVC)

duplicates drop fid, force
egen medianexr=median(meanexr)
egen mediangvc=median(meangvc)
keep fid medianexr mediangvc

save "Build/Heterogeneity/Export share & GVC grouping", replace

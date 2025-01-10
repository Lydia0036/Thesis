
//Cost complementarity effect

cd "/Github/Build"

//Product varieties grouping
use "Mechanism/Cost complementarity effect/Export destinations and varieties/Firm_export varieties_2000-2016", clear
keep fid year products
bys fid : egen meanfid=mean(products)
duplicates drop fid, force
sort meanfid
gen group_varieties=group(3)
label var group_varieties "group based on average product varieties per firm, 3 is most"
save "Mechanism/Cost complementarity effect/Product varieties grouping", replace


//Export share grouping
use "Output/Firm_green_harmon_2000-2016", clear
keep fid year exr
bys fid : egen meanfid=mean(exr)
duplicates drop fid, force
sort meanfid
gen group_expshare=group(3)
label var group_expshare "group based on average export share, 3 is most"
save "Mechanism/Cost complementarity effect/Export share grouping", replace



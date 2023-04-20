clear
set more off
use datasets/cfps_adult.dta
python set exec /opt/Anaconda/bin/python
// 清洗并产生数据
drop if employ2014<0
drop if te4<0
drop if qa301<0 | qa301==5
gen exit_labor=employ2014==3
gen age=2014-cfps_birth
gen age2=age^2
gen urban_hukou=qa301==3
// 回归并预测
local x "age age2 cfps_gender urban_hukou i.provcd14 i.te4"
pystacked exit_labor `x', type(classify) m(rf) cmdopt1(n_estimators(100) max_leaf_nodes(20))

// partioned_regression.do 
clear
use datasets/citydata.dta
// 设定个体、时间变量
xtset CityCode Year
// 计算增加量的对数
gen elec_new=log(v247-L.v247)
gen train_new=log(v226-L.v226)
gen loan_new=log(v170-L.v170)
gen gdp_new=log(v84-L.v84)
// 保留2010年数据
keep if Year==2010
// 回归
reg gdp_new elec_new train_new loan_new
local coef=_b[elec_new]
// 为了获得elec_new的系数，如果分步回归：
reg gdp_new train_new loan_new
predict resid_gdp_new, resid
reg elec_new train_new loan_new
predict resid_elec_new, resid
reg resid_gdp_new resid_elec_new, noconstant
local coef_partioned=_b[resid_elec_new]
di "OLS系数=`coef'，分步回归系数=`coef_partioned'"
corr resid_elec_new resid_gdp_new

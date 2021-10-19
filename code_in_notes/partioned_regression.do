// partioned_regression.do 
clear
use datasets/citydata.dta
// 设定个体、时间变量
xtset CityCode Year
// 计算增长率
gen elec_growth=log(v247)-log(L.v247)
gen train_growth=log(v226)-log(L.v226)
gen loan_growth=log(v170)-log(L.v170)
gen gdp_growth=log(v84)-log(L.v84)
// 保留2010年数据
keep if Year==2010
// 回归
reg gdp_growth elec_growth train_growth loan_growth
local coef=_b[elec_growth]
// 为了获得elec_growth的系数，如果分步回归：
reg gdp_growth train_growth loan_growth
predict resid_gdp_growth, resid
reg elec_growth train_growth loan_growth
predict resid_elec_growth, resid
reg resid_gdp_growth resid_elec_growth, noconstant
local coef_partioned=_b[resid_elec_growth]
di "OLS系数=`coef'，分步回归系数=`coef_partioned'"
corr resid_elec_growth resid_gdp_growth

// CivilConflict.do
clear
set more off
use datasets/CivilConflict
// 内生变量：GDP增长率 gdp_g；工具变量：降水增长率 GPCP_g
// 第一阶段，first stage
reg gdp_g GPCP_g i.ccode i.year i.ccode#c.year
predict gdp_g_pred
// reduced-form
reg any_prio GPCP_g i.ccode i.year i.ccode#c.year, cl(ccode)
// 错误做法：手动两阶段最小二乘
reg any_prio gdp_g_pred i.ccode i.year i.ccode#c.year,cl(ccode)
// 两阶段最小二乘，三种命令
ivregress 2sls  any_prio (gdp_g = GPCP_g) i.ccode i.year i.ccode#c.year, cl(ccode)
ivreghdfe any_prio (gdp_g = GPCP_g), absorb(i.ccode  i.year i.ccode#c.year) cl(ccode)
ivreg2 any_prio (gdp_g = GPCP_g) i.ccode i.year i.ccode#c.year, cl(ccode)

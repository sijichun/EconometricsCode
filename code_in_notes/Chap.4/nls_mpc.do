clear
set more off
use "../datasets/chfs2017_hh.dta"
// 线性回归
reg total_consump total_income
predict consump_linear
label variable consump_linear "OLS预测值"
// 非线性回归
drop if total_income==. | total_income<0
drop if total_consump==. | total_consump<0 | total_consump>5*total_income
nl (total_consump={alpha=_b[_cons]}+{beta=_b[total_income]}*total_income^{gamma=1})
predict consump_nls
label variable consump_nls "NLS预测值"
// 计算MPC
gen mpc=_b[/beta]*_b[/gamma]*total_income^(_b[/gamma]-1)
// 画图
sort total_income
twoway (scatter total_consump total_income) (line consump_linear total_income) (line consump_nls total_income)
graph export nls_mpc.pdf, replace

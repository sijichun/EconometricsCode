// file: qreg_outlier.do
clear
set more off
set obs 50
set seed 505
// generate vars
gen x=rnormal()
gen u=rnormal()
// y
gen y=1+x+u
// 产生一个outlier
sort x
replace y=30 if _n==1
// qreg
reg y x
predict p_y_reg
label variable p_y_reg "OLS"
reg y x if _n~=1
predict p_y_reg_no_outlier
label variable p_y_reg_no_outlier "OLS, 排除异常值"
qreg y x , q(0.50)
predict p_y_qreg
label variable p_y_qreg "分位数回归"
// graph
twoway (scatter y x) (line p_y_reg  x) (line p_y_reg_no_outlier  x) (line p_y_qreg x)
graph export qreg_outlier.pdf, replace

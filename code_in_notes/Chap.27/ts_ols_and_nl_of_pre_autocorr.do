// ts_ols_and_nl_of_pre_autocorr.do
clear
set more off
set obs 2000
set seed 505

gen t=_n
tsset t

gen e=rnormal()
gen u=0
replace u=0.5*L.u+e if t>1
// x为前定变量，所以可以与滞后的u相关
gen x=0
replace x=2*L.u+rnormal() if t>1
gen y=1+3*x+u

// 简单的最小二乘法是错误的
reg y x
// 更正的OLS
reg y L.y x L.x
// 非线性最小二乘
nl (y={alpha}*(1-{rho})+{rho}*L.y+{beta}*x-{rho}*{beta}*L.x) if t>1

// local_constant.do
clear
set more off
// 生成数据
set seed 19880505
set obs 300
gen x=2*runiform()
gen y=exp(sin(x^3))+rnormal()
// 局部常数回归
gen w=normalden((x-2)/0.1)
reg y [iw=w]
di _b[_cons]

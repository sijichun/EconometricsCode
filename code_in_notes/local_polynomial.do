// local_polynomial.do
clear
set more off
// 生成数据
set seed 19880505
set obs 300
gen x=2*runiform()
gen y=exp(sin(x^3))+rnormal()
// 局部线性回归
gen w=normalden((x-2)/0.1)
gen x_2=x-2
gen x_22=x_2^2
gen x_23=x_2^3
reg y x_2* [iw=w]
di _b[_cons]

// file: qreg_simulate.do
clear
set more off
set seed 505
set obs 500
// 生成x
gen x=rchi2(3)+2
// 分位数
gen q=runiform()
// 系数
gen b0=50*q^2
gen b1=5+q*10
gen b2=exp(q)
// y
gen y=b0+b1*x+b2*x^2
// 条件分位数函数
gen q25 = 50*0.25^2+(5+0.25*10)*x+exp(0.25)*x^2
gen q50 = 50*0.5^2+(5+0.5*10)*x+exp(0.5)*x^2
gen q75 = 50*0.75^2+(5+0.75*10)*x+exp(0.75)*x^2
// 画图
sort x
twoway (scatter y x) (line q25 x) (line q50 x) (line q75 x) 
graph export qreg_simulate.pdf, replace
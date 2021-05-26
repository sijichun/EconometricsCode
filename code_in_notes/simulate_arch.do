// simulate_arch.do
clear
set obs 1000
set more off
set seed 505
// 设定参数
local alpha0=1
local alpha1=0.3
local alpha2=0.3
// 开始模拟
gen t=_n
tsset t
gen z=rnormal()
gen epsilon=0 if t<=2
replace epsilon=sqrt(`alpha0'+`alpha1'*L.epsilon^2+`alpha2'*L2.epsilon^2)*z if t>2
// 画图
tsline epsilon
graph export simulate_arch_line.pdf, replace
gen epsilon2=epsilon^2
ac epsilon2
graph export simulate_arch_ac2.pdf, replace
su epsilon, de

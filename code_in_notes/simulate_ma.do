// simulate_ma.do

clear
set obs 500
set seed 505
gen t=_n
gen e=rnormal()
tsset t
gen y1=e+2*L.e+L2.e
gen y2=e-2*L.e
tsline y1
graph export simulate_ma_1.pdf, replace
ac y1
graph export simulate_ma_ac1.pdf, replace
tsline y2
graph export simulate_ma_2.pdf, replace
ac y2
graph export simulate_ma_ac2.pdf, replace
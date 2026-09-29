// simulate_ar.do

clear
set obs 500
set seed 505
gen t=_n
gen e=rnormal()
tsset t
gen y1=0
replace y1=0.9*L.y1+e if t>1
gen y2=0
replace y2=-0.9*L.y2+e if t>1
tsline y1
graph export simulate_ar_1.pdf, replace
ac y1
graph export simulate_ar_ac1.pdf, replace
tsline y2
graph export simulate_ar_2.pdf, replace
ac y2
graph export simulate_ar_ac2.pdf, replace

// simulate_causal.do

clear
set obs 100
set seed 505
gen t1=_n
gen t2=_N-_n+1
gen e=rnormal()
tsset t1
gen y=0
replace y=-1*((1/2)*L.e+(1/2^2)*L2.e+(1/2^3)*L3.e+ ///
(1/2^4)*L4.e+(1/2^5)*L5.e) if t1>5
tsset t2
gen er=y-2*L.y
tsline y
graph export simulate_causal_line.pdf, replace
tsline e er if t2<95
graph export simulate_causal_error.pdf, replace
ac y
graph export simulate_causal_ac.pdf, replace
gen y2=0
replace y2=2*L.y2+e if t2>1
tsline y2
graph export simulate_causal_line2.pdf, replace

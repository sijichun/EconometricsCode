// simulate_rw_coef.do
clear all
frame create betas beta1 beta2
set obs 5000
set seed 250211
gen t = _n
tsset t
gen e = .
forvalues i=1/1000{
	qui{
		replace e = rnormal()
		gen y = 0 if _n==1
		replace y = L.y + e if _n > 1
		reg y L.y
		local b1 = _b[L.y]
		reg y L.y t
		local b2 = _b[L.y]
		frame post betas (`b1') (`b2')
		drop y
	}
}
frame change betas
label variable beta1 "带漂移项的回归"
label variable beta2 "带漂移项与线性时间趋势的回归"
hist beta1 
graph save simulate_rw_coef1, replace
hist beta2
graph save simulate_rw_coef2, replace
graph combine simulate_rw_coef1.gph simulate_rw_coef2.gph
graph export simulate_rw_coef.pdf, replace
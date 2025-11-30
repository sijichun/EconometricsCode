// simulate_sprious.do
clear all
frame create betas t1 t2
set obs 5000
set seed 250211
gen t = _n
tsset t
gen e = .
gen v = .
forvalues i=1/1000{
	qui{
		replace e = rnormal()
		replace v = rnormal()
		gen y = 0 if _n==1
		replace y = L.y + e if _n > 1
		gen x = 0 if _n==1
		replace x = L.x + v if _n > 1
		reg y x
		local t1 = _b[x]/_se[x]
		reg y x t
		local t2 = _b[x]/_se[x]
		frame post betas (`t1') (`t2')
		drop y x
	}
}
frame change betas
label variable t1 "线性回归"
label variable t2 "带线性时间趋势的回归"
gen sig1 = abs(t1)>1.96
gen sig2 = abs(t2)>1.96
su sig*
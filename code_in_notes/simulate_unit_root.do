// simulate_unit_root.do
clear
set obs 100
set seed 250211
gen t = _n
tsset t
gen e = .
forvalues i=1/15{
	replace e = rnormal()
	gen x`i' = 0 if _n==1
	replace x`i' = L.x`i' + e if _n > 1
}
tsline x*, legend(off)
graph export simulate_unit_root.pdf, replace
ac x2
graph export simulate_unit_root_ac.pdf, replace
// simulate_rw_coef.do
clear all
frame create betas b1 b2 b3 v1 v2 v3
set obs 5000
set seed 15634145
gen t = _n
tsset t
gen e = .
forvalues i=1/1000{
	qui{
		replace e = rnormal()
		gen y = 0 if _n==1
		replace y = L.y + e if _n > 1
		reg y L.y if _n<=500, noc
		local b1 = sqrt(500)*(_b[L.y]-1)
		local v1 = 500*(_b[L.y]-1)
		reg y L.y if _n<=1500, noc
		local b2 = sqrt(1500)*(_b[L.y]-1)
		local v2 = 1500*(_b[L.y]-1)
		reg y L.y, noc
		local b3 = sqrt(5000)*(_b[L.y]-1)
		local v3 = 5000*(_b[L.y]-1)
		frame post betas (`b1') (`b2') (`b3') (`v1') (`v2') (`v3')
		drop y
	}
}
frame change betas
// twoway (hist b1, color(gs3)) (hist b2, color(gs7%60)) (hist b3, color(gs12%60)), legend(label(1 "T=500") label(2 "T=1500") label(3 "T=5000")) xline(1)
twoway (kdensity b1, lp(solid) lc(gs0)) (kdensity b2,lp(dash) lc(gs0)) (kdensity b3, lp("-..-") lc(gs0)), legend(label(1 "T=500") label(2 "T=1500") label(3 "T=5000")) xline(0)
graph export simulate_rw_coef.pdf, replace
twoway (kdensity v1, lp(solid) lc(gs0)) (kdensity v2,lp(dash) lc(gs0)) (kdensity v3, lp("-..-") lc(gs0)), legend(label(1 "T=500") label(2 "T=1500") label(3 "T=5000")) xline(0)
graph export simulate_rw_coef_T.pdf, replace
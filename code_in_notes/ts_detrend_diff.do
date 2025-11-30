// ts_detrend_diff.do
use datasets/quarterlyGDP.dta, clear
tsset time
gen ln_gdp = log(qgdp)
label variable ln_gdp "log(GDP)"
// difference
gen r1 = ln_gdp - L.ln_gdp
gen r2 = ln_gdp - L4.ln_gdp
gen r3 = r1 - L.r1
gen r4 = r2 - L.r2
// ac plot
ac r1
graph export ts_detrend_diff_ac1.pdf, replace
ac r2
graph export ts_detrend_diff_ac2.pdf, replace
ac r3
graph export ts_detrend_diff_ac3.pdf, replace
ac r4
graph export ts_detrend_diff_ac4.pdf, replace
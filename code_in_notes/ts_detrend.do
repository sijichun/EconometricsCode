// ts_detrend.do
use datasets/quarterlyGDP.dta, clear
tsset time
gen ln_gdp = log(qgdp)
label variable ln_gdp "log(GDP)"
tsline ln_gdp
graph export ts_detrend_raw.pdf, replace
gen t  = _n
gen td = (t - (_N+1)/2)/10
gen t2 = td^2
reg ln_gdp t t2
predict detrend_gdp, resid
label variable detrend_gdp "去趋势"
tsline detrend_gdp
graph export ts_detrend_graph.pdf, replace
reg ln_gdp t t2 i.quarter
predict detrend_quarter_gdp, resid
label variable detrend_quarter_gdp "去趋势及季节项"
tsline detrend_quarter_gdp
graph export ts_detrend_season.pdf, replace
ac detrend_quarter_gdp
graph export ts_detrend_ac.pdf, replace
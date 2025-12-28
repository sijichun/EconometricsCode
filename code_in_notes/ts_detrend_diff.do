// ts_detrend_diff.do
use datasets/quarterlyGDP.dta, clear
tsset time
gen t = _n
gen ln_gdp = log(qgdp)
label variable ln_gdp "log(GDP)"
// Unit root test
dfuller ln_gdp, trend regress lags(5)
// difference
gen r1 = D.ln_gdp
dfuller r1, trend regress lags(5)
dfuller r1, drift regress lags(5)
// quarter difference
gen r2 = ln_gdp - L4.ln_gdp
dfuller r2, trend regress lags(5)
dfuller r2, drift regress lags(5)
// test drift
reg r1
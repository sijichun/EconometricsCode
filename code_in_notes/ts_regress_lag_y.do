// ts_regress_lag_y.do
clear
set more off

use datasets/quarterlyGDP.dta
merge 1:1 time using datasets/quarterlyInvest.dta

tsset time
gen gdp_growth=(gdp-L4.gdp)/L4.gdp*100

reg gdp_growth einvq0105
estat bgodfrey, lags(2)
local p=r(p)[1,1]
local le=_b[einvq0105]
outreg2 using ts_reg_lay_y.tex, replace adds(Breusch-Godfrey, `p', Long-run effects, `le')
reg gdp_growth L.gdp_growth L(0/1).einvq0105
estat bgodfrey, lags(2)
local p=r(p)[1,1]
local le=(_b[einvq0105]+_b[L.einvq0105])/(1-_b[L.gdp_growth])
outreg2 using ts_reg_lay_y.tex, append adds(Breusch-Godfrey, `p', Long-run effects, `le')
reg gdp_growth L(1/2).gdp_growth L(0/1).einvq0105
estat bgodfrey, lags(2)
local p=r(p)[1,1]
local le=(_b[einvq0105]+_b[L.einvq0105])/(1-_b[L.gdp_growth]-_b[L2.gdp_growth])
outreg2 using ts_reg_lay_y.tex, append adds(Breusch-Godfrey, `p', Long-run effects, `le')
reg gdp_growth L(1/2).gdp_growth L(0/2).einvq0105
estat bgodfrey, lags(2)
local p=r(p)[1,1]
local le=(_b[einvq0105]+_b[L.einvq0105]+_b[L2.einvq0105])/(1-_b[L.gdp_growth]-_b[L2.gdp_growth])
outreg2 using ts_reg_lay_y.tex, append adds(Breusch-Godfrey, `p', Long-run effects, `le')

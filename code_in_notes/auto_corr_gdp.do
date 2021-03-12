// auto_corr_gdp.do

use datasets/quarterlyGDP.dta, clear
tsset time
gen gdp_growth=(gdp-L4.gdp)/l4.gdp
ac gdp_growth, lags(40)
graph export auto_corr_gdp.pdf, replace

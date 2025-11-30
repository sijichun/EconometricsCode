// gdp_growth.do

use datasets/quarterlyGDP.dta, clear
tsset time
gen yoy_growth=(qgdp-L4.qgdp)/L4.qgdp
label variable yoy_growth "同比增长率"
gen pop_growth=(qgdp-L.qgdp)/L.qgdp
label variable pop_growth "环比增长率"
tsline yoy_growth pop_growth
graph export gdp_growth.pdf, replace

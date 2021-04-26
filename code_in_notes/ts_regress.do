// ts_regress.do
clear
set more off

use datasets/quarterlyGDP.dta
merge 1:1 time using datasets/quarterlyInvest.dta

tsset time
gen gdp_growth=(gdp-L4.gdp)/L4.gdp*100

newey gdp_growth einvq0105, lag(4)
newey gdp_growth L(0/1).einvq0105, lag(4)
newey gdp_growth L(0/2).einvq0105, lag(4)
newey gdp_growth L(0/3).einvq0105, lag(4)
newey gdp_growth L(0/4).einvq0105, lag(4)

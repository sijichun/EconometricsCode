// quarterly_gdp.do

use datasets/quarterlyGDP.dta, clear
// 设定时间
tsset time
// 画时间序列图
tsline gdp
graph export quarter_gdp.pdf, replace

// auto_corr_stock.do

use datasets/stock_price, clear
keep if stkcd==600519
// 设定时间并计算收益率
sort date
gen t=_n
tsset t
gen rr=log(clsprc)-log(L.clsprc)
ac rr, lags(40)
graph export auto_corr_stock.pdf, replace

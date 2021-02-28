// stock_return.do

use datasets/stock_price, clear
// 整理为月度数据
gen year=year(date)
gen month=month(date)
gen day=day(date)
egen max_day=max(day), by(year month)
keep if day==max_day
gen month_date=ym(year,month)
format month_date %tm
// 设定时间并计算收益率
tsset stkcd month_date
gen simple_rr=(clsprc-L.clsprc)/L.clsprc
label variable simple_rr "简单收益率"
gen log_rr=log(clsprc)-log(L.clsprc)
label variable log_rr "对数收益率"
tsline simple_rr log_rr if stkcd == 600519, ///
	lpattern(solid dash)
graph export stock_return_rate.pdf, replace

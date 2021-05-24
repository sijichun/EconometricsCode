// stock_return_facts.do
clear all
set more off
use datasets/stock_price
// 为了避免非交易日之后的缺失值，用每只股票的行号作为时间
sort stkcd date
gen t=.
by stkcd: replace t=_n
tsset stkcd t
gen rr=log(clsprc)-log(L.clsprc)
label variable rr "对数收益率"
gen rr2=rr^2
label variable rr2 "对数收益率平方"
// 去除上市不到半年的股票
egen days=count(stkcd), by(stkcd)
drop if days<180
// 直方图
foreach c in 600519 66 600009{
	line rr date if stkcd==`c' //& date>date("2006-01-01","YMD")
	graph export stock_return_`c'.pdf, replace
	ac rr if stkcd==`c'
	graph export stock_return_ac_`c'.pdf, replace
	ac rr2 if stkcd==`c'
	graph export stock_return_ac2_`c'.pdf, replace
	qnorm rr if stkcd==`c'
	graph export stock_return_qq_`c'.pdf, replace
	hist rr if stkcd==`c', normal
	graph export stock_return_hist_`c'.pdf, replace
}
// 计算每只股票的收益率的描述性统计
statsby mean=r(mean) sd=r(sd) skew=r(skewness) kurt=r(kurtosis), by(stkcd) saving(stock_return_facts.dta, replace): su rr, de
// 打开stock_return_facts.dta
frame create descriptive
frame change descriptive
use stock_return_facts.dta
su mean-kurt, de
rm stock_return_facts.dta

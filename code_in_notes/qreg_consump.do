// file: qreg_consump.do
use datasets/chfs2017_hh.dta, clear
drop if total_income < 0
drop if max(censor_total_consump, censor_total_income)
gen log_total_consump = log(total_consump+1)
gen log_total_income = log(total_income+1)
gen log_total_income2 = log_total_income^2
// 一次函数
qreg log_total_consump log_total_income
predict pred_consump_50
label variable pred_consump_50 "50%分位数"
qreg log_total_consump log_total_income, q(0.25)
predict pred_consump_25
label variable pred_consump_25 "25%分位数"
qreg log_total_consump log_total_income, q(0.75)
predict pred_consump_75
label variable pred_consump_75 "75%分位数"
sort total_income
twoway (scatter log_total_consump log_total_income) (line pred_consump_50 log_total_income) (line pred_consump_25 log_total_income) (line pred_consump_75 log_total_income)
graph export qreg_one_variate1.pdf, replace
// 二次函数
qreg log_total_consump log_total_income*
predict pred_consump2_50
label variable pred_consump_50 "50%分位数"
qreg log_total_consump log_total_income*, q(0.25)
predict pred_consump2_25
label variable pred_consump_25 "25%分位数"
qreg log_total_consump log_total_income*, q(0.75)
predict pred_consump2_75
label variable pred_consump_75 "75%分位数"
sort total_income
twoway (scatter log_total_consump log_total_income) (line pred_consump2_50 log_total_income) (line pred_consump2_25 log_total_income) (line pred_consump2_75 log_total_income)
graph export qreg_one_variate2.pdf, replace
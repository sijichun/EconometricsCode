// file: reg_one_variate.do
use datasets/chfs2017_hh.dta, clear
drop if total_income < 0
drop if max(censor_total_consump, censor_total_income)
reg total_consump total_income
outreg2 using reg_one_variate.tex, replace
predict pred_consump
label variable pred_consump "预测的消费"
sort total_income
twoway (scatter total_consump total_income) (line pred_consump total_income)
graph export reg_one_variate.pdf, replace

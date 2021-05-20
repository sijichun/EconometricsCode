// arma_model_selection.do

cap program drop display_ic
program define display_ic, rclass
	syntax , p(integer) q(integer) t(integer) ll(real)
	tempname aic bic aicc
	local `aic'=-2*`ll'+2*(`p'+`q'+1)
	local `bic'=-2*`ll'+sqrt(`t')*(`p'+`q'+1)
	local `aicc'=-2*`ll'+2*(`p'+`q'+1)*`t'/(`t'-`p'-`q'-2)
	di "p=`p', q=`q', AIC=``aic'', BIC=``bic'', AICC=``aicc''"
	return scalar aic=``aic''
	return scalar bic=``bic''
	return scalar aicc=``aicc''
end

clear
use datasets/monthly_PMI.dta
tsset time

line PMI time
graph export arma_pmi_line.pdf, replace
// 开始挑选
local T=_N
local minp_cc=0
local minq_cc=0
local minaicc=.
local minp_b=0
local minq_b=0
local minbic=.
forvalues p=0/5{
	forvalues q=0/13{
		if `p'==0 & `q'==0{
			continue
		}
		if `p'==0{
			qui: arima PMI, ma(1/`q')
		}
		else if `q'==0{
			qui: arima PMI, ar(1/`p')
		}
		local ll=e(ll)
		display_ic, p(`p') q(`q') t(`T') ll(`ll')
		if r(aicc)<`minaicc' {
			local minp_cc=`p'
			local minq_cc=`q'
			local minaicc=r(aicc)
		}
		if r(bic)<`minbic' {
			local minp_b=`p'
			local minq_b=`q'
			local minbic=r(bic)
		}
	}
}
di "AICC minimized at p=`minp_cc', q=`minq_cc'"
di "BIC minimized at p=`minp_b', q=`minq_b'"
// 根据筛选结果，AR(1)模型
arima PMI, ar(1)
local T=_N
local p=1
local q=0
local ll=e(ll)
display_ic, p(`p') q(`q') t(`T') ll(`ll')
predict resid, residuals
line resid time
graph export arma_pmi_resid_line.pdf, replace
ac resid
graph export arma_pmi_resid_ac.pdf, replace
// 尝试其他模型
// AR(1,12)
arima PMI, ar(1 12)
local T=_N
local p=2
local q=0
local ll=e(ll)
display_ic, p(`p') q(`q') t(`T') ll(`ll')
predict resid1, residuals
line resid1 time
graph export arma_pmi_resid_line1.pdf, replace
ac resid1
graph export arma_pmi_resid_ac1.pdf, replace
// ARMA
arima PMI, ar(1) ma(12)
local T=_N
local p=1
local q=1
local ll=e(ll)
display_ic, p(`p') q(`q') t(`T') ll(`ll')
predict resid2, residuals
line resid2 time
graph export arma_pmi_resid_line2.pdf, replace
ac resid2
graph export arma_pmi_resid_ac2.pdf, replace
// 加入月份虚拟变量
gen pmonth=mod(time, 12)
tab pmonth, gen(month)
arima PMI month1-month11, ar(1)
local T=_N
local p=12
local q=0
local ll=e(ll)
display_ic, p(`p') q(`q') t(`T') ll(`ll')
predict resid3, residuals
line resid3 time
graph export arma_pmi_resid_line3.pdf, replace
ac resid3
graph export arma_pmi_resid_ac3.pdf, replace

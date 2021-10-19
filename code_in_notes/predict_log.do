// predict_log.do
use datasets/quarterlyGDP.dta, clear
label variable gdp "真实GDP"
gen log_gdp=log(gdp)
sort time
tsset time
gen t=_n
gen t2=t^2
gen t3=t^3
gen t4=t^4
reg log_gdp t-t4 
local sigma=e(rmse)
predict predicted_log_gdp
gen predicted_gdp_unadjust=exp(predicted_log_gdp)
label variable predicted_gdp_unadjust "未调整"
gen predicted_gdp_adjust=exp(predicted_log_gdp+(`sigma'^2)/2)
label variable predicted_gdp_adjust "调整后"
gen error_unadjust=(gdp-predicted_gdp_unadjust)
gen error_adjust=(gdp-predicted_gdp_adjust)
su error*
tsline gdp predicted_gdp_unadjust predicted_gdp_adjust, legend(pos(11) ring(0))
graph export predict_log.pdf, replace

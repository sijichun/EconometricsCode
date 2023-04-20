// ntv_double_selec.do
clear
set more off
use datasets/NTV_Aggregate_Data_reshaped.dta
tsset tik_id year
// 社会经济变量以及人口、工资的多项式
forvalues i=1/5{
    gen lag_log_pop_`i'=L.logpop^`i'
    gen lag_log_wage_`i'=L.log_wage^`i'
}
gen lag_nurses=L.nurses
gen lag_doctors_pc=L.doctors_pc
local E_controls "lag_log_pop_* lag_log_wage_* lag_nurses lag_doctors_pc"
reghdfe Votes_SPS_ Watch_probit `E_controls' if year==1999, a(region) cluster(region)
dsregress Votes_SPS_ Watch_probit if year==1999, controls((i.region) `E_controls') cluster(region) selec(cv)


// partioned_regression.do 
clear all
use datasets/chfs2017_hh.dta
frame create master
frame master: use datasets/chfs2017_master.dta
frame master: keep hhid rural
frame master: duplicates drop hhid rural, force
frlink 1:1 hhid, frame(master)
frget rural, from(master)
// 计算对数
gen log_comsump = log(total_consump)
gen log_income = log(total_income)
gen log_asset = log(b2003a)
// 回归
reg log_comsump log_income log_asset rural
local coef=_b[log_income]
// 为了获得log_income的系数，如果分步回归：
reg log_income log_asset rural
predict resid_log_income, resid
reg log_comsump log_asset rural
predict resid_log_comsump, resid
reg resid_log_comsump resid_log_income, noconstant
local coef_partioned=_b[resid_log_income]
di "OLS系数=`coef'，分步回归系数=`coef_partioned'"
corr log_comsump log_income // 相关系数
corr resid_log_comsump resid_log_income // 偏相关系数

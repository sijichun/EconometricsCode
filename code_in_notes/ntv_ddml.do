// ntv_ddml.do
clear
set more off
use datasets/NTV_Aggregate_Data_reshaped.dta
tsset tik_id year
// 控制变量
gen lag_nurses=L.nurses
gen lag_doctors_pc=L.doctors_pc
gen lag_pop=L.logpop
gen lag_wage=L.log_wage
local controls "lag_doctors_pc lag_nurses lag_pop lag_wage i.region"
// DDML
ddml init partial, kfolds(10) // 初始化模型，10折的交叉拟合
ddml E[Y|X]: pystacked Votes_SPS_  `controls', type(regress) method(rf) cmdopt1(n_estimators(200))
ddml E[D|X]: pystacked Watch_probit `controls', type(regress) method(rf) cmdopt1(n_estimators(200))
ddml crossfit
ddml estimate,  cluster(region) // 等价于 reg Y1_pystacked_1 D1_pystacked_1,  cluster(region)
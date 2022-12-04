// linear_panel_fe.do
clear
set more off
use datasets/NTV_Aggregate_Data_reshaped.dta
xtset tik_id year
// 1995年NTV并没有成立
gen Watch_probit_p=0
replace Watch_probit_p=Watch_probit if year==1999
// LSDV回归
reghdfe Votes_SPS_ Watch_probit_p i.year if year!=2003, absorb(i.tik_id) cluster(region)
// xtreg 回归
xtreg Votes_SPS_ Watch_probit_p i.year if year!=2003, fe cluster(region)
// 使用一阶差分
gen delta_Votes_SPS_=Votes_SPS_-L4.Votes_SPS_
gen delta_Watch_probit_p=Watch_probit_p-L4.Watch_probit_p
reg delta_Votes_SPS_ delta_Watch_probit_p i.year if year!=2003, cluster(region)

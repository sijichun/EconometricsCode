// jia2024.do
clear
use datasets/Jia_Wang_Si2024.dta
// 取对数
gen lnPEE=log(PEE)
// 去平均
egen m_lnPEE=mean(lnPEE)
gen dm_lnPEE=lnPEE-m_lnPEE
// 交乘项
gen hukou_dm_lnPEE=hukou*dm_lnPEE
// 回归
local controls "gender nation married parents_edu"
reg lnIncome hukou_dm_lnPEE hukou lnPEE `controls'
outreg2 using jia2024.tex, replace addt(出生年份固定效应, 否, 城市固定效应, 否, 调查年份固定效应, 否, 城市×出生年份固定效应, 否)
reghdfe lnIncome hukou_dm_lnPEE hukou lnPEE `controls', absorb(birthyear)
outreg2 using jia2024.tex, append addt(出生年份固定效应, 是, 城市固定效应, 否, 调查年份固定效应, 否, 城市×出生年份固定效应, 否)
reghdfe lnIncome hukou_dm_lnPEE hukou lnPEE `controls', absorb(birthyear citycode year)
outreg2 using jia2024.tex, append addt(出生年份固定效应, 是, 城市固定效应, 是, 调查年份固定效应, 是, 城市×出生年份固定效应, 否)
reghdfe lnIncome hukou_dm_lnPEE hukou lnPEE `controls', absorb(i.birthyear#i.citycode year)
outreg2 using jia2024.tex, append addt(出生年份固定效应, --, 城市固定效应, --, 调查年份固定效应, 是, 城市×出生年份固定效应, 是)

clear
set more off
use ../datasets/chfs2017_ind.dta
// 清洗并产生数据
// a3143=3 为从未找工作，即退出劳动力市场，需删掉
drop if a3143==3
gen unemployed = a3101==2 & a3143!=3
gen age=2017-a2005
gen age2=age^2
rename a2012 edu_level
gen sex=2-a2003
drop if a2022==7777
rename a2022 hukou
// 回归并预测
local x "age age2 sex i.hukou i.edu_level"
logit unemployed `x'
predict p_unemployed // 预测概率
// 使用预测值计算R2
corr unemployed p_unemployed
local R2_corr2=r(rho)^2
// 计算cutoff=0.5时的查准率、查全率
gen predict_unemployed=p_unemployed>0.5
gen TP=(unemployed==1 & predict_unemployed==1)
gen FP=(unemployed==0 & predict_unemployed==1)
gen FN=(unemployed==1 & predict_unemployed==0)
gen TN=(unemployed==0 & predict_unemployed==0)
foreach v of varlist TP FP FN TN{
	quietly: su `v'
	local `v' = r(mean)
}
local R2=e(r2_p)
local precision=`TP'/(`TP'+`FP')
local recall=`TP'/(`TP'+`FN')
local accuracy=(`TP'+`TN')/(`TP'+`TN'+`FP'+`FN')
local F1=(2*`precision'*`recall')/(`precision'+`recall')
di "相关系数平方计算R2=`R2_corr2'"
di "Pseudo-R2=`R2'"
di "查准率=`precision'"
di "查全率=`recall'"
di "精度=`accuracy'"
di "F1=`F1'"
// 画出ROC曲线
lroc
graph export roc.pdf, replace
// 画出sensitivity 以及specificity
lsens
graph export sens_speci.pdf, replace

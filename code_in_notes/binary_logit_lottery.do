// binary_logit_lottery.do
clear
set more off
use datasets/lottery_data.dta

// 计算lottery的期望与方差
gen eiL = P0left*prize0  + P1left*prize1  + P2left*prize2  + P3left*prize3
gen eiR = P0right*prize0 + P1right*prize1 + P2right*prize2 + P3right*prize3
gen ei2L = P0left*prize0^2  + P1left*prize1^2  + P2left*prize2^2  + P3left*prize3^2
gen ei2R = P0right*prize0^2 + P1right*prize1^2 + P2right*prize2^2 + P3right*prize3^2
gen viL = ei2L - eiL^2
gen viR = ei2R - eiR^2
gen deltaI = eiR - eiL
gen deltaV = viR - viL
// 估计
// 简单模型，只加入收益的期望与方差
logit Choices deltaI deltaV, cluster(id)
// 分别加入左、右两遍的收益与方差
logit Choices eiL eiR viL viR, cluster(id)
test eiL+eiR=0
test viL+viR=0
// 加入个体层面变量
logit Choices deltaI deltaV Female Black Hispanic Age Business GPAlow, cluster(id)
margins, dydx(*)

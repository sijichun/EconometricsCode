// binary_logit_mle.do
clear
set more off
// 定义对数似然函数
cap program drop binarylogitobj 
program binarylogitobj 
	args todo b lnfj g1
	tempvar theta Lambda
	mleval `theta' = `b', eq(1)
	quietly{
		gen `Lambda' = 1/(1+exp(-1*`theta'))
		replace `lnfj' = $ML_y1 * log(`Lambda') + (1-$ML_y1 ) * log(1-`Lambda')
		if (`todo' == 0) exit //如果不需要计算导数，退出
		replace `g1' = $ML_y1 * (1-`Lambda') - (1-$ML_y1 ) * `Lambda' //导数
	}
end
do binary_logit_lottery.do
// 定义极大似然问题
ml model lf0 binarylogitobj (Choices = deltaI deltaV), cluster(id) tech(bfgs)
// 寻找初始点，可选
ml search
// 最大化
ml maximize
// fisher_exact_t.do
clear all
use datasets/Lalonde_nsw/nsw.dta
set seed 1900
// 计算样本量
su treat
local N=r(N)
local Nt=r(sum)
// 统计量的选择
local y "re78"
if "`y'"=="re78rank"{
	gen_rank re78, gen(re78rank)
	replace re78rank=re78rank-(`N'+1)/2
}
else if "`y'"=="log_re78"{
	gen log_re78=log(1+re78)
}
else if "`y'"=="re75rank"{
	gen_rank re75, gen(re75rank)
	replace re75rank=re75rank-(`N'+1)/2
}
else if "`y'"=="log_re75"{
	gen log_re78=log(1+re75)
}
// 计算两组均值差的绝对值
qui: reg `y' treat
local test_stat=_b[treat]

// 使用Frame存储重新分配的检验统计量
frame create reassign_stats stats
local M=10000
gen reassign_treat=.
gen reassign_rnum=.
forvalues i=1/`M'{
	quietly{
		replace reassign_rnum=runiform()
		sort reassign_rnum
		replace reassign_treat=_n<=`Nt'
		reg `y' reassign_treat
		frame post reassign_stats (_b[reassign_treat])
	}
}
// 计算p并画图
frame change reassign_stats
gen d_extreme=abs(stats)>abs(`test_stat')
sum d_extreme
di "test stats=" `test_stat' _skip  ", Fisher's exact p=" r(mean)

hist stats, xline(`test_stat')
graph export fisher_exact_t.pdf, replace

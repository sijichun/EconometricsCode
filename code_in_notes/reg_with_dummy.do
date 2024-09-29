// file: reg_with_dummy.do
use datasets/chfs2017_ind.dta, clear
gen p_income = a3109*12
gen gender = 2-a2003 // a2003定义1为男性，2为女性
bysort gender: outreg2 using reg_with_dummy_su.tex, replace sum(log) eqkeep(N mean) keep(p_income)
reg p_income gender
outreg2 using reg_with_dummy.tex, replace

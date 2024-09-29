// file: reg_with_dummies.do
use datasets/chfs2017_ind.dta, clear
gen p_income = a3109*12
tab a2012, gen(edu)
reg p_income edu*
outreg2 using reg_with_dummies.tex, replace
reg p_income edu*, noconstant
outreg2 using reg_with_dummies.tex, append
reg p_income edu2-edu9
outreg2 using reg_with_dummies.tex, append

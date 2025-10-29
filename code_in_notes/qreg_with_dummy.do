// file: qreg_with_dummy.do
use datasets/chfs2017_ind.dta, clear
gen p_income = a3109*12
gen gender = 2-a2003 // a2003定义1为男性，2为女性
drop if gender == .
bysort gender: su p_income, de
qreg p_income gender, q(0.25)
qreg p_income gender, q(0.5)
qreg p_income gender, q(0.75)
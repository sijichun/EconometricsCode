// ohie_qje_test_one.do
clear
set more off
use datasets/OHIE_QJE.dta

// 需要进行比较的特征
local ys "birthyear_list female_list english_list self_list first_day_list have_phone_list"
// 挨个比较
local repapp "replace"
foreach v of varlist `ys'{
	reg `v' treatment [iw=weight_12m ], robust
	outreg2 using ohie_qje_test_one.tex, `repapp'
	local repapp "append"
	test treatment
}

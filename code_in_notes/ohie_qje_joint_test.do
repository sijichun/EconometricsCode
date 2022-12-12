// ohie_qje_joint_test.do
clear frames
set more off
use datasets/OHIE_QJE.dta

// 比较随机化之前的特征
local lottery_list "birthyear_list female_list english_list self_list first_day_list have_phone_list pobox_list zip_msa"
// 合在一起比较
frames put `lottery_list' treatment weight_12m household_id numhh_list, into(joint_compare)
frame change joint_compare
local i=0
foreach v of varlist `lottery_list'{
	local i=`i'+1
	rename `v' outcome`i'
}
gen id=_n
reshape long outcome, i(id) j(varid)
local test_coefs ""
forvalues j=1/`i'{
	local test_coefs "`test_coefs' 1.treatment#`j'.varid"
}
di "`test_coefs'"
reg outcome i.varid i.treatment#i.varid i.numhh_list#i.varid , cl(household_id)
test `test_coefs'
frame change default

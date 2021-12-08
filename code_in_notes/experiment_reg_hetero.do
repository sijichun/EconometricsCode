// experiment_reg_hetero.do
clear all
use datasets/Lalonde_nsw/nsw.dta

// 去平均
foreach v of varlist age-re75{
    egen mean_`v'=mean(`v')
	gen demean_`v'=`v'-mean_`v'
	gen treat_demean_`v'=treat*demean_`v'
}

reg re78 treat demean_* treat_demean_*, r
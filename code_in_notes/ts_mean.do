// ts_mean.do
set seed 505
clear
cap program drop tsmean
program define tsmean, rclass
	syntax [, obs(integer 300) beta(real 0.8) mu(real 0)]
	drop _all
	set obs `obs'
	tempvar y t
	gen `t'=_n
	tsset `t'
	gen `y'=`mu'
	replace `y'=`beta'*L.`y'+rnormal() if `t'>1
	quietly: reg `y'
	return scalar sample_mean=_b[_cons]
	return scalar unadjusted_se=_se[_cons]
	quietly: newey `y', lag(20)
	return scalar adjusted_se=_se[_cons]
end

simulate m=r(sample_mean) se=r(unadjusted_se) ase=r(adjusted_se),/*
	*/ reps(1000): tsmean
su

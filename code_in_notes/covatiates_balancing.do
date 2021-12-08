// cavatiates_balancing.do
clear all
use datasets/Lalonde_nsw/nsw.dta

foreach v of varlist age-re75{
	qui{
		ttest `v', by(treat)
		local mean_t=r(mu_2)
		local mean_c=r(mu_1)
		local diff=`mean_t'-`mean_c'
		local se=r(se)
		fishers_p `v' treat
		local exact_p=r(p)
	}
	di "`v'" _skip `mean_t' _skip `mean_c' _skip `diff' _skip `se' _skip `exact_p'
}
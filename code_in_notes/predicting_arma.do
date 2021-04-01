clear
set obs 50
set seed 19880505
gen t=_n
tsset t
scalar sept=28
gen e=rnormal() if t<sept
gen y=6 if t<sept
replace y=3+0.5*L.y+e+0.8*L.e if t<sept & t>1
replace y=3+0.5*L.y+0.8*L.e if t==sept
replace y=3+0.5*L.y if t>sept
gen lb=.
gen ub=.
gen variance=.
replace variance=0 if t==sept-1
replace variance=1 if t==sept
local sept1=sept+1
forvalues i= `sept1'/50{
	replace variance=L.variance+1.3^2*0.25^(`i'-sept-1) if t==`i'
}
replace ub=y+1.96*sqrt(variance) if t>=sept-1
replace lb=y-1.96*sqrt(variance) if t>=sept-1
twoway (tsline y if t<=sept-1) (tsline y if t>=sept-1, lpattern(-.)) (tsline lb if t>=sept-1, lpattern(dash) lc(orange)) (tsline ub if t>=sept-1, lpattern(dash) lc(orange)), legend(off)
graph export "predicting_arma.pdf", replace

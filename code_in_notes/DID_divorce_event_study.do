clear
set more off
use "datasets/Divorce-Wolfers-AER.dta"
** state dummies
egen state=group(st)
** panel setting
keep if year>1967 & year<1989 
xtset state year
** TWFE setting
reghdfe div_rate unilateral divx* [w=stpop], absorb(i.state i.year) cl(state)
** prepare relative time
gen never_treated = lfdivlaw>1989
gen always_treated= lfdivlaw<=1967
gen delta_year=year-lfdivlaw
gen L12unilateral = delta_year<=-12
forvalues t=11(-1)2{
    gen L`t'unilateral = delta_year==-`t'
}
gen unilateral0  = delta_year==0
forvalues t=1/19{
    gen F`t'unilateral = delta_year==`t'
}
gen F20unilateral = delta_year>=20
** compute weights
gen cohort=lfdivlaw
replace cohort =. if never_treated
eventstudyweights L12unilateral - F20unilateral [w=stpop], absorb(i.state i.year) cohort(cohort) rel_time(delta_year) covariates(divx*) saveweights("weights.xlsx")
** estimate
eventstudyinteract div_rate L12unilateral - F20unilateral [w=stpop], absorb(i.state i.year) cohort(cohort) covariates(divx*) control_cohort(never_treated)
* plot
matrix C = e(b_iw)
mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
matrix C = C \ A
coefplot matrix(C[1]), se(C[2])vert xline(12)
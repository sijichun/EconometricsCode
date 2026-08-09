// conditional_logit_simu.do
clear all
set more off
set seed 42
global hetero "no"
// simulate individuals
local N = 1000
set obs `N'
gen id = _n
gen income = exp(rnormal(7,3))
gen sex = runiform()<0.5
gen age = ceil(runiform()*40+20)
// alternatives
gen p1 = 14000
gen p2 = 10000
gen p3 = 13000
gen p4 = 9000

gen storage1 = 1000
gen storage2 = 500
gen storage3 = 2000
gen storage4 = 500

gen stores1 = ceil(runiform()*20+1)
gen stores2 = stores1
gen stores3 = ceil(runiform()*20+1)
gen stores4 = stores3

// reshape
reshape long p storage stores, i(id) j(alternative)

// gen utility
if ("$hetero" == "no"){
	gen V = 0.2*log(storage) - 0.4*log(p) + 0.5*log(stores) -35
}
else if ("$hetero" == "yes"){
	gen V = 0.2*log(storage) - 0.4*exp(-income/10000)*log(p) + 0.5*log(stores) -35 
}
replace V = V + 0.01*(log(income) - sex + (age-30)) if alternative == 1
replace V = V + 0.01*(1.1*log(income) - 0.5*sex + 0.8*(age-30)) if alternative == 2
replace V = V + 0.01*(0.9*log(income) + 0.5*sex - 0.2*(age-30)) if alternative == 3
replace V = V + 0.01*(0.8*log(income) - sex + (age-30)) if alternative == 4
gen epsilon = -log(-log(runiform())) //type-I extreme value distribution
gen U = V + epsilon
// gen choice
egen maxU = max(U), by(id)
gen choice = U==maxU
tab choice alternative


// estimate

gen log_income = log(income)
gen log_storage = log(storage)
gen log_p = log(p)
gen log_stores = log(stores)
gen log_p_log_income = log_p - log_income

cmset id alternative

// no heterogeneity
cmclogit choice log_storage log_p log_stores, casevars(log_income sex age) vce(cluster id) noconstant
// with heterogeneity
cmclogit choice log_storage log_p_log_income log_stores, casevars(log_income sex age) vce(cluster id) noconstant
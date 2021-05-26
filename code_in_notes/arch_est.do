// arch_est.do
clear all
set more off
use datasets/stock_price
keep if stkcd==600009
sort date
gen t=_n
tsset stkcd t
gen rr=log(clsprc)-log(L.clsprc)
label variable rr "对数收益率"
line rr date
graph export arch_line.pdf, replace
// ARCH(5)
arch rr, arch(1/5)
predict sigma2_arch, variance
gen sigma_arch=sqrt(sigma2_arch)
label variable sigma_arch "ARCH(5)"
// GARCH(1,1)
arch rr, arch(1) garch(1)
predict sigma2_garch, variance
gen sigma_garch=sqrt(sigma2_garch)
label variable sigma_garch "GARCH(1,1)"
// EGARCH(1,1)
arch rr, earch(1) egarch(1)
predict sigma2_egarch, variance
gen sigma_egarch=sqrt(sigma2_egarch)
label variable sigma_egarch "EGARCH(1,1)"
// GJR threshold arch
arch rr, arch(1) garch(1) tarch(1)
predict sigma2_tgarch, variance
gen sigma_tgarch=sqrt(sigma2_tgarch)
label variable sigma_tgarch "GJR"
// 画图
tsset date
tsline sigma_*, legend(ring(0) position(11) bmargin(large))
graph export arch_sigma.pdf, replace
// GARCH-M
arch rr, arch(1) garch(1) archm

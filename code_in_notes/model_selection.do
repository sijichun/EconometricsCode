// file: model_selection.do
clear
set obs 50
set seed 1000
gen x=runiform()*3
gen y=exp(x)+rnormal()*2
local control ""
scalar K=1
forvalues i=1/10{
    gen x`i'=x^`i'
    local control "`control' x`i'"
    scalar K=K+1
    quietly: reg y `control'
    scalar r2=e(r2)
    scalar r2a=e(r2_a)
    scalar aic=-2*e(ll)+2*K
    scalar bic=-2*e(ll)+log(e(N))*K
	scalar aicc=aic+(2*K*(K+1))/(e(N)-K-1)
    display `i' _skip r2 _skip r2a _skip aic _skip bic _skip aicc
}

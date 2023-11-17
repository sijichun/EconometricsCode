// quadratic.do
clear
set obs 600
set seed 505
gen x=rchi2(1)*2
su x
gen y_true=2-exp(-0.5*x)
gen y=y_true+rnormal()*2
gen x2=x^2
reg y x x2
local sym = _b[x]/(-2*_b[x2])
predict y_hat
sort x
twoway (scatter y x) (line y_hat x, xline(`sym')) (line y_true x)
graph export quadratic.pdf, replace

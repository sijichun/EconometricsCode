// log_of_gravity.do
use datasets/log_of_gravity, clear
local explan_var "lypex lypim lyex lyim ldist border comlang colony landl_ex landl_im lremot_ex lremot_im comfrt_wto open_wto"
// log(1+y)
gen log_trade = log(1+trade)
reg log_trade `explan_var'
// log(y)
reg ltrade `explan_var'
// nonlinear least squares
nl (trade = exp({xb: `explan_var'} + {_cons}))
// ppml
poisson trade `explan_var'
// negative binomial pml
nbreg  trade `explan_var'
// gamma pml
glm trade `explan_var', family(gamma) link(log)
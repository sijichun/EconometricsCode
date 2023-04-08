clear
set more off
use "datasets/hcw.dta"
tsset time
// Lasso
lasso linear HongKong Australia-Thailand if _n<=18, rseed(5) sel(cv)
coefpath
graph export beta_lasso_plot.pdf, replace
cvplot
graph export cv_lasso_plot.pdf, replace
etable
lassocoef
lassoinfo
// ridge
elasticnet linear HongKong Australia-Thailand if _n<=18,  rseed(5) sel(cv) alpha(0)
coefpath
graph export beta_ridge_plot.pdf, replace
cvplot
graph export cv_ridge_plot.pdf, replace
etable
lassocoef
lassoinfo
// adpative lasso
lasso linear HongKong Australia-Thailand if _n<=18, rseed(5) sel(cv)
predict HongKong_lasso
predict HongKong_lasso_post, post
label variable HongKong_lasso "Lasso"
label variable HongKong_lasso_post "PostLasso"
lasso linear HongKong Australia-Thailand if _n<=18, rseed(5) sel(adaptive)
lassocoef
predict HongKong_adalasso
label variable HongKong_adalasso "Adaptive Lasso"
twoway (tsline HongKong, lcolor(black)) (tsline HongKong_lasso, lcolor(black) lpattern(dash)) (tsline HongKong_lasso_post, lcolor(black) lpattern(dot)) (tsline HongKong_adalasso, lcolor(black) lpattern(dash_dot)) if _n<=18
graph export lasso_prediction.pdf , replace
lasso linear HongKong Australia-Thailand if _n<=18, rseed(5) sel(cv)
local post_vars=e(post_sel_vars)
reg `post_vars'
// ddml_nsw.do
clear
set more off
use datasets/Lalonde_nsw/nsw.dta
// append using datasets/Lalonde_nsw/cps_controls.dta
local controls "age-nodegree"
ddml init interactive, kfolds(10)
ddml E[Y|X,D]: pystacked re78  `controls', type(regress) method(rf) cmdopt1(n_estimators(200))
ddml E[D|X]: pystacked treat  `controls', type(class) method(rf) cmdopt1(n_estimators(200))
ddml crossfit
ddml estimate, robust

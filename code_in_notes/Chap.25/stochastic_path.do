clear
set more off
set obs 30
set seed 505
gen t=_n
tsset t
forvalues i=1/10{
	gen x`i'=rnormal()
	replace x`i'=x`i'+L.x`i' if _n>1
}
twoway (tsline x1, tline(9.8 10.2) ) (tsline x2-x10, lpattern(dot dot dot dot dot dot dot dot dot)) (scatter x1 t if t==10, msize(0.8) mc(red) ) (scatter x2 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow)) (scatter x3 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x4 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x5 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x6 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x7 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x8 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x9 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow))(scatter x10 t if t==10, msize(0.5) mc(purple) msymbol(circle_hollow)), legend(off)
graph export stochastic_path.pdf, replace

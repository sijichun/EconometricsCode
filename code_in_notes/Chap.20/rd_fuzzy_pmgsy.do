// rd_fuzzy_pmgsy.do
clear
set more off
use datasets/pmgsy_working_aer_mainsample.dta

// triangle kernel and bandwidth
local bw = 80
gen kw = max(`bw'-abs(v_pop),0)

// polynomials left and right
gen l1 = abs(v_pop) if v_pop<0
replace l1 = 0 if v_pop>=0
gen r1 = abs(v_pop) if v_pop>=0
replace r1 =0 if v_pop<0
gen l2 = l1^2
gen r2 = r1^2

// control variables
local controls  primary_school med_center elect tdist irr_share ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share bpl_inc_250plus 
local fe vhg_dist_id
local clse dist_id

// manipulation test
rddensity v_pop, plot hist_n(10)

// first-stage
reg r2012 t l1 r1 [aw = kw], cluster(`clse')
reghdfe r2012 t l1 r1 `controls' [aw = kw], a(`fe') cluster(`clse')
reghdfe r2012 t l1 l2 r1 r2 `controls' [aw = kw], a(`fe') cluster(`clse')
rdrobust r2012 v_pop, c(0) covs(`controls')
rdrobust r2012 v_pop, c(0) p(2) covs(`controls')

// graph
sort v_pop
rdplot r2012 v_pop, p(1) h(`bw') kernel(tri)

// ITT
reg transport_index_andrsn t l1 r1 [aw = kw], cluster(`clse')
reghdfe transport_index_andrsn t l1 r1 `controls' [aw = kw], a(`fe') cluster(`clse')
reghdfe transport_index_andrsn t l1 l2 r1 r2 `controls' [aw = kw], a(`fe') cluster(`clse')
rdrobust transport_index_andrsn v_pop, c(0) covs(`controls')
rdrobust transport_index_andrsn v_pop, c(0) p(2) covs(`controls')

// graph
sort v_pop
rdplot transport_index_andrsn v_pop, p(1) h(`bw') kernel(tri)

// Fuzzy or IV
ivregress 2sls transport_index_andrsn (r2012=t) l1 r1 [aw = kw], cluster(`clse')
ivreghdfe transport_index_andrsn (r2012=t) l1 r1 `controls' [aw = kw], a(`fe') cluster(`clse')
ivreghdfe transport_index_andrsn (r2012=t) l1 l2 r1 r2 `controls' [aw = kw], a(`fe') cluster(`clse')
rdrobust transport_index_andrsn v_pop, c(0) covs(`controls') fuzzy(r2012)
rdrobust transport_index_andrsn v_pop, c(0) p(2) covs(`controls') fuzzy(r2012)


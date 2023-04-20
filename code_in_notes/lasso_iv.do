// lasso_iv.do
clear all
set maxvar 100000
use datasets/chfs_ind.dta,clear
gen exper=a3007
gen exper2=exper^2
gen edu=a2012
gen ln_income=log(1+labor_inc)
gen quarter=floor(a2006/4)
gen birth_year=a2005
poivregress ln_income (edu=i.quarter#i.province#i.birth_year), controls(exper*) sel(cv) cluster(province)

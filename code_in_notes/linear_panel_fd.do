// linear_panel_fd.do
clear
set more off
use datasets/voting_cnty_clean.dta

xtset cnty90 year

gen numdailies_l1=L4.numdailies
gen prestout_l1=L4.prestout
gen changedailies=numdailies-numdailies_l1
gen changeprestout=prestout-prestout_l1
// 一阶差分
reghdfe changeprestout changedailies if mainsample, absorb(i.st#i.year) cluster(cnty90) resid
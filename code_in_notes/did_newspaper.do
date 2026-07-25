// did_newspaper.do
clear
use datasets/Angelucci_Cage_AEJMicro_dataset.dta, clear

// year setting
drop if year<1960 | year>1974
gen after = year>1967
gen treat_post = national*after

// simple DID
reghdfe ln_nb_journ treat_post, a(year id_news) cluster(id_news)

// didreg
xtdidregress (ln_nb_journ) (treat_post),  g(id_news) t(year) vce(cl id_news)

// event study
gen p=1
label var p "1960"
reghdfe ln_nb_journ p ib1960.year##ib0.national, a(year id_news) cluster(id_news)
coefplot, omitted vertical label keep(p *.year#1.national) yline(0) levels(90) xline(7.5,lcolor(black) lpattern(dash)) rename((\d+).year#1.national=\1, regex)
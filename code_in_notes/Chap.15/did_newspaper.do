// did_newspaper.do
clear
use ../datasets/Angelucci_Cage_AEJMicro_dataset.dta, clear

// year setting
drop if year<1960 | year>1974
gen after = year>1967
gen treat_post = national*after

// event study (price data is not available in 1960 and 1961)
gen p=1
label var p "1962"
reghdfe ln_ads_p4_cst p ib1962.year##ib0.national if year>=1962, a(year id_news) cluster(id_news)
coefplot, omitted vertical label keep(p *.year#1.national) yline(0) levels(90) xline(5.5,lcolor(black) lpattern(dash)) rename((\d+).year#1.national=\1, regex)
graph export newspaper_common_trend.pdf, replace
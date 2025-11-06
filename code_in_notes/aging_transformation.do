// aging_transformation.do
use datasets/aging_transformation_macro.dta, clear
// 不
gen log_gdp_pc  = log(gdp_pc)
gen log_gdp_pc2 = log_gdp_pc^2
reghdfe hw_share_man log_gdp_pc log_gdp_pc2 share_65plus, a(code) vce(cl code)
egen mean_log_gdp_pc = mean(log_gdp_pc)
gen dm_log_gdp_pc2 = (log_gdp_pc-mean_log_gdp_pc)^2
reghdfe hw_share_man log_gdp_pc dm_log_gdp_pc2 share_65plus, a(code) vce(cl code)
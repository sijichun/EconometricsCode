// file: chow_test.do
use datasets/citydata, clear
keep if Year==2011
gen pop_growth=v8/100
gen log_pop=log(v4)
gen log_pop_dens=log(v80)
// 省会城市虚拟变量
gen metropolis=(mod(CityCode,10000)==0 | mod(CityCode,10000)==100)
// 乘积
gen d=metropolis
gen nd=1-metropolis
gen d_log_pop=d*log_pop
gen nd_log_pop=nd*log_pop
gen d_log_pop_dens=d*log_pop_dens
gen nd_log_pop_dens=nd*log_pop_dens
// 回归，无常数项
reg pop_growth d nd d_log_pop nd_log_pop d_log_pop_dens nd_log_pop_dens, noc
// 检验
test (d=nd) (d_log_pop=nd_log_pop) (d_log_pop_dens=nd_log_pop_dens)

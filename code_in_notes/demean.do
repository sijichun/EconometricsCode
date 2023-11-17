// demean.do
clear
use datasets/citydata
keep if Year==2011
gen log_pollu=log(v268)
gen log_pgdp=log(v84)-log(v4)
su log_pgdp
local m_pgdp=r(mean)
// 不去平均的平方项
gen log_pgdp2=log_pgdp^2
// 产生去平均的平方项
egen mean_log_pdgp=mean(log_pgdp)
gen dm_log_pgdp2=(log_pgdp-mean_log_pdgp)^2
// 回归
reg log_pollu log_pgdp log_pgdp2, r
di _b[log_pgdp]+_b[log_pgdp2]*2*`m_pgdp'
reg log_pollu log_pgdp dm_log_pgdp2, r

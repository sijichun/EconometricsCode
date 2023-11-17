// simulate_fe.do
clear all
set seed 880505
set obs 3000
gen R=mod(_n,30)+1
bysort R: gen M=mod(_n-1,10)+1
gen id=_n
// 生成delta 和 gamma
frame create temp1
frame change temp1
set obs 30
gen R=_n
gen delta=rnormal()
frame create temp2
frame change temp2
set obs 10
gen M=_n
gen gamma=rnormal()*sqrt(2)
frame change default
frlink m:1 R, frame(temp1)
frget delta, from(temp1)
frlink m:1 M, frame(temp2)
frget gamma, from(temp2)
// DGP1
gen h=runiform()
gen x=h+max(delta,gamma)
gen y1=1+2*x+delta+gamma+rnormal()
reghdfe y1 x , a(i.R i.M)
outreg2 using simulate_fe.tex, replace addt(R固定效应, "Yes", M固定效应, "Yes", R×M固定效应, "No") ctitle("DGP1")
reghdfe y1 x , a(i.R#i.M)
outreg2 using simulate_fe.tex, append addt(R固定效应, "No", M固定效应, "No", R×M固定效应, "Yes") ctitle("DGP1")
// DGP2
gen y2=1+2*x+delta*gamma+rnormal()
reghdfe y2 x , a(i.R i.M)
outreg2 using simulate_fe.tex, append addt(R固定效应, "Yes", M固定效应, "Yes", R×M固定效应, "No") ctitle("DGP2")
reghdfe y2 x , a(i.R#i.M)
outreg2 using simulate_fe.tex, append addt(R固定效应, "No", M固定效应, "No", R×M固定效应, "Yes") ctitle("DGP2")

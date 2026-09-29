// file: simpson_paradox.do
clear
set obs 1000
gen sex=runiform()<0.5
gen     exer=runiform()<0.8 if sex==1
replace exer=runiform()<0.3 if sex==0
gen y=80-10*sex+3*exer+rnormal()
reg y exer
outreg2 using simpson_paradox.tex, replace ctitle(全样本)
reg y exer if sex==1
outreg2 using simpson_paradox.tex, append ctitle(男性)
reg y exer if sex==0
outreg2 using simpson_paradox.tex, append ctitle(女性)
reg y exer sex
outreg2 using simpson_paradox.tex, append ctitle(全样本)

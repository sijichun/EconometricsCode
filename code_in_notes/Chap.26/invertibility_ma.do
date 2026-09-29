// inversability_ma.do
clear
set obs 200
gen t=_n
tsset t
gen e=rnormal()
gen y1=e+0.5*L.e
gen y2=e+2*L.e
// compute e from y
gen e1=y1-0.5*L.y1+0.5^2*L2.y1-0.5^3*L3.y1+0.5^4*L4.y1-0.5^5*L5.y1
gen e2=0.5*F.y2-0.5^2*F2.y2+0.5^3*F3.y2-0.5^4*F4.y2+0.5^5*F5.y2
tsline e e1 e2
